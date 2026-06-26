import 'package:flutter/material.dart';
import 'database/app_database.dart';
import 'overlay_channel.dart';
import 'main.dart';

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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('History'),
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
          : Column(
              children: [
                // Untagged banner
                if (untaggedCount > 0)
                  GestureDetector(
                    onTap: () => setState(() => _filter = 'untagged'),
                    child: Container(
                      width: double.infinity,
                      color: Colors.orange[50],
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
                                  fontSize: 13,
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text('View',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                // Filter chips
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    children: _filters.map((f) {
                      final isSelected = _filter == f['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f['label']!),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _filter = f['value']!),
                          selectedColor: const Color(0xFF1A73E8),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Transaction count
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        '${_filtered.length} transaction${_filtered.length != 1 ? 's' : ''}',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _buildRow(_filtered[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildRow(Transaction t) {
    final isIn = t.direction == 'in';
    final color = isIn ? Colors.green : Colors.red;
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !t.isTagged ? Colors.orange[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: t.isTagged
                  ? color.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              !t.isTagged
                  ? Icons.hourglass_empty
                  : isIn
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
              color: t.isTagged ? color : Colors.orange,
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
                Text(dateStr,
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey[400])),
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
                    color: t.isTagged ? color : Colors.orange),
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
                  child: const Text('tap to tag',
                      style:
                          TextStyle(fontSize: 9, color: Colors.orange)),
                ),
            ],
          ),
        ],
      ),
    );

    // Untagged rows open the tag card on tap
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