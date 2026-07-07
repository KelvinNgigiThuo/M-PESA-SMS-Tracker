import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/money_text.dart';

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
  bool _loading = true;

  static const _zoneInfo = {
    1: {'label': 'Operating', 'subtitle': 'Available right now', 'icon': Icons.bolt_outlined},
    2: {'label': 'Reserves', 'subtitle': 'Accessible same-day', 'icon': Icons.shield_outlined},
    3: {'label': 'Committed', 'subtitle': 'Locked or tied up', 'icon': Icons.lock_outline},
    4: {'label': 'Invested', 'subtitle': 'Long-term growth', 'icon': Icons.trending_up},
  };

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
    for (final t in all) {
      if (t.balanceAfter > 0) {
        if (lastBalanceTime == null || t.createdAt.isAfter(lastBalanceTime)) {
          mpesaBalance = t.balanceAfter;
          lastBalanceTime = t.createdAt;
        }
      }
    }

    setState(() {
      _accounts = accounts;
      _bucketBalances = bucketBalances;
      _mpesaLiveBalance = mpesaBalance;
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

  double get _trueNetWorth {
    double total = 0;
    for (var z = 1; z <= 4; z++) {
      total += _zoneTotal(z);
    }
    return total;
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
                        const SizedBox(height: 16),
                        _buildAddAccountButton(),
                        const SizedBox(height: 16),
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
      decoration: BoxDecoration(
        color: _green,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 16),
          Text(
            'True Net Worth',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.45)),
          ),
          const SizedBox(height: 4),
          MoneyText(
            'Ksh ${_trueNetWorth.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: _gold,
              letterSpacing: -1,
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

    return GestureDetector(
      onTap: () => _showCorrectBalance(account),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(
                    hasManual ? 'Manually corrected' : 'Tracked from transfers',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            MoneyText(
              'Ksh ${balance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return GestureDetector(
      onTap: _showAddAccount,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _green.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: _green, size: 16),
            const SizedBox(width: 8),
            Text('Add new account',
                style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
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

  // ── Add new account sheet ───────────────────────────────────────
  void _showAddAccount() {
    final nameController = TextEditingController();
    int selectedZone = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Add new account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Account name',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    hintText: 'e.g. CIC Money Market',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _gold)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Which zone?', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _zoneInfo.entries.map((e) {
                    final selected = selectedZone == e.key;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedZone = e.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? _gold.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: selected ? _gold.withOpacity(0.6) : Colors.white.withOpacity(0.15),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          e.value['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? _gold : Colors.white.withOpacity(0.7),
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    await db.addCustomAccount(name, 'custom');
                    final newAccounts = await db.getAllAccounts();
                    final created = newAccounts.lastWhere((a) => a.name == name);
                    await db.updateAccountZone(created.id, selectedZone);
                    if (mounted) {
                      Navigator.pop(context);
                      _load();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(12)),
                    child: Text('Add account',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}