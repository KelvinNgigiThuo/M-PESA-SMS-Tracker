import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../overlay/overlay_channel.dart';
import '../main.dart';
import '../widgets/money_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _green = Color(0xFF1A3C34);
const _gold = Color(0xFFC9A84C);
const _incomeColor = Color(0xFF5ec47a);
const _expenseColor = Color(0xFFe05252);
const _holdingColor = Color(0xFFf5a623);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _channel = MethodChannel('com.kelvin.mpesa/overlay');

  List<Transaction> _recent = [];
  List<Transaction> _openReceivables = [];
  List<Map<String, dynamic>> _custodyPools = [];

  double _mpesaBalance = 0;
  double _custodyHeld = 0;
  double _openReceivablesTotal = 0;
  double _bucketTotal = 0;
  double _zone1Total = 0;
  double _zone2Total = 0;
  double _bufferTarget = 10000;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleNativeCall);
    _signalReady();
    _load();
  }

  Future<void> _signalReady() async {
    try {
      await _channel.invokeMethod('flutterReady');
    } catch (e) {}
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'showTagCard') {
      final data = Map<String, dynamic>.from(call.arguments);
      if (mounted) {
        await showTagCard(context, data);
        _load();
        try {
          await _channel.invokeMethod('closeTagCard');
        } catch (e) {}
      }
    }
  }

  Future<void> _load() async {
    final all = await db.watchAll().first;
    final bucketBalances = await db.getBucketBalances();
    final accounts = await db.getAllAccounts();

    double mpesaBalance = 0;
    DateTime? lastBalanceTime;
    double custody = 0;
    double receivables = 0;
    final Map<String, double> poolMap = {};

    // Zone totals for dashboard headline
    double zone1Total = 0;
    double zone2Total = 0;
    for (final a in accounts) {
      final balance = a.manualBalance ??
          (a.openingBalance + (bucketBalances[a.name] ?? 0.0));
      if (a.zone == 1) zone1Total += balance;
      if (a.zone == 2) zone2Total += balance;
    }

    // Load buffer target from prefs
    final prefs = await SharedPreferences.getInstance();
    final bufferTarget = prefs.getDouble('buffer_target') ?? 10000;

    for (final t in all) {
      if (t.balanceAfter > 0) {
        if (lastBalanceTime == null ||
            t.createdAt.isAfter(lastBalanceTime)) {
          mpesaBalance = t.balanceAfter;
          lastBalanceTime = t.createdAt;
        }
      }
      if (t.type == 'custody_receive') {
        custody += t.amount;
        final label = t.poolLabel ?? 'Unnamed';
        poolMap[label] = (poolMap[label] ?? 0) + t.amount;
      }
      if (t.type == 'custody_spend') {
        custody -= t.amount;
        final label = t.poolLabel ?? 'Unnamed';
        poolMap[label] = (poolMap[label] ?? 0) - t.amount;
      }
      if (t.type == 'receivable_create') receivables += t.amount;
      if (t.type == 'receivable_clear') receivables -= t.amount;
    }

    double openingTotal = 0;
    for (final a in accounts) {
      if (a.name != 'M-Pesa') {
        if (a.manualBalance != null) {
          openingTotal += a.manualBalance!;
        } else {
          openingTotal +=
              a.openingBalance + (bucketBalances[a.name] ?? 0.0);
        }
      }
    }

    final openPools = poolMap.entries
        .where((e) => e.value > 0)
        .map((e) => {'label': e.key, 'balance': e.value})
        .toList();

    final openReceivables = all
        .where((t) => t.type == 'receivable_create')
        .toList();

    final recent = all.where((t) => t.isTagged).take(5).toList();

    setState(() {
      _mpesaBalance = mpesaBalance;
      _custodyHeld = custody.clamp(0, double.infinity);
      _openReceivablesTotal = receivables.clamp(0, double.infinity);
      _bucketTotal = openingTotal;
      _zone1Total = zone1Total;
      _zone2Total = zone2Total;
      _bufferTarget = bufferTarget;
      _custodyPools = openPools;
      _openReceivables = openReceivables;
      _recent = recent;
      _loading = false;
    });
  }

  double get _trueNetWorth =>
    _mpesaBalance + _bucketTotal - _custodyHeld + _openReceivablesTotal;

  double get _availableToDeploy =>
      _zone1Total - _custodyHeld;

  double get _bufferPercent =>
      (_zone2Total / _bufferTarget).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : RefreshIndicator(
              color: _gold,
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  // ── Dark top section ──────────────────────────────
                  SliverToBoxAdapter(child: _buildTopSection()),
                  // ── Body ─────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (_openReceivables.isNotEmpty) ...[
                          _sectionTitle('Owed to me',
                              total: _openReceivablesTotal,
                              color: _incomeColor),
                          ..._openReceivables
                              .map(_buildReceivableRow),
                          const SizedBox(height: 16),
                        ],
                        if (_custodyPools.isNotEmpty) ...[
                          _sectionTitle("I'm holding",
                              total: _custodyHeld,
                              color: _holdingColor),
                          ..._custodyPools.map(_buildCustodyRow),
                          const SizedBox(height: 16),
                        ],
                        if (_recent.isNotEmpty) ...[
                          _sectionTitle('Recent', color: Colors.grey),
                          ..._recent.map(_buildTxRow),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Top section ───────────────────────────────────────────────────
  Widget _buildTopSection() {
    final deployAmount = _availableToDeploy;
    final bufferPct = _bufferPercent;
    final bufferLabel =
        '${(bufferPct * 100).toStringAsFixed(0)}% of target';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: _green,
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App label + actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DHAHIRI',
                    style: TextStyle(
                      fontSize: 9,
                      color: _gold.withOpacity(0.6),
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: isPrivacyMode,
                        builder: (context, hidden, _) {
                          return GestureDetector(
                            onTap: () =>
                                isPrivacyMode.value = !hidden,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 14),
                              child: Icon(
                                hidden
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _gold.withOpacity(0.5),
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: _load,
                        child: Icon(Icons.refresh,
                            color: _gold.withOpacity(0.5),
                            size: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Main label
              Text(
                'Available to deploy',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.45)),
              ),
              const SizedBox(height: 4),
              // Big number
              MoneyText(
                'Ksh ${deployAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: deployAmount >= 0 ? _gold : Colors.red[300]!,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Zone 1 − custody held',
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.3)),
              ),
              const SizedBox(height: 16),
              // Buffer row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _gold.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Buffer  ',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.4)),
                      ),
                      MoneyText(
                        'Ksh ${_zone2Total.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7)),
                      ),
                    ],
                  ),
                  Text(
                    bufferLabel,
                    style: TextStyle(
                        fontSize: 10,
                        color: _gold.withOpacity(0.6)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Buffer progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: bufferPct,
                  minHeight: 3,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    bufferPct >= 1.0
                        ? _gold
                        : _gold.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Floating stat card
        Transform.translate(
          offset: const Offset(0, -22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _statCell('M-Pesa',
                      'Ksh ${_mpesaBalance.toStringAsFixed(2)}',
                      _green),
                  _statDivider(),
                  _statCell('Holding',
                      'Ksh ${_custodyHeld.toStringAsFixed(2)}',
                      _holdingColor),
                  _statDivider(),
                  _statCell('Owed to me',
                      'Ksh ${_openReceivablesTotal.toStringAsFixed(2)}',
                      _incomeColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _statCell(String label, String value, Color valueColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            MoneyText(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 9, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 0.5,
      height: 30,
      color: Colors.grey[200],
    );
  }

  // ── Section title ─────────────────────────────────────────────────
  Widget _sectionTitle(String title,
      {double? total, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                  letterSpacing: 0.8)),
          if (total != null)
            Text('Ksh ${total.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
        ],
      ),
    );
  }

  // ── Receivable row ────────────────────────────────────────────────
  Widget _buildReceivableRow(Transaction t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                color: _incomeColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(t.receivableLabel ?? t.recipient,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text('Ksh ${t.amount.toInt()}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _incomeColor)),
        ],
      ),
    );
  }

  // ── Custody row ───────────────────────────────────────────────────
  Widget _buildCustodyRow(Map<String, dynamic> pool) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                color: _holdingColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(pool['label'] as String,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Text('Ksh ${(pool['balance'] as double).toInt()}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _holdingColor)),
        ],
      ),
    );
  }

  // ── Recent tx row ─────────────────────────────────────────────────
Widget _buildTxRow(Transaction t) {
  final isIn = t.direction == 'in';
  final color = isIn ? _incomeColor : _expenseColor;
  final prefix = isIn ? '+' : '−';
  final label = _typeLabel(t.type ?? 'untagged');
  final sub = t.category ??
      t.bucketName ??
      t.poolLabel ??
      t.receivableLabel ??
      t.recipient;

  final date = t.createdAt;
  final timeStr =
      '${date.hour}:${date.minute.toString().padLeft(2, '0')}';

  return Container(
    margin: const EdgeInsets.only(bottom: 5),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: color.withOpacity(0.15), width: 0.5),
          ),
          child: Icon(
            isIn ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
            size: 15,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87)),
              if (sub.isNotEmpty)
                Text(sub,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[400]),
                    overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$prefix Ksh ${t.amount.toInt()}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
            Text(timeStr,
                style: TextStyle(
                    fontSize: 10, color: Colors.grey[400])),
          ],
        ),
      ],
    ),
  );
}

  String _typeLabel(String type) {
    switch (type) {
      case 'transfer':          return 'Transfer out';
      case 'transfer_in':       return 'Transfer in';
      case 'mshwari_out':       return 'To M-Shwari';
      case 'mshwari_in':        return 'From M-Shwari';
      case 'kcbmpesa_out':      return 'To KCB M-Pesa';
      case 'kcbmpesa_in':       return 'From KCB M-Pesa';
      case 'custody_spend':     return 'Custody spend';
      case 'custody_receive':   return 'Custody received';
      case 'receivable_create': return 'Fronted — pay me back';
      case 'receivable_clear':  return 'Receivable cleared';
      case 'expense':           return 'Expense';
      case 'income':            return 'Income';
      case 'fee':               return 'Transaction fee';
      default:                  return 'Untagged';
    }
  }
}