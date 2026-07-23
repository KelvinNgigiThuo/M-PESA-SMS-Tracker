import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/money_text.dart';
import '../widgets/add_account_sheet.dart';

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

  static const _zoneInfo = zoneInfo;

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
                        const SizedBox(height: 8),
                        _buildHiddenAccountsLink(),
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 16, color: Colors.grey[400]),
            onSelected: (value) {
              switch (value) {
                case 'zone':
                  _showZonePicker(account);
                  break;
                case 'rename':
                  _showRename(account);
                  break;
                case 'hide':
                  _showHideConfirm(account);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'zone', child: Text('Move to another zone')),
              if (!account.isSystem)
                const PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(
                value: 'hide',
                child: Text('Hide', style: TextStyle(color: Colors.red[400])),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddAccountButton() {
    return GestureDetector(
      onTap: () => showAddAccountSheet(context, onAdded: _load),
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

  Widget _buildHiddenAccountsLink() {
    return GestureDetector(
      onTap: _showHiddenAccounts,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off_outlined, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 6),
            Text('Hidden accounts',
                style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
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

  // ── Zone picker ──────────────────────────────────────────────────
  void _showZonePicker(Account account) {
    showZonePicker(context, account, onSelected: (zone) async {
      await db.updateAccountZone(account.id, zone);
      _load();
    });
  }

  // ── Rename sheet (custom accounts only) ─────────────────────────
  void _showRename(Account account) {
    final controller = TextEditingController(text: account.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
              const SizedBox(height: 20),
              const Text('Rename account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: _gold,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _gold)),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    await db.renameAccount(account.id, name);
                    if (mounted) {
                      Navigator.pop(ctx);
                      _load();
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(12)),
                  child: Text('Save',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _green)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hide (soft-delete) confirm ───────────────────────────────────
  void _showHideConfirm(Account account) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _green,
        title: Text('Hide "${account.name}"?',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
        content: Text(
          account.isSystem
              ? 'It will stop appearing in your accounts list and bucket pickers. Balance updates from M-Pesa messages will keep running in the background — you can restore it anytime from Hidden accounts.'
              : 'It will stop appearing in your accounts list and bucket pickers. Existing transactions are not affected, and you can restore it anytime from Hidden accounts.',
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () async {
              await db.deactivateAccount(account.id);
              if (mounted) {
                Navigator.pop(context);
                _load();
              }
            },
            child: const Text('Hide', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Hidden accounts list ─────────────────────────────────────────
  void _showHiddenAccounts() async {
    final hidden = await db.getInactiveAccounts();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                const Text('Hidden accounts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 12),
                if (hidden.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('No hidden accounts.', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: hidden.map((a) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(a.name, style: const TextStyle(fontSize: 13, color: Colors.white)),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await db.reactivateAccount(a.id);
                                final refreshed = await db.getInactiveAccounts();
                                setModalState(() => hidden
                                  ..clear()
                                  ..addAll(refreshed));
                                _load();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _gold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Restore',
                                    style: TextStyle(fontSize: 11, color: _gold, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
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
