import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/app_database.dart';
import 'main.dart';

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
      final balance = double.tryParse(text.replaceAll(',', '')) ?? 0.0;
      await db.updateOpeningBalance(account.id, balance);
    }

    if (mounted) {
      // Navigate to dashboard and remove setup from stack
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  String _groupLabel(String group) {
    switch (group) {
      case 'mpesa':           return 'M-Pesa';
      case 'bank':            return 'Bank Accounts';
      case 'mobile_savings':  return 'Mobile Savings';
      case 'investment':      return 'Investments';
      default:                return group;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group accounts by their group field
    final grouped = <String, List<Account>>{};
    for (final a in _accounts) {
      grouped.putIfAbsent(a.group, () => []).add(a);
    }

    final groupOrder = ['mpesa', 'bank', 'mobile_savings', 'investment'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Set opening balances'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  color: const Color(0xFF1A73E8),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: const Text(
                    'Enter what each account holds right now.\nSkip any account you don\'t use.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
                // Account list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final group in groupOrder)
                        if (grouped.containsKey(group)) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16, bottom: 8),
                            child: Text(
                              _groupLabel(group),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          for (final account in grouped[group]!)
                            _buildAccountRow(account),
                        ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Save button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: GestureDetector(
                    onTap: _saving ? null : _save,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _saving
                            ? Colors.grey[300]
                            : const Color(0xFF1A73E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _saving
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Done — take me to my dashboard',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
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

  Widget _buildAccountRow(Account account) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              account.name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const Text(
            'Ksh',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _controllers[account.id],
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'[\d,.]')),
              ],
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: '0.00',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}