import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../overlay/overlay_channel.dart';
import '../main.dart';
import '../widgets/money_text.dart';

const _green = Color(0xFF1A3C34);
const _gold = Color(0xFFC9A84C);
const _incomeColor = Color(0xFF5ec47a);
const _expenseColor = Color(0xFFe05252);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> _all = [];
  String _filter = 'all';
  bool _loading = true;

  final List<Map<String, String>> _filters = [
    {'value': 'all',        'label': 'All'},
    {'value': 'untagged',   'label': 'Untagged'},
    {'value': 'expense',    'label': 'Expenses'},
    {'value': 'income',     'label': 'Income'},
    {'value': 'transfer',   'label': 'Transfers'},
    {'value': 'custody',    'label': 'Custody'},
    {'value': 'receivable', 'label': 'Receivables'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await db.watchAll().first;
    setState(() {
      _all = all;
      _loading = false;
    });
  }

  List<Transaction> get _filtered {
    switch (_filter) {
      case 'untagged':
        return _all.where((t) => !t.isTagged).toList();
      case 'expense':
        return _all
            .where((t) => t.type == 'expense' || t.type == 'fee')
            .toList();
      case 'income':
        return _all.where((t) => t.type == 'income').toList();
      case 'transfer':
        return _all
            .where((t) =>
                t.type == 'transfer' ||
                t.type == 'transfer_in' ||
                t.type == 'mshwari_out' ||
                t.type == 'mshwari_in' ||
                t.type == 'kcbmpesa_out' ||
                t.type == 'kcbmpesa_in')
            .toList();
      case 'custody':
        return _all
            .where((t) =>
                t.type == 'custody_spend' ||
                t.type == 'custody_receive')
            .toList();
      case 'receivable':
        return _all
            .where((t) =>
                t.type == 'receivable_create' ||
                t.type == 'receivable_clear')
            .toList();
      default:
        return _all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final untaggedCount = _all.where((t) => !t.isTagged).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F3),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _gold))
          : Column(
              children: [
                // ── Dark header ──────────────────────────────────
                Container(
                  color: _green,
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
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
                          GestureDetector(
                            onTap: _load,
                            child: Icon(Icons.refresh,
                                color: _gold.withOpacity(0.5),
                                size: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ledger',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _gold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_all.length} transaction${_all.length != 1 ? 's' : ''}',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.4)),
                      ),
                    ],
                  ),
                ),
                // ── Untagged banner ──────────────────────────────
                if (untaggedCount > 0)
                  GestureDetector(
                    onTap: () =>
                        setState(() => _filter = 'untagged'),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFFFF8EC),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange[700], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$untaggedCount transaction${untaggedCount > 1 ? 's' : ''} '
                              'waiting to be tagged',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text('View',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                // ── Filter chips ─────────────────────────────────
                Container(
                  color: Colors.white,
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    children: _filters.map((f) {
                      final isSelected = _filter == f['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _filter = f['value']!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _green
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(99),
                              border: Border.all(
                                color: isSelected
                                    ? _green
                                    : Colors.grey[300]!,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              f['label']!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? _gold
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Thin divider under filter chips
                Container(height: 0.5, color: Colors.grey[200]),
                // ── Transaction count ────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Row(
                    children: [
                      Text(
                        '${_filtered.length} result${_filtered.length != 1 ? 's' : ''}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                // ── List ─────────────────────────────────────────
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions found',
                            style:
                                TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : RefreshIndicator(
                          color: _gold,
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                16, 4, 16, 16),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) =>
                                _buildRow(_filtered[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRow(Transaction t) {
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
    final dateStr =
        '${date.day}/${date.month}/${date.year} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';

    final card = Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: !t.isTagged
              ? Colors.orange[100]!
              : Colors.transparent,
          width: !t.isTagged ? 1 : 0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.isTagged
                  ? color.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: t.isTagged
                    ? color.withOpacity(0.15)
                    : Colors.orange.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Icon(
              !t.isTagged
                  ? Icons.hourglass_empty
                  : isIn
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
              color: t.isTagged ? color : Colors.orange,
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
                Text(dateStr,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey[400])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MoneyText(
                '$prefix Ksh ${t.amount.toInt()}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.isTagged ? color : Colors.orange),
              ),
              if (!t.isTagged)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('tap to tag',
                      style: TextStyle(
                          fontSize: 9, color: Colors.orange)),
                ),
            ],
          ),
        ],
      ),
    );

    if (!t.isTagged) {
      return GestureDetector(
        onTap: () async {
          await showTagCard(context, {
            'amount': t.amount,
            'recipient': t.recipient,
            'direction': t.direction,
            'txCode': t.txCode,
            'balance': t.balanceAfter,
            'txCost': t.txCost,
          });
          _load();
        },
        child: card,
      );
    }

    return card;
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