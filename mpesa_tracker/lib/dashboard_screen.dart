import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/app_database.dart';
import 'overlay_channel.dart';
import 'main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _channel = MethodChannel('com.kelvin.mpesa/overlay');

  // Transactions
  List<Transaction> _recent = [];
  List<Transaction> _openReceivables = [];

  // Net worth components
  double _mpesaBalance = 0;
  double _custodyHeld = 0;
  double _openReceivablesTotal = 0;
  double _bucketTotal = 0;
  Map<String, double> _bucketBalances = {};

  // Custody pools — derived from transactions
  List<Map<String, dynamic>> _custodyPools = [];

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

    // Custody pools — track per label
    final Map<String, double> poolMap = {};

    for (final t in all) {
      // Latest M-Pesa balance from SMS
      if (t.balanceAfter > 0) {
        if (lastBalanceTime == null ||
            t.createdAt.isAfter(lastBalanceTime)) {
          mpesaBalance = t.balanceAfter;
          lastBalanceTime = t.createdAt;
        }
      }

      // Custody totals
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

      // Receivables totals
      if (t.type == 'receivable_create') receivables += t.amount;
      if (t.type == 'receivable_clear') receivables -= t.amount;
    }

    // Opening balances from accounts table (excluding M-Pesa)
    double openingTotal = 0;
    for (final a in accounts) {
      if (a.name != 'M-Pesa') {
        final manual = a.manualBalance;
        if (manual != null) {
          // Manual correction overrides opening balance
          // Add tagged movements since the correction date
          final movements = bucketBalances[a.name] ?? 0.0;
          openingTotal += manual + movements;
        } else {
          openingTotal += a.openingBalance + (bucketBalances[a.name] ?? 0.0);
        }
      }
    }

    // Filter open pools only
    final openPools = poolMap.entries
        .where((e) => e.value > 0)
        .map((e) => {'label': e.key, 'balance': e.value})
        .toList();

    // Open receivables list
    final openReceivables = all
        .where((t) => t.type == 'receivable_create')
        .toList();

    // Recent 5 tagged transactions
    final recent = all
        .where((t) => t.isTagged)
        .take(5)
        .toList();

    setState(() {
      _mpesaBalance = mpesaBalance;
      _custodyHeld = custody.clamp(0, double.infinity);
      _openReceivablesTotal = receivables.clamp(0, double.infinity);
      _bucketTotal = openingTotal;
      _bucketBalances = bucketBalances;
      _custodyPools = openPools;
      _openReceivables = openReceivables;
      _recent = recent;
      _loading = false;
    });
  }

  double get _trueNetWorth =>
      _mpesaBalance + _bucketTotal - _custodyHeld + _openReceivablesTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildNetWorthCard(),
                  const SizedBox(height: 12),
                  _buildStatRow(),
                  const SizedBox(height: 20),
                  if (_openReceivables.isNotEmpty) ...[
                    _buildSectionHeader(
                        'Owed to me', _openReceivablesTotal),
                    const SizedBox(height: 8),
                    ..._openReceivables.map(_buildReceivableRow),
                    const SizedBox(height: 20),
                  ],
                  if (_custodyPools.isNotEmpty) ...[
                    _buildSectionHeader(
                        "I'm holding", _custodyHeld),
                    const SizedBox(height: 8),
                    ..._custodyPools.map(_buildCustodyRow),
                    const SizedBox(height: 20),
                  ],
                  if (_recent.isNotEmpty) ...[
                    _buildSectionHeader('Recent', null),
                    const SizedBox(height: 8),
                    ..._recent.map(_buildTxRow),
                  ],
                ],
              ),
            ),
    );
  }

  // ── Net worth card ─────────────────────────────────────────────────
  Widget _buildNetWorthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A73E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('True Net Worth',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            'Ksh ${_trueNetWorth.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'M-Pesa + accounts − custody held + owed to me',
            style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Stat row ───────────────────────────────────────────────────────
  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(child: _statTile(
          'M-Pesa',
          'Ksh ${_mpesaBalance.toStringAsFixed(2)}',
          Colors.blue,
          Icons.phone_android,
        )),
        const SizedBox(width: 8),
        Expanded(child: _statTile(
          'Holding',
          '− Ksh ${_custodyHeld.toStringAsFixed(2)}',
          Colors.orange,
          Icons.wallet,
        )),
        const SizedBox(width: 8),
        Expanded(child: _statTile(
          'Owed to me',
          '+ Ksh ${_openReceivablesTotal.toStringAsFixed(2)}',
          Colors.green,
          Icons.arrow_downward,
        )),
      ],
    );
  }

  Widget _statTile(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, double? total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        if (total != null)
          Text('Ksh ${total.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600])),
      ],
    );
  }

  // ── Receivable row ─────────────────────────────────────────────────
  Widget _buildReceivableRow(Transaction t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long, color: Colors.green[400], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.receivableLabel ?? t.recipient,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            'Ksh ${t.amount.toInt()}',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.green),
          ),
        ],
      ),
    );
  }

  // ── Custody pool row ───────────────────────────────────────────────
  Widget _buildCustodyRow(Map<String, dynamic> pool) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.wallet, color: Colors.orange[400], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pool['label'] as String,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            'Ksh ${(pool['balance'] as double).toInt()}',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.orange),
          ),
        ],
      ),
    );
  }

  // ── Recent transaction row ─────────────────────────────────────────
  Widget _buildTxRow(Transaction t) {
    final isIn = t.direction == 'in';
    final color = isIn ? Colors.green : Colors.red;
    final prefix = isIn ? '+' : '−';
    final label = _typeLabel(t.type ?? 'untagged');
    final sub = t.category ??
        t.bucketName ??
        t.poolLabel ??
        t.receivableLabel ??
        t.recipient;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIn ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                if (sub.isNotEmpty)
                  Text(sub,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(
            '$prefix Ksh ${t.amount.toInt()}',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color),
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