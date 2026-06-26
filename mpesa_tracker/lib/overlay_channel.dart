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
  // Auto-update secondary account balance if present (M-Shwari, KCB M-Pesa)
  final secondaryBalance = (data['secondaryBalance'] as num?)?.toDouble() ?? 0.0;
  final secondaryAccount = data['secondaryAccount'] as String? ?? '';

  if (secondaryBalance > 0 && secondaryAccount.isNotEmpty) {
    final account = await db.getAccountByName(secondaryAccount);
    if (account != null) {
      await db.setManualBalance(account.id, secondaryBalance);
    }
  }

  // Auto-save transaction fee silently before showing card
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
  String _screen = 'root';
  String? _selectedCategory;
  final _noteController = TextEditingController();

  // For receivable matching
  List<Transaction> _receivables = [];
  bool _loadingReceivables = false;

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
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          _buildScreen(),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case 'root':              return _buildRoot();
      case 'bucket':            return _buildBucketPicker();
      // Outflow branches
      case 'not_mine':          return _buildNotMine();
      case 'custody':           return _buildCustodyNote();
      case 'reimbursable':      return _buildReimbursableNote();
      case 'expense':           return _buildExpense();
      // Inflow branches
      case 'inflow_not_mine':   return _buildInflowNotMine();
      case 'custody_receive':   return _buildCustodyReceive();
      case 'receivable_match':  return _buildReceivableMatch();
      default:                  return _buildRoot();
    }
  }

  // ── Header ────────────────────────────────────────────────────────
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
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    final isOut = widget.direction == 'out';
    final amountLabel = 'Ksh ${widget.amount.toInt()}';
    final subLabel = '${isOut ? "to" : "from"} ${widget.recipient}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(amountLabel,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: () => _saveUntagged(),
              child: const Icon(Icons.close, color: Colors.grey),
            ),
          ],
        ),
        Text(subLabel,
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 20),
        if (isOut) ...[
          // ── Outflow root ──
          _rootBtn(Icons.account_balance, 'My account', Colors.blue,
              () => setState(() => _screen = 'bucket')),
          const SizedBox(height: 8),
          _rootBtn(Icons.block, 'Not mine', Colors.blue,
              () => setState(() => _screen = 'not_mine')),
          const SizedBox(height: 8),
          _rootBtn(Icons.receipt_long, 'True expense', Colors.red,
              () => setState(() => _screen = 'expense')),
        ] else ...[
          // ── Inflow root ──
          _rootBtn(Icons.account_balance, 'From my account', Colors.blue,
              () => setState(() => _screen = 'bucket')),
          const SizedBox(height: 8),
          _rootBtn(Icons.swap_horiz, 'Not mine', Colors.blue,
              () => setState(() => _screen = 'inflow_not_mine')),
          const SizedBox(height: 8),
          _rootBtn(Icons.trending_up, 'True income', Colors.green,
              () => _saveIncome()),
        ],
      ],
    );
  }

  // ── Screen: bucket picker (shared outflow + inflow) ───────────────
  Widget _buildBucketPicker() {
    final isOut = widget.direction == 'out';
    final label = isOut
        ? 'My account · Ksh ${widget.amount.toInt()}'
        : 'From my account · Ksh ${widget.amount.toInt()}';

    final buckets = [
      {'name': 'Other M-Pesa', 'icon': Icons.phone_android},
      {'name': 'NCBA', 'icon': Icons.account_balance},
      {'name': 'KCB Bank', 'icon': Icons.account_balance},
      {'name': 'KCB M-Pesa', 'icon': Icons.account_balance_wallet},
      {'name': 'M-Shwari', 'icon': Icons.savings},
      {'name': 'M-Shwari Lock', 'icon': Icons.lock},
      {'name': 'KCB M-Pesa Lock', 'icon': Icons.lock},
      {'name': 'Etica', 'icon': Icons.trending_up},
      {'name': 'Company', 'icon': Icons.business},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(label, backScreen: 'root'),
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
                    Icon(b['icon'] as IconData,
                        color: Colors.blue, size: 20),
                    const SizedBox(height: 4),
                    Text(b['name'] as String,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          }).toList()
            ..add(
              GestureDetector(
                onTap: () => _showAddBucket(context),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.blue[200]!, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add, color: Colors.blue, size: 20),
                      SizedBox(height: 4),
                      Text('Add new',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue)),
                    ],
                  ),
                ),
              ),
            ),
        ),
      ],
    );
  }

  void _showAddBucket(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add account',
            style: TextStyle(fontSize: 15)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. CIC Money Market',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                _saveTransfer(name);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Screen: outflow not-mine sub-choice ───────────────────────────
  Widget _buildNotMine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Not mine · Ksh ${widget.amount.toInt()}',
            backScreen: 'root'),
        const SizedBox(height: 16),
        _rootBtn(Icons.wallet, "I'm holding their money", Colors.blue,
            () => setState(() {
                  _noteController.clear();
                  _screen = 'custody';
                })),
        const SizedBox(height: 8),
        _rootBtn(Icons.undo, "I'll be paid back", Colors.blue,
            () => setState(() {
                  _noteController.clear();
                  _screen = 'reimbursable';
                })),
      ],
    );
  }

  // ── Screen: outflow custody note ──────────────────────────────────
  Widget _buildCustodyNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
            "Holding their money · Ksh ${widget.amount.toInt()}",
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
        _saveBtn('Save', () => _saveCustodySpend()),
      ],
    );
  }

  // ── Screen: outflow reimbursable note ─────────────────────────────
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

  // ── Screen: outflow expense category ─────────────────────────────
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
              onSelected: (_) =>
                  setState(() => _selectedCategory = c),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _saveBtn('Save',
            _selectedCategory == null ? null : () => _saveExpense()),
      ],
    );
  }

  // ── Screen: inflow not-mine sub-choice ────────────────────────────
  Widget _buildInflowNotMine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader('Not mine · Ksh ${widget.amount.toInt()}',
            backScreen: 'root'),
        const SizedBox(height: 16),
        _rootBtn(Icons.add_circle_outline, "Adding to a pool I'm holding",
            Colors.blue, () => setState(() {
                  _noteController.clear();
                  _screen = 'custody_receive';
                })),
        const SizedBox(height: 8),
        _rootBtn(Icons.check_circle_outline,
            "Clears what I'm owed", Colors.blue,
            () => _loadReceivables()),
      ],
    );
  }

  // ── Screen: inflow custody receive ───────────────────────────────
  Widget _buildCustodyReceive() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(
            "Adding to pool · Ksh ${widget.amount.toInt()}",
            backScreen: 'inflow_not_mine'),
        const SizedBox(height: 16),
        const Text("What pool is this for?",
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
        _saveBtn('Save', () => _saveCustodyReceive()),
      ],
    );
  }

  // ── Screen: receivable match ──────────────────────────────────────
  Widget _buildReceivableMatch() {
    if (_loadingReceivables) {
      return Column(
        children: [
          _buildHeader(
              "Clears what I'm owed · Ksh ${widget.amount.toInt()}",
              backScreen: 'inflow_not_mine'),
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 24),
        ],
      );
    }

    if (_receivables.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
              "Clears what I'm owed · Ksh ${widget.amount.toInt()}",
              backScreen: 'inflow_not_mine'),
          const SizedBox(height: 16),
          const Text(
            'No open receivables found.\nTag this as True income instead.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _saveBtn('Save as income', () => _saveIncome()),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(
            "Clears what I'm owed · Ksh ${widget.amount.toInt()}",
            backScreen: 'inflow_not_mine'),
        const SizedBox(height: 8),
        const Text('Which receivable does this clear?',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 10),
        // Limit height so card doesn't overflow screen
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _receivables.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) {
              final r = _receivables[i];
              final label = r.receivableLabel ?? 'Unnamed';
              final owed = r.amount;
              final incoming = widget.amount;
              // Calculate what will happen on tap
              final cleared = incoming >= owed ? owed : incoming;
              final income = incoming > owed ? incoming - owed : 0.0;

              return GestureDetector(
                onTap: () => _saveReceivableMatch(r),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long,
                          color: Colors.blue, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            Text(
                              income > 0
                                  ? 'Clears Ksh ${cleared.toInt()} · Ksh ${income.toInt()} income'
                                  : 'Clears Ksh ${cleared.toInt()} of Ksh ${owed.toInt()} owed',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.grey, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Load receivables then switch screen ───────────────────────────
  Future<void> _loadReceivables() async {
    setState(() {
      _loadingReceivables = true;
      _screen = 'receivable_match';
    });
    final results = await db.getOpenReceivables();
    setState(() {
      _receivables = results;
      _loadingReceivables = false;
    });
  }

  // ── Save methods ──────────────────────────────────────────────────
 // ── Upsert — updates existing untagged record or inserts new ─────
  Future<void> _upsert(TransactionsCompanion companion) async {
    final existing = await (db.select(db.transactions)
      ..where((t) =>
          t.txCode.equals(widget.txCode) &
          t.isTagged.equals(false)))
    .getSingleOrNull();

    if (existing != null) {
      await db.updateTaggedTransaction(
        existing.id,
        type: companion.type.value ?? '',
        category: companion.category.value,
        bucketName: companion.bucketName.value,
        poolLabel: companion.poolLabel.value,
        receivableLabel: companion.receivableLabel.value,
      );
    } else {
      await db.insertTransaction(companion);
    }
  }

  Future<void> _saveTransfer(String bucketName) async {
    await _upsert(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(widget.amount),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value(widget.direction),
      type: drift.Value(
          widget.direction == 'out' ? 'transfer' : 'transfer_in'),
      bucketName: drift.Value(bucketName),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveCustodySpend() async {
    final label = _noteController.text.trim().isEmpty
        ? 'Custody – ${DateTime.now().day}/${DateTime.now().month}'
        : _noteController.text.trim();
    await _upsert(TransactionsCompanion(
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
    await _upsert(TransactionsCompanion(
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
    await _upsert(TransactionsCompanion(
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

  Future<void> _saveCustodyReceive() async {
    final label = _noteController.text.trim().isEmpty
        ? 'Custody – ${DateTime.now().day}/${DateTime.now().month}'
        : _noteController.text.trim();
    await _upsert(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(widget.amount),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value('in'),
      type: drift.Value('custody_receive'),
      poolLabel: drift.Value(label),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveReceivableMatch(Transaction receivable) async {
    final owed = receivable.amount;
    final incoming = widget.amount;

    await _upsert(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(incoming >= owed ? owed : incoming),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value('in'),
      type: drift.Value('receivable_clear'),
      receivableLabel: drift.Value(receivable.receivableLabel),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));

    if (incoming > owed) {
      final excess = incoming - owed;
      await db.insertTransaction(TransactionsCompanion(
        txCode: drift.Value('${widget.txCode}_income'),
        amount: drift.Value(excess),
        recipient: drift.Value(widget.recipient),
        direction: drift.Value('in'),
        type: drift.Value('income'),
        receivableLabel: drift.Value(
            '${receivable.receivableLabel} – income split'),
        balanceAfter: drift.Value(widget.balance),
        rawSms: drift.Value('auto-split from receivable'),
        createdAt: drift.Value(DateTime.now()),
        isTagged: drift.Value(true),
      ));
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveIncome() async {
    await _upsert(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(widget.amount),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value('in'),
      type: drift.Value('income'),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveUntagged() async {
    await _upsert(TransactionsCompanion(
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

  // ── UI helpers ────────────────────────────────────────────────────
  Widget _rootBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ),
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