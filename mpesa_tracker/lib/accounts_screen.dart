import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/app_database.dart';
import 'main.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Account> _accounts = [];
  Map<String, double> _bucketBalances = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final accounts = await db.getAllAccounts();
    final bucketBalances = await db.getBucketBalances();
    setState(() {
      _accounts = accounts;
      _bucketBalances = bucketBalances;
      _loading = false;
    });
  }

  // Compute live balance for an account
  double _balanceFor(Account a) {
    if (a.name == 'M-Pesa') {
      // M-Pesa balance comes from dashboard — show opening balance here
      // as a fallback since live balance is tracked via SMS
      return a.openingBalance;
    }
    final movements = _bucketBalances[a.name] ?? 0.0;
    final base = a.manualBalance ?? a.openingBalance;
    return base + movements;
  }

  String _groupLabel(String group) {
    switch (group) {
      case 'mpesa':          return 'M-Pesa';
      case 'bank':           return 'Bank Accounts';
      case 'mobile_savings': return 'Mobile Savings';
      case 'investment':     return 'Investments';
      default:               return group;
    }
  }

  IconData _groupIcon(String group) {
    switch (group) {
      case 'mpesa':          return Icons.phone_android;
      case 'bank':           return Icons.account_balance;
      case 'mobile_savings': return Icons.savings;
      case 'investment':     return Icons.trending_up;
      default:               return Icons.wallet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Account>>{};
    for (final a in _accounts) {
      grouped.putIfAbsent(a.group, () => []).add(a);
    }

    final groupOrder = ['mpesa', 'bank', 'mobile_savings', 'investment'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Accounts'),
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
                  for (final group in groupOrder)
                    if (grouped.containsKey(group)) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Row(
                          children: [
                            Icon(_groupIcon(group),
                                size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 6),
                            Text(
                              _groupLabel(group),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (final account in grouped[group]!)
                        _buildAccountCard(account),
                    ],
                  const SizedBox(height: 24),
                  // Add new account button
                  GestureDetector(
                    onTap: () => _showAddAccount(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF1A73E8),
                            style: BorderStyle.solid),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Color(0xFF1A73E8), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Add new account',
                            style: TextStyle(
                                color: Color(0xFF1A73E8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildAccountCard(Account account) {
    final balance = _balanceFor(account);
    final hasManual = account.manualBalance != null;

    return GestureDetector(
      onTap: () => _showCorrectBalance(account),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    hasManual
                        ? 'Manual correction set'
                        : 'Opening balance + transfers',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Ksh ${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to correct',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Manual balance correction sheet ───────────────────────────────
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
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                account.name,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Set the actual current balance. The app will track movements from this point.',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Ksh',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\d,.]')),
                      ],
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final value = double.tryParse(
                          controller.text
                              .trim()
                              .replaceAll(',', '')) ??
                      0.0;
                  await db.setManualBalance(account.id, value);
                  if (mounted) {
                    Navigator.pop(context);
                    _load();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Save correction',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Add new account sheet ─────────────────────────────────────────
  void _showAddAccount() {
    final nameController = TextEditingController();
    String selectedGroup = 'bank';

    final groups = [
      {'value': 'mpesa', 'label': 'M-Pesa'},
      {'value': 'bank', 'label': 'Bank'},
      {'value': 'mobile_savings', 'label': 'Mobile Savings'},
      {'value': 'investment', 'label': 'Investment'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Add new account',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Account name',
                    hintText: 'e.g. CIC Money Market',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                // Group selector
                Wrap(
                  spacing: 8,
                  children: groups.map((g) {
                    final isSelected = selectedGroup == g['value'];
                    return ChoiceChip(
                      label: Text(g['label']!),
                      selected: isSelected,
                      onSelected: (_) => setModalState(
                          () => selectedGroup = g['value']!),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    await db.addCustomAccount(name, selectedGroup);
                    if (mounted) {
                      Navigator.pop(context);
                      _load();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Add account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
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