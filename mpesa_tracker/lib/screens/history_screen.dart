import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../overlay/overlay_channel.dart';
import '../main.dart';
import '../widgets/money_text.dart';
import '../widgets/direction_toggle.dart';

const _green = Color(0xFF1A3C34);
const _gold = Color(0xFFC9A84C);
const _incomeColor = Color(0xFF5ec47a);
const _expenseColor = Color(0xFFe05252);

List<BoxShadow> get _cardShadow => [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Transaction> _all = [];
  String _direction = 'out';
  bool _untaggedOnly = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (ledgerInitialDirection.value != null) {
      _direction = ledgerInitialDirection.value!;
      ledgerInitialDirection.value = null;
    }
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
    // Untagged transactions can be either direction — show all of them
    // regardless of the Out/In toggle, since tagging is how their
    // category (and often their real intent) gets decided in the first
    // place.
    if (_untaggedOnly) {
      return _all.where((t) => !t.isTagged).toList();
    }
    return _all.where((t) => t.direction == _direction).toList();
  }

  double _sumType(String type) => _all
      .where((t) => t.type == type)
      .fold(0.0, (sum, t) => sum + t.amount);

  List<MapEntry<String, double>> get _typeSummary {
    final Map<String, double> totals = _direction == 'out'
        ? {
            'True expense': _sumType('expense'),
            'Transfers': _sumType('transfer'),
            'Custody spent': _sumType('custody_spend'),
            'Fronted (owed)': _sumType('receivable_create'),
          }
        : {
            'True income': _sumType('income'),
            'Transfers in': _sumType('transfer_in'),
            'Custody received': _sumType('custody_receive'),
            'Debt repayment': _sumType('receivable_clear'),
          };
    return totals.entries.where((e) => e.value > 0).toList();
  }

  List<MapEntry<String, double>> get _categorySummary {
    final Map<String, double> totals = {};
    for (final t in _all) {
      if (t.direction != _direction) continue;
      final cat = t.category;
      if (cat == null || cat.isEmpty) continue;
      final topLevel = cat.split(': ').first;
      totals[topLevel] = (totals[topLevel] ?? 0) + t.amount;
    }
    final list = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
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
                // ── Outflow/Inflow toggle + breakdowns + list ────
                Expanded(
                  child: RefreshIndicator(
                    color: _gold,
                    onRefresh: _load,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Untagged banner ──────────────────
                          if (untaggedCount > 0)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 14, 16, 0),
                              child: GestureDetector(
                                onTap: () => setState(() =>
                                    _untaggedOnly = !_untaggedOnly),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _untaggedOnly
                                        ? _gold.withOpacity(0.12)
                                        : Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(14),
                                    border: Border.all(
                                        color: _gold.withOpacity(0.35),
                                        width: 1),
                                    boxShadow: _cardShadow,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: _gold.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(9),
                                        ),
                                        child: const Icon(
                                            Icons.hourglass_empty,
                                            color: _gold,
                                            size: 15),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '$untaggedCount transaction${untaggedCount > 1 ? 's' : ''} '
                                          'waiting to be tagged',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: _green,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Icon(
                                        _untaggedOnly
                                            ? Icons.close
                                            : Icons.chevron_right,
                                        color: _gold,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          // ── Direction toggle card ────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16, 14, 16, 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: _cardShadow,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildDirectionToggle(
                                    value: _direction,
                                    onChanged: (v) => setState(
                                        () => _direction = v),
                                  ),
                                  Text(
                                    _untaggedOnly
                                        ? '${_filtered.length} untagged'
                                        : '${_filtered.length} ${_direction == 'out' ? 'outflow' : 'inflow'}${_filtered.length != 1 ? 's' : ''}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16, 16, 16, 0),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (_typeSummary.isNotEmpty) ...[
                                  _breakdownTitle('Summary'),
                                  const SizedBox(height: 8),
                                  _buildSummaryCard(_typeSummary),
                                  const SizedBox(height: 16),
                                ],
                                if (_categorySummary.isNotEmpty) ...[
                                  _breakdownTitle('By category'),
                                  const SizedBox(height: 8),
                                  _buildSummaryCard(_categorySummary),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 40),
                              child: Center(
                                child: Text(
                                  'No transactions found',
                                  style: TextStyle(
                                      color: Colors.grey[400]),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 0, 16, 16),
                              child: Column(
                                children:
                                    _filtered.map(_buildRow).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _breakdownTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey[400],
          letterSpacing: 0.8),
    );
  }

  Widget _buildSummaryCard(List<MapEntry<String, double>> entries) {
    final color = _direction == 'out' ? _expenseColor : _incomeColor;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _cardShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: i == entries.length - 1
                    ? null
                    : Border(
                        bottom: BorderSide(
                            color: Colors.grey[100]!, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entries[i].key,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  MoneyText(
                    'Ksh ${entries[i].value.toStringAsFixed(0)}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color),
                  ),
                ],
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
              ? _gold.withOpacity(0.3)
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
                  : _gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: t.isTagged
                    ? color.withOpacity(0.15)
                    : _gold.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: Icon(
              !t.isTagged
                  ? Icons.hourglass_empty
                  : isIn
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
              color: t.isTagged ? color : _gold,
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
                    color: t.isTagged ? color : _green),
              ),
              if (!t.isTagged)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('tap to tag',
                      style: TextStyle(
                          fontSize: 9,
                          color: _gold.withOpacity(0.9),
                          fontWeight: FontWeight.w600)),
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
      case 'receivable_clear':  return 'Debt repayment';
      case 'expense':           return 'Expense';
      case 'income':            return 'Income';
      case 'fee':               return 'Transaction fee';
      default:                  return 'Untagged';
    }
  }
}