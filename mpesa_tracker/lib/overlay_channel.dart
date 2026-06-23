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

  // Auto-save the transaction fee silently before showing card
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
    builder: (_) => _TagCard(
      amount: amount,
      recipient: recipient,
      direction: direction,
      txCode: txCode,
      balance: balance,
    ),
  );
}

class _TagCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Amount + recipient
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ksh ${amount % 1 == 0 ? amount.toInt() : amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _saveUntagged(context),
              ),
            ],
          ),
          Text(
            '${direction == "out" ? "to" : "from"} $recipient',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          // Root buttons — outflow only for M4
          if (direction == 'out') ...[
            _RootButton(
              icon: Icons.account_balance,
              label: 'My account',
              color: Colors.blue,
              onTap: () => _showBucketPicker(context),
            ),
            const SizedBox(height: 8),
            _RootButton(
              icon: Icons.block,
              label: 'Not mine',
              color: Colors.blue,
              onTap: () => _showNotMine(context),
            ),
            const SizedBox(height: 8),
            _RootButton(
              icon: Icons.receipt_long,
              label: 'True expense',
              color: Colors.red,
              onTap: () => _showExpense(context),
            ),
          ] else ...[
            // Inflow placeholder — M5
            const Text(
              'Inflow tagging coming in next build',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            _SaveButton(label: 'Save as untagged', onTap: () => _saveUntagged(context)),
          ],
        ],
      ),
    );
  }

  // ── Branch: My account ──────────────────────────────────────────────
  void _showBucketPicker(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BucketPicker(
        amount: amount, txCode: txCode, recipient: recipient, balance: balance,
      ),
    );
  }

  // ── Branch: Not mine ────────────────────────────────────────────────
  void _showNotMine(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotMineSubChoice(
        amount: amount, txCode: txCode, recipient: recipient, balance: balance,
      ),
    );
  }

  // ── Branch: True expense ────────────────────────────────────────────
  void _showExpense(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExpensePicker(
        amount: amount, txCode: txCode, recipient: recipient, balance: balance,
      ),
    );
  }

  Future<void> _saveUntagged(BuildContext context) async {
    await db.insertTransaction(TransactionsCompanion(
      txCode: drift.Value(txCode),
      amount: drift.Value(amount),
      recipient: drift.Value(recipient),
      direction: drift.Value(direction),
      balanceAfter: drift.Value(balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(false),
    ));
    if (context.mounted) Navigator.pop(context);
  }
}

// ── Bucket picker ────────────────────────────────────────────────────
class _BucketPicker extends StatelessWidget {
  final double amount;
  final String txCode;
  final String recipient;
  final double balance;

  const _BucketPicker({
    required this.amount, required this.txCode,
    required this.recipient, required this.balance,
  });

  static const buckets = [
    {'name': 'NCBA', 'icon': Icons.account_balance, 'group': 'bank'},
    {'name': 'KCB Bank', 'icon': Icons.account_balance, 'group': 'bank'},
    {'name': 'M-Shwari', 'icon': Icons.savings, 'group': 'mobile_savings'},
    {'name': 'KCB M-Pesa', 'icon': Icons.account_balance_wallet, 'group': 'mobile_savings'},
    {'name': 'Money Market', 'icon': Icons.trending_up, 'group': 'investment'},
    {'name': 'Company', 'icon': Icons.business, 'group': 'investment'},
  ];

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      backLabel: 'My account · Ksh ${amount.toInt()}',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
        physics: const NeverScrollableScrollPhysics(),
        children: buckets.map((b) {
          return _GridTile(
            icon: b['icon'] as IconData,
            label: b['name'] as String,
            onTap: () => _save(context, b['name'] as String),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _save(BuildContext context, String bucketName) async {
    await db.insertTransaction(TransactionsCompanion(
      txCode: drift.Value(txCode),
      amount: drift.Value(amount),
      recipient: drift.Value(recipient),
      direction: drift.Value('out'),
      type: drift.Value('transfer'),
      bucketName: drift.Value(bucketName),
      balanceAfter: drift.Value(balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
    if (context.mounted) Navigator.pop(context);
  }
}

// ── Not mine sub-choice ──────────────────────────────────────────────
class _NotMineSubChoice extends StatelessWidget {
  final double amount;
  final String txCode;
  final String recipient;
  final double balance;

  const _NotMineSubChoice({
    required this.amount, required this.txCode,
    required this.recipient, required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      backLabel: 'Not mine · Ksh ${amount.toInt()}',
      child: Column(
        children: [
          _RootButton(
            icon: Icons.wallet,
            label: "I'm holding their money",
            color: Colors.blue,
            onTap: () => _showCustody(context),
          ),
          const SizedBox(height: 8),
          _RootButton(
            icon: Icons.undo,
            label: "I'll be paid back",
            color: Colors.blue,
            onTap: () => _showReimbursable(context),
          ),
        ],
      ),
    );
  }

  void _showCustody(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CustodyNote(
        amount: amount, txCode: txCode,
        recipient: recipient, balance: balance,
      ),
    );
  }

  void _showReimbursable(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ReimbursableNote(
        amount: amount, txCode: txCode,
        recipient: recipient, balance: balance,
      ),
    );
  }
}

// ── Custody note ─────────────────────────────────────────────────────
class _CustodyNote extends StatefulWidget {
  final double amount;
  final String txCode;
  final String recipient;
  final double balance;

  const _CustodyNote({
    required this.amount, required this.txCode,
    required this.recipient, required this.balance,
  });

  @override
  State<_CustodyNote> createState() => _CustodyNoteState();
}

class _CustodyNoteState extends State<_CustodyNote> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _CardShell(
        backLabel: "Holding their money · Ksh ${widget.amount.toInt()}",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What's this for?",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g. Fuel float, Westlands job',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            _SaveButton(label: 'Save', onTap: () => _save(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final label = _controller.text.trim().isEmpty
        ? 'Custody – ${DateTime.now().day}/${DateTime.now().month}'
        : _controller.text.trim();

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
    if (context.mounted) Navigator.pop(context);
  }
}

// ── Reimbursable note ────────────────────────────────────────────────
class _ReimbursableNote extends StatefulWidget {
  final double amount;
  final String txCode;
  final String recipient;
  final double balance;

  const _ReimbursableNote({
    required this.amount, required this.txCode,
    required this.recipient, required this.balance,
  });

  @override
  State<_ReimbursableNote> createState() => _ReimbursableNoteState();
}

class _ReimbursableNoteState extends State<_ReimbursableNote> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _CardShell(
        backLabel: "Pay me back · Ksh ${widget.amount.toInt()}",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Which job is this for?",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'e.g. Client X supplies',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            _SaveButton(label: 'Save', onTap: () => _save(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final label = _controller.text.trim().isEmpty
        ? 'Reimbursement – ${DateTime.now().day}/${DateTime.now().month}'
        : _controller.text.trim();

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
    if (context.mounted) Navigator.pop(context);
  }
}

// ── Expense picker ───────────────────────────────────────────────────
class _ExpensePicker extends StatefulWidget {
  final double amount;
  final String txCode;
  final String recipient;
  final double balance;

  const _ExpensePicker({
    required this.amount, required this.txCode,
    required this.recipient, required this.balance,
  });

  @override
  State<_ExpensePicker> createState() => _ExpensePickerState();
}

class _ExpensePickerState extends State<_ExpensePicker> {
  String? selected;

  static const categories = [
    'Food', 'Transport', 'Supplies', 'Bills', 'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      backLabel: 'True expense · Ksh ${widget.amount.toInt()}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((c) {
              final isSelected = selected == c;
              return ChoiceChip(
                label: Text(c),
                selected: isSelected,
                onSelected: (_) => setState(() => selected = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _SaveButton(
            label: 'Save',
            onTap: selected == null ? null : () => _save(context),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    await db.insertTransaction(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(widget.amount),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value('out'),
      type: drift.Value('expense'),
      category: drift.Value(selected!),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
    if (context.mounted) Navigator.pop(context);
  }
}

// ── Shared UI components ─────────────────────────────────────────────
class _CardShell extends StatelessWidget {
  final String backLabel;
  final Widget child;

  const _CardShell({required this.backLabel, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left, color: Colors.grey),
              ),
              const SizedBox(width: 4),
              Text(backLabel,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _RootButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RootButton({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _GridTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GridTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SaveButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
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