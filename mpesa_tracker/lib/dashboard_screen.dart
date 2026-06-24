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
  List<Transaction> _transactions = [];
  bool _loading = true;

  // Net worth components
  double _lastMpesaBalance = 0;
  double _custodyHeld = 0;
  double _openReceivables = 0;

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
    } catch (e) {
      // TagCardActivity will retry
    }
  }

  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'showTagCard') {
      final data = Map<String, dynamic>.from(call.arguments);
      if (mounted) {
        await showTagCard(context, data);
        _load();
        try {
          await _channel.invokeMethod('closeTagCard');
        } catch (e) {
          // Only TagCardActivity needs to close
        }
      }
    }
  }

  Future<void> _load() async {
    final all = await db.watchAll().first;

    double custody = 0;
    double receivables = 0;
    double lastBalance = 0;
    DateTime? lastBalanceTime;

    for (final t in all) {
        // Only update balance if this transaction is more recent
        if (t.balanceAfter > 0) {
        if (lastBalanceTime == null || t.createdAt.isAfter(lastBalanceTime)) {
            lastBalance = t.balanceAfter;
            lastBalanceTime = t.createdAt;
        }
        }

        // Custody held
        if (t.type == 'custody_receive') custody += t.amount;
        if (t.type == 'custody_spend') custody -= t.amount;

        // Open receivables
        if (t.type == 'receivable_create') receivables += t.amount;
        if (t.type == 'receivable_clear') receivables -= t.amount;
    }

    setState(() {
        _transactions = all;
        _lastMpesaBalance = lastBalance;
        _custodyHeld = custody.clamp(0, double.infinity);
        _openReceivables = receivables.clamp(0, double.infinity);
        _loading = false;
    });
    }

  double get _trueNetWorth =>
      _lastMpesaBalance - _custodyHeld + _openReceivables;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('M-Pesa Tracker'),
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
                  const SizedBox(height: 16),
                  _buildBreakdownRow(),
                  const SizedBox(height: 20),
                  _buildTransactionList(),
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
                fontSize: 28,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'M-Pesa balance − custody held + receivables owed',
            style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Breakdown row ──────────────────────────────────────────────────
  Widget _buildBreakdownRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatTile(
            label: 'M-Pesa balance',
            value: 'Ksh ${_lastMpesaBalance.toStringAsFixed(2)}',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatTile(
            label: 'Custody held',
            value: '− Ksh ${_custodyHeld.toStringAsFixed(2)}',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatTile(
            label: 'Owed to me',
            value: '+ Ksh ${_openReceivables.toStringAsFixed(2)}',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(
      {required String label,
      required String value,
      required Color color}) {
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
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  // ── Transaction list ───────────────────────────────────────────────
  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text('No transactions yet',
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transactions (${_transactions.length})',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
        const SizedBox(height: 10),
        ...(_transactions.map((t) => _buildTxRow(t)).toList()),
      ],
    );
  }

  Widget _buildTxRow(Transaction t) {
    final isIn = t.direction == 'in';
    final amountColor = isIn ? Colors.green : Colors.red;
    final amountPrefix = isIn ? '+' : '−';
    final typeLabel = _typeLabel(t.type ?? 'untagged');
    final subLabel = t.category ??
        t.bucketName ??
        t.poolLabel ??
        t.receivableLabel ??
        t.recipient;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: t.isTagged ? Colors.grey[200]! : Colors.orange[200]!),
      ),
      child: Row(
        children: [
          // Direction indicator
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIn ? Icons.arrow_downward : Icons.arrow_upward,
              color: amountColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(typeLabel,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                if (subLabel.isNotEmpty)
                  Text(subLabel,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[500]),
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Amount + untagged badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix Ksh ${t.amount.toInt()}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: amountColor),
              ),
              if (!t.isTagged)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('untagged',
                      style: TextStyle(
                          fontSize: 9, color: Colors.orange)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'transfer':        return 'Transfer out';
      case 'transfer_in':     return 'Transfer in';
      case 'custody_spend':   return 'Custody spend';
      case 'custody_receive': return 'Custody received';
      case 'receivable_create': return 'Fronted — pay me back';
      case 'receivable_clear':  return 'Receivable cleared';
      case 'expense':         return 'Expense';
      case 'income':          return 'Income';
      case 'fee':             return 'Transaction fee';
      default:                return 'Untagged';
    }
  }
}