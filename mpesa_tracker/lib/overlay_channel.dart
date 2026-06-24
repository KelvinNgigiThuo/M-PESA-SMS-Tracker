import 'package:flutter/material.dart';
import 'main.dart';
import 'database/app_database.dart';
import 'package:drift/drift.dart' as drift;

Future<void> showTagCard(BuildContext context, Map<String, dynamic> data) async {
  final amount = (data['amount'] as num).toDouble();
  final txCost = (data['txCost'] as num?)?.toDouble() ?? 0.0;
  final recipient = data['recipient'] as String;
  final direction = data['direction'] as String;
  final txCode = data['txCode'] as String;
  final balance = (data['balance'] as num).toDouble();

  if (txCost > 0) {
    await db.insertTransaction(TransactionsCompanion(
      txCode: drift.Value('${txCode}_fee'),
      amount: drift.Value(txCost),
      recipient: drift.Value('M-Pesa'),
      direction: drift.Value('out'),
      type: drift.Value('fee'),
      category: drift.Value('Transaction fee'),
      balanceAfter: drift.Value(balance),
      rawSms: drift.Value('auto-split fee'),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
  }

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (_) => _TagCard(
      amount: amount,
      recipient: recipient,
      direction: direction,
      txCode: txCode,
      balance: balance,
    ),
  );
}

// ── Single stateful card that manages its own screen flow ────────────
class _TagCard extends StatefulWidget {
  final double amount;
  final String recipient;
  final String direction;
  final String txCode;
  final double balance;

  const _TagCard({
    required this.amount,
    required this.recipient,
    required this.direction,
    required this.txCode,
    required this.balance,
  });

  @override
  State<_TagCard> createState() => _TagCardState();
}

class _TagCardState extends State<_TagCard> {
  // Tracks which screen we're on
  String _screen = 'root';

  // For expense screen
  String? _selectedCategory;

  // For note screens
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.fromLTRB(
        16, 12, 16,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Route to correct screen
          _buildScreen(),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case 'root':         return _buildRoot();
      case 'bucket':       return _buildBucketPicker();
      case 'not_mine':     return _buildNotMine();
      case 'custody':      return _buildCustodyNote();
      case 'reimbursable': return _buildReimbursableNote();
      case 'expense':      return _buildExpense();
      default:             return _buildRoot();
    }
  }

  // ── Header shared across all screens ──────────────────────────────
  Widget _buildHeader(String label, {String? backScreen}) {
    return Row(
      children: [
        if (backScreen != null)
          GestureDetector(
            onTap: () => setState(() => _screen = backScreen),
            child: const Icon(Icons.chevron_left, color: Colors.grey),
          ),
        if (backScreen != null) const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        GestureDetector(
          onTap: () => _saveUntagged(),
          child: const Icon(Icons.close, color: Colors.grey, size: 18),
        ),
      ],
    );
  }

  // ── Screen: root ──────────────────────────────────────────────────
  Widget _buildRoot() {
    final amountLabel = 'Ksh ${widget.amount.toInt()}';
    final subLabel = '${widget.direction == "out" ? "to" : "from"} ${widget.recipient}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(amountLabel,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () => _saveUntagged(),
              child: const Icon(Icons.close, color: Colors.grey),
            ),
          ],
        ),
        Text(subLabel,
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 20),
        if (widget.direction == 'out') ...[
          _rootBtn(Icons.account_balance, 'My account', Colors.blue,
              () => setState(() => _screen = 'bucket')),
          const SizedBox(height: 8),
          _rootBtn(Icons.block, 'Not mine', Colors.blue,
              () => setState(() => _screen = 'not_mine')),
          const SizedBox(height: 8),
          _rootBtn(Icons.receipt_long, 'True expense', Colors.red,
              () => setState(() => _screen = 'expense')),
        ] else ...[
          const Text('Inflow tagging coming in M5',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          _saveBtn('Save as untagged', () => _saveUntagged()),
        ],
      ],
    );
  }

  // ── Screen: bucket picker ─────────────────────────────────────────
  Widget _buildBucketPicker() {
    final buckets = [
      {'name': 'NCBA', 'icon': Icons.account_balance},
      {'name': 'KCB Bank', 'icon': Icons.account_balance},
      {'name': 'M-Shwari', 'icon': Icons.savings},
      {'name': 'KCB M-Pesa', 'icon': Icons.account_balance_wallet},
      {'name': 'Money Market', 'icon': Icons.trending_up},
      {'name': 'Company', 'icon': Icons.business},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('My account · Ksh ${widget.amount.toInt()}',
            backScreen: 'root'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.2,
          physics: const NeverScrollableScrollPhysics(),
          children: buckets.map((b) {
            return GestureDetector(
              onTap: () => _saveTransfer(b['name'] as String),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(b['icon'] as IconData, color: Colors.blue, size: 20),
                    const SizedBox(height: 4),
                    Text(b['name'] as String,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Screen: not mine sub-choice ───────────────────────────────────
  Widget _buildNotMine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Not mine · Ksh ${widget.amount.toInt()}',
            backScreen: 'root'),
        const SizedBox(height: 16),
        _rootBtn(Icons.wallet, "I'm holding their money", Colors.blue,
            () => setState(() { _noteController.clear(); _screen = 'custody'; })),
        const SizedBox(height: 8),
        _rootBtn(Icons.undo, "I'll be paid back", Colors.blue,
            () => setState(() { _noteController.clear(); _screen = 'reimbursable'; })),
      ],
    );
  }

  // ── Screen: custody note ──────────────────────────────────────────
  Widget _buildCustodyNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader("Holding their money · Ksh ${widget.amount.toInt()}",
            backScreen: 'not_mine'),
        const SizedBox(height: 16),
        const Text("What's this for?",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: _noteController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Fuel float, Westlands job',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        _saveBtn('Save', () => _saveCustody()),
      ],
    );
  }

  // ── Screen: reimbursable note ─────────────────────────────────────
  Widget _buildReimbursableNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader("Pay me back · Ksh ${widget.amount.toInt()}",
            backScreen: 'not_mine'),
        const SizedBox(height: 16),
        const Text("Which job is this for?",
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: _noteController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Client X supplies',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        _saveBtn('Save', () => _saveReimbursable()),
      ],
    );
  }

  // ── Screen: expense category ──────────────────────────────────────
  Widget _buildExpense() {
    const categories = ['Food', 'Transport', 'Supplies', 'Bills', 'Other'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('True expense · Ksh ${widget.amount.toInt()}',
            backScreen: 'root'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((c) {
            return ChoiceChip(
              label: Text(c),
              selected: _selectedCategory == c,
              onSelected: (_) => setState(() => _selectedCategory = c),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _saveBtn('Save',
            _selectedCategory == null ? null : () => _saveExpense()),
      ],
    );
  }

  // ── Save methods ──────────────────────────────────────────────────
  Future<void> _saveTransfer(String bucketName) async {
    await db.insertTransaction(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(widget.amount),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value('out'),
      type: drift.Value('transfer'),
      bucketName: drift.Value(bucketName),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveCustody() async {
    final label = _noteController.text.trim().isEmpty
        ? 'Custody – ${DateTime.now().day}/${DateTime.now().month}'
        : _noteController.text.trim();
    await db.insertTransaction(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(widget.amount),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value('out'),
      type: drift.Value('custody_spend'),
      poolLabel: drift.Value(label),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveReimbursable() async {
    final label = _noteController.text.trim().isEmpty
        ? 'Reimbursement – ${DateTime.now().day}/${DateTime.now().month}'
        : _noteController.text.trim();
    await db.insertTransaction(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(widget.amount),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value('out'),
      type: drift.Value('receivable_create'),
      receivableLabel: drift.Value(label),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveExpense() async {
    await db.insertTransaction(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(widget.amount),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value('out'),
      type: drift.Value('expense'),
      category: drift.Value(_selectedCategory!),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveUntagged() async {
    await db.insertTransaction(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(widget.amount),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value(widget.direction),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(false),
    ));
    if (mounted) Navigator.pop(context);
  }

  // ── Shared UI helpers ─────────────────────────────────────────────
  Widget _rootBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _saveBtn(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey[200] : Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: onTap == null ? Colors.grey : Colors.white,
          ),
        ),
      ),
    );
  }
}