import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/money_text.dart';
import '../widgets/add_account_sheet.dart' show zoneInfo;

const _green = Color(0xFF1A3C34);
const _gold = Color(0xFFC9A84C);

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Account> _accounts = [];
  Map<String, double> _bucketBalances = {};
  double _mpesaLiveBalance = 0;
  double _custodyHeld = 0;
  double _openReceivablesTotal = 0;
  bool _loading = true;
  Set<int> _hiddenAccountIds = {};

  static const _zoneInfo = zoneInfo;

  bool get _allHidden =>
      _accounts.isNotEmpty && _hiddenAccountIds.length == _accounts.length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final accounts = await db.getAllAccounts();
    final bucketBalances = await db.getBucketBalances();
    final all = await db.watchAll().first;

    double mpesaBalance = 0;
    DateTime? lastBalanceTime;
    double custody = 0;
    double receivables = 0;
    for (final t in all) {
      if (t.balanceAfter > 0) {
        if (lastBalanceTime == null || t.createdAt.isAfter(lastBalanceTime)) {
          mpesaBalance = t.balanceAfter;
          lastBalanceTime = t.createdAt;
        }
      }
      if (t.type == 'custody_receive') custody += t.amount;
      if (t.type == 'custody_spend') custody -= t.amount;
      if (t.type == 'receivable_create') receivables += t.amount;
      if (t.type == 'receivable_clear') receivables -= t.amount;
    }

    setState(() {
      _accounts = accounts;
      _bucketBalances = bucketBalances;
      _mpesaLiveBalance = mpesaBalance;
      _custodyHeld = custody.clamp(0, double.infinity);
      _openReceivablesTotal = receivables.clamp(0, double.infinity);
      _loading = false;
    });
  }

  double _balanceFor(Account a) {
    if (a.name == 'M-Pesa') {
      return _mpesaLiveBalance > 0 ? _mpesaLiveBalance : a.openingBalance;
    }
    if (a.manualBalance != null) {
      return a.manualBalance!;
    }
    final movements = _bucketBalances[a.name] ?? 0.0;
    return a.openingBalance + movements;
  }

  double _zoneTotal(int zone) {
    return _accounts
        .where((a) => a.zone == zone)
        .fold(0.0, (sum, a) => sum + _balanceFor(a));
  }

  double get _allZonesTotal {
    double total = 0;
    for (var z = 1; z <= 4; z++) {
      total += _zoneTotal(z);
    }
    return total;
  }

  /// Overall financial position: all account balances, minus money held
  /// in custody for someone else (a liability), plus money owed to me
  /// that I've fronted (an asset not yet in hand).
  double get _trueNetWorth =>
      _allZonesTotal - _custodyHeld + _openReceivablesTotal;

  /// Same, but without counting pending debts owed to me — since those
  /// might or might not actually get paid back.
  double get _netWorthWithoutDebt => _allZonesTotal - _custodyHeld;

  void _toggleAll() {
    setState(() {
      _hiddenAccountIds =
          _allHidden ? {} : _accounts.map((a) => a.id).toSet();
    });
  }

  void _toggleAccount(int id) {
    setState(() {
      if (_hiddenAccountIds.contains(id)) {
        _hiddenAccountIds.remove(id);
      } else {
        _hiddenAccountIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <int, List<Account>>{};
    for (final a in _accounts) {
      grouped.putIfAbsent(a.zone, () => []).add(a);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F3),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : RefreshIndicator(
              color: _gold,
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        for (var zone = 1; zone <= 4; zone++)
                          if (grouped.containsKey(zone))
                            _buildZoneSection(zone, grouped[zone]!),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _green,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MY MONEY',
                style: TextStyle(
                  fontSize: 9,
                  color: _gold.withOpacity(0.6),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: _toggleAll,
                child: Icon(
                  _allHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _gold.withOpacity(0.5),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'True Net Worth',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.45)),
          ),
          const SizedBox(height: 4),
          MoneyText(
            'Ksh ${_trueNetWorth.toStringAsFixed(2)}',
            hidden: _allHidden,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: _gold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          MoneyText(
            'Ksh ${_netWorthWithoutDebt.toStringAsFixed(2)} without pending debts',
            hidden: _allHidden,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneSection(int zone, List<Account> accounts) {
    final info = _zoneInfo[zone]!;
    final total = _zoneTotal(zone);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(info['icon'] as IconData, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                (info['label'] as String).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '· ${info['subtitle']}',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
              const Spacer(),
              MoneyText(
                'Ksh ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final account in accounts) _buildAccountCard(account),
        ],
      ),
    );
  }

  Widget _buildAccountCard(Account account) {
    final balance = _balanceFor(account);
    final hasManual = account.manualBalance != null;
    final hidden = _hiddenAccountIds.contains(account.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showCorrectBalance(account),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(account.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              if (account.isSystem) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: _gold.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('System',
                                      style: TextStyle(fontSize: 8, color: _gold.withOpacity(0.9), fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            hasManual ? 'Manually corrected' : 'Tracked from transfers',
                            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                    MoneyText(
                      'Ksh ${balance.toStringAsFixed(2)}',
                      hidden: hidden,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _toggleAccount(account.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 16,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Manual balance correction sheet ─────────────────────────────
  void _showCorrectBalance(Account account) {
    final controller = TextEditingController(
      text: account.manualBalance != null
          ? account.manualBalance!.toStringAsFixed(2)
          : _balanceFor(account).toStringAsFixed(2),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(account.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                'Set the actual current balance.',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Ksh', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                      cursorColor: _gold,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _gold)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final value = double.tryParse(controller.text.trim().replaceAll(',', '')) ?? 0.0;
                  await db.setManualBalance(account.id, value);
                  if (mounted) {
                    Navigator.pop(ctx);
                    _load();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(12)),
                  child: Text('Save correction',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
