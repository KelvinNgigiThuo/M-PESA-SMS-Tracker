import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../services/setup_service.dart';

const _green = Color(0xFF1A3C34);
const _gold = Color(0xFFC9A84C);

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  List<Account> _accounts = [];
  final Map<int, TextEditingController> _controllers = {};
  bool _loading = true;
  bool _saving = false;

  static const _zoneInfo = {
    1: {'label': 'Operating', 'subtitle': 'M-Pesa and day-to-day accounts'},
    2: {'label': 'Reserves', 'subtitle': 'M-Shwari, KCB M-Pesa — same-day access'},
    3: {'label': 'Committed', 'subtitle': 'Bank accounts and locked savings'},
    4: {'label': 'Invested', 'subtitle': 'Long-term — Etica, Company equity'},
  };

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final all = await db.getAllAccounts();
    final controllers = <int, TextEditingController>{};
    for (final a in all) {
      controllers[a.id] = TextEditingController(
        text: a.openingBalance > 0
            ? a.openingBalance.toStringAsFixed(2)
            : '',
      );
    }
    setState(() {
      _accounts = all;
      _controllers.addAll(controllers);
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    for (final account in _accounts) {
      final text = _controllers[account.id]?.text.trim() ?? '';
      final balance =
          double.tryParse(text.replaceAll(',', '')) ?? 0.0;
      await db.updateOpeningBalance(account.id, balance);
    }
    await SetupService.markSetupComplete();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
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
          ? const Center(
              child: CircularProgressIndicator(color: _gold))
          : Column(
              children: [
                // ── Dark header ──────────────────────────────────
                Container(
                  color: _green,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.fromLTRB(20, 56, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 16),
                      const Text(
                        'Set your balances',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _gold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Enter what each account holds right now.\nSkip anything you don\'t use — you can update anytime.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.45),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Account list ─────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        16, 20, 16, 16),
                    children: [
                      for (var zone = 1; zone <= 4; zone++)
                        if (grouped.containsKey(zone)) ...[
                          _buildZoneHeader(zone),
                          const SizedBox(height: 8),
                          for (final account in grouped[zone]!)
                            _buildAccountRow(account),
                          const SizedBox(height: 16),
                        ],
                    ],
                  ),
                ),
                // ── Save button ──────────────────────────────────
                Container(
                  color: const Color(0xFFF2F5F3),
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  child: GestureDetector(
                    onTap: _saving ? null : _save,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _saving
                            ? Colors.grey[300]
                            : _green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _saving
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _gold,
                                ),
                              ),
                            )
                          : const Text(
                              'Done — take me to my dashboard',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _gold,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildZoneHeader(int zone) {
    final info = _zoneInfo[zone]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (info['label']! as String).toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          info['subtitle']! as String,
          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
        ),
      ],
    );
  }

  Widget _buildAccountRow(Account account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              account.name,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            'Ksh',
            style: TextStyle(
                fontSize: 12, color: Colors.grey[400]),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: TextField(
              controller: _controllers[account.id],
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[\d,.]')),
              ],
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle:
                    TextStyle(color: Colors.grey[300]),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}