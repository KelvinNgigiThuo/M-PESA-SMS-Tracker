import 'package:flutter/material.dart';
import '../main.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart' as drift;

// ── Colour constants ──────────────────────────────────────────────────
const tagCardGreen = Color(0xFF1A3C34);
const tagCardGold = Color(0xFFC9A84C);
const tagCardWhite = Colors.white;

class TagCard extends StatefulWidget {
  final double amount;
  final String recipient;
  final String direction;
  final String txCode;
  final double balance;

  const TagCard({
    super.key,
    required this.amount,
    required this.recipient,
    required this.direction,
    required this.txCode,
    required this.balance,
  });

  @override
  State<TagCard> createState() => _TagCardState();
}

class _TagCardState extends State<TagCard> {
  String _screen = 'root';
  String? _selectedCategory;
  final _noteController = TextEditingController();
  List<Transaction> _receivables = [];
  bool _loadingReceivables = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: tagCardGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: tagCardGold.withOpacity(0.25), width: 0.5),
      ),
      padding: EdgeInsets.fromLTRB(
        16, 12, 16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: _showSuccess
            ? _buildSuccessState()
            : _buildNormalState(),
      ),
    );
  }

  Widget _buildNormalState() {
    return Column(
      key: const ValueKey('normal'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            color: tagCardWhite.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 14),
        _buildScreen(),
      ],
    );
  }

  Widget _buildSuccessState() {
    return SizedBox(
      key: const ValueKey('success'),
      width: double.infinity,
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tagCardGold.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: tagCardGold, width: 1.5),
            ),
            child: const Icon(Icons.check,
                color: tagCardGold, size: 26),
          ),
          const SizedBox(height: 12),
          const Text(
            'Saved',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tagCardWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case 'root':             return _buildRoot();
      case 'bucket':           return _buildBucketPicker();
      case 'not_mine':         return _buildNotMine();
      case 'custody':          return _buildCustodyNote();
      case 'reimbursable':     return _buildReimbursableNote();
      case 'expense':          return _buildExpense();
      case 'inflow_not_mine':  return _buildInflowNotMine();
      case 'custody_receive':  return _buildCustodyReceive();
      case 'receivable_match': return _buildReceivableMatch();
      default:                 return _buildRoot();
    }
  }

  Widget _header(String label, {String? backScreen}) {
    return Row(
      children: [
        if (backScreen != null)
          GestureDetector(
            onTap: () => setState(() => _screen = backScreen),
            child: Icon(Icons.chevron_left,
                color: tagCardWhite.withOpacity(0.5), size: 20),
          ),
        if (backScreen != null) const SizedBox(width: 4),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: tagCardWhite.withOpacity(0.5))),
        ),
        GestureDetector(
          onTap: () => _saveUntagged(),
          child: Icon(Icons.close,
              color: tagCardWhite.withOpacity(0.4), size: 18),
        ),
      ],
    );
  }

  Widget _amountRow(String subLabel) {
    final amtStr = widget.amount % 1 == 0
        ? 'Ksh ${widget.amount.toInt()}'
        : 'Ksh ${widget.amount.toStringAsFixed(2)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(amtStr,
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: tagCardGold,
                letterSpacing: -0.5)),
        Text(subLabel,
            style: TextStyle(
                fontSize: 12,
                color: tagCardWhite.withOpacity(0.45))),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _flowRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool last = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(
                  bottom: BorderSide(
                      color: tagCardWhite.withOpacity(0.08),
                      width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: iconColor.withOpacity(0.3), width: 0.5),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: tagCardWhite)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: tagCardWhite.withOpacity(0.4))),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: tagCardWhite.withOpacity(0.25), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRoot() {
    final isOut = widget.direction == 'out';
    final dirLabel = isOut
        ? 'to ${widget.recipient}'
        : 'from ${widget.recipient}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _amountRow(dirLabel)),
            GestureDetector(
              onTap: () => _saveUntagged(),
              child: Icon(Icons.close,
                  color: tagCardWhite.withOpacity(0.4), size: 20),
            ),
          ],
        ),
        if (isOut) ...[
          _flowRow(
            icon: Icons.account_balance_outlined,
            iconColor: tagCardGold,
            iconBg: tagCardGold.withOpacity(0.12),
            title: 'My account',
            subtitle: 'Transfer to a bucket',
            onTap: () => setState(() => _screen = 'bucket'),
          ),
          _flowRow(
            icon: Icons.swap_horiz,
            iconColor: const Color(0xFF4a9eff),
            iconBg: const Color(0xFF4a9eff).withOpacity(0.12),
            title: 'Not mine',
            subtitle: 'Custody or reimbursable',
            onTap: () => setState(() => _screen = 'not_mine'),
          ),
          _flowRow(
            icon: Icons.receipt_outlined,
            iconColor: const Color(0xFFe87070),
            iconBg: const Color(0xFFe87070).withOpacity(0.12),
            title: 'True expense',
            subtitle: 'From my own pocket',
            onTap: () => setState(() => _screen = 'expense'),
            last: true,
          ),
        ] else ...[
          _flowRow(
            icon: Icons.account_balance_outlined,
            iconColor: tagCardGold,
            iconBg: tagCardGold.withOpacity(0.12),
            title: 'From my account',
            subtitle: 'Transfer from a bucket',
            onTap: () => setState(() => _screen = 'bucket'),
          ),
          _flowRow(
            icon: Icons.swap_horiz,
            iconColor: const Color(0xFF4a9eff),
            iconBg: const Color(0xFF4a9eff).withOpacity(0.12),
            title: 'Not mine',
            subtitle: 'Custody or payment received',
            onTap: () => setState(() => _screen = 'inflow_not_mine'),
          ),
          _flowRow(
            icon: Icons.trending_up,
            iconColor: const Color(0xFF5ec47a),
            iconBg: const Color(0xFF5ec47a).withOpacity(0.12),
            title: 'True income',
            subtitle: 'Into my own pocket',
            onTap: () => _saveIncome(),
            last: true,
          ),
        ],
      ],
    );
  }

  Widget _buildBucketPicker() {
    final isOut = widget.direction == 'out';
    final label = isOut
        ? 'My account · Ksh ${widget.amount.toInt()}'
        : 'From my account · Ksh ${widget.amount.toInt()}';

    final buckets = [
      {'name': 'Other M-Pesa',    'icon': Icons.phone_android},
      {'name': 'NCBA',            'icon': Icons.account_balance},
      {'name': 'KCB Bank',        'icon': Icons.account_balance},
      {'name': 'KCB M-Pesa',      'icon': Icons.account_balance_wallet},
      {'name': 'M-Shwari',        'icon': Icons.savings},
      {'name': 'M-Shwari Lock',   'icon': Icons.lock_outline},
      {'name': 'KCB M-Pesa Lock', 'icon': Icons.lock_outline},
      {'name': 'Etica',           'icon': Icons.trending_up},
      {'name': 'Company',         'icon': Icons.business_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(label, backScreen: 'root'),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.4,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ...buckets.map((b) => GestureDetector(
              onTap: () => _saveTransfer(b['name'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: tagCardGold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: tagCardGold.withOpacity(0.2),
                      width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(b['icon'] as IconData,
                        color: tagCardGold, size: 15),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(b['name'] as String,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: tagCardWhite),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            )),
            GestureDetector(
              onTap: () => _showAddBucket(context),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: tagCardGold.withOpacity(0.3),
                      width: 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add,
                        color: tagCardGold.withOpacity(0.7),
                        size: 15),
                    const SizedBox(width: 6),
                    Text('Add new',
                        style: TextStyle(
                            fontSize: 11,
                            color: tagCardGold.withOpacity(0.7))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddBucket(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: tagCardGreen,
        title: const Text('Add account',
            style: TextStyle(fontSize: 15, color: tagCardWhite)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: tagCardWhite),
          decoration: InputDecoration(
            hintText: 'e.g. CIC Money Market',
            hintStyle:
                TextStyle(color: tagCardWhite.withOpacity(0.4)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: tagCardGold.withOpacity(0.5))),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: tagCardGold)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(
                    color: tagCardWhite.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                _saveTransfer(name);
              }
            },
            child: const Text('Save',
                style: TextStyle(color: tagCardGold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotMine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('Not mine · Ksh ${widget.amount.toInt()}',
            backScreen: 'root'),
        const SizedBox(height: 14),
        _flowRow(
          icon: Icons.wallet_outlined,
          iconColor: const Color(0xFF4a9eff),
          iconBg: const Color(0xFF4a9eff).withOpacity(0.12),
          title: "I'm holding their money",
          subtitle: 'Spending from a custody pool',
          onTap: () => setState(() {
            _noteController.clear();
            _screen = 'custody';
          }),
        ),
        _flowRow(
          icon: Icons.undo,
          iconColor: tagCardGold,
          iconBg: tagCardGold.withOpacity(0.12),
          title: "I'll be paid back",
          subtitle: 'Creates a reimbursable record',
          onTap: () => setState(() {
            _noteController.clear();
            _screen = 'reimbursable';
          }),
          last: true,
        ),
      ],
    );
  }

  Widget _buildInflowNotMine() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('Not mine · Ksh ${widget.amount.toInt()}',
            backScreen: 'root'),
        const SizedBox(height: 14),
        _flowRow(
          icon: Icons.add_circle_outline,
          iconColor: const Color(0xFF4a9eff),
          iconBg: const Color(0xFF4a9eff).withOpacity(0.12),
          title: "Adding to a pool I'm holding",
          subtitle: 'Tops up a custody pool',
          onTap: () => setState(() {
            _noteController.clear();
            _screen = 'custody_receive';
          }),
        ),
        _flowRow(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF5ec47a),
          iconBg: const Color(0xFF5ec47a).withOpacity(0.12),
          title: "Clears what I'm owed",
          subtitle: 'Match to an open receivable',
          onTap: () => _loadReceivables(),
          last: true,
        ),
      ],
    );
  }

  Widget _noteField(String hint) {
    return TextField(
      controller: _noteController,
      autofocus: true,
      style: const TextStyle(color: tagCardWhite, fontSize: 14),
      cursorColor: tagCardGold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: tagCardWhite.withOpacity(0.3)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: tagCardWhite.withOpacity(0.15))),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: tagCardGold)),
      ),
    );
  }

  Widget _buildCustodyNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
            "Holding their money · Ksh ${widget.amount.toInt()}",
            backScreen: 'not_mine'),
        const SizedBox(height: 16),
        Text("What's this for?",
            style: TextStyle(
                fontSize: 11,
                color: tagCardWhite.withOpacity(0.5))),
        const SizedBox(height: 8),
        _noteField('e.g. Fuel float, Westlands job'),
        const SizedBox(height: 20),
        _saveBtn('Save', () => _saveCustodySpend()),
      ],
    );
  }

  Widget _buildReimbursableNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header("Pay me back · Ksh ${widget.amount.toInt()}",
            backScreen: 'not_mine'),
        const SizedBox(height: 16),
        Text("Which job is this for?",
            style: TextStyle(
                fontSize: 11,
                color: tagCardWhite.withOpacity(0.5))),
        const SizedBox(height: 8),
        _noteField('e.g. Client X supplies'),
        const SizedBox(height: 20),
        _saveBtn('Save', () => _saveReimbursable()),
      ],
    );
  }

  Widget _buildCustodyReceive() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header("Adding to pool · Ksh ${widget.amount.toInt()}",
            backScreen: 'inflow_not_mine'),
        const SizedBox(height: 16),
        Text("What pool is this for?",
            style: TextStyle(
                fontSize: 11,
                color: tagCardWhite.withOpacity(0.5))),
        const SizedBox(height: 8),
        _noteField('e.g. Fuel float, Westlands job'),
        const SizedBox(height: 20),
        _saveBtn('Save', () => _saveCustodyReceive()),
      ],
    );
  }

  Widget _buildExpense() {
    const categories = [
      'Food', 'Transport', 'Supplies', 'Bills', 'Airtime', 'Other'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header('True expense · Ksh ${widget.amount.toInt()}',
            backScreen: 'root'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((c) {
            final selected = _selectedCategory == c;
            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedCategory = c),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFe87070).withOpacity(0.2)
                      : tagCardWhite.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFe87070).withOpacity(0.6)
                        : tagCardWhite.withOpacity(0.12),
                    width: 0.5,
                  ),
                ),
                child: Text(c,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? const Color(0xFFe87070)
                            : tagCardWhite.withOpacity(0.8))),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _saveBtn(
            'Save',
            _selectedCategory == null
                ? null
                : () => _saveExpense()),
      ],
    );
  }

  Widget _buildReceivableMatch() {
    if (_loadingReceivables) {
      return Column(children: [
        _header(
            "Clears what I'm owed · Ksh ${widget.amount.toInt()}",
            backScreen: 'inflow_not_mine'),
        const SizedBox(height: 24),
        const Center(
            child:
                CircularProgressIndicator(color: tagCardGold)),
        const SizedBox(height: 24),
      ]);
    }
    if (_receivables.isEmpty) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(
                "Clears what I'm owed · Ksh ${widget.amount.toInt()}",
                backScreen: 'inflow_not_mine'),
            const SizedBox(height: 16),
            Text(
              'No open receivables found.\nTag as True income instead.',
              style: TextStyle(
                  fontSize: 13,
                  color: tagCardWhite.withOpacity(0.5)),
            ),
            const SizedBox(height: 16),
            _saveBtn('Save as income', () => _saveIncome()),
          ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _header(
            "Clears what I'm owed · Ksh ${widget.amount.toInt()}",
            backScreen: 'inflow_not_mine'),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _receivables.length,
            separatorBuilder: (_, __) => Divider(
                color: tagCardWhite.withOpacity(0.08),
                height: 1),
            itemBuilder: (_, i) {
              final r = _receivables[i];
              final label = r.receivableLabel ?? 'Unnamed';
              final owed = r.amount;
              final incoming = widget.amount;
              final cleared =
                  incoming >= owed ? owed : incoming;
              final income =
                  incoming > owed ? incoming - owed : 0.0;
              return GestureDetector(
                onTap: () => _saveReceivableMatch(r),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10),
                  child: Row(children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5ec47a)
                            .withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(9),
                        border: Border.all(
                            color: const Color(0xFF5ec47a)
                                .withOpacity(0.3),
                            width: 0.5),
                      ),
                      child: const Icon(
                          Icons.receipt_long_outlined,
                          color: Color(0xFF5ec47a),
                          size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: tagCardWhite)),
                          Text(
                            income > 0
                                ? 'Clears Ksh ${cleared.toInt()} · Ksh ${income.toInt()} income'
                                : 'Clears Ksh ${cleared.toInt()} of Ksh ${owed.toInt()} owed',
                            style: TextStyle(
                                fontSize: 11,
                                color: tagCardWhite
                                    .withOpacity(0.4)),
                          ),
                        ])),
                    Icon(Icons.chevron_right,
                        color: tagCardWhite.withOpacity(0.25),
                        size: 16),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _saveBtn(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: onTap == null
              ? tagCardWhite.withOpacity(0.08)
              : tagCardGold,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: onTap == null
                ? tagCardWhite.withOpacity(0.3)
                : tagCardGreen,
          ),
        ),
      ),
    );
  }

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

  Future<void> _completeAndClose() async {
    if (!mounted) return;
    setState(() => _showSuccess = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveTransfer(String bucketName) async {
    await _upsert(TransactionsCompanion(
      txCode: drift.Value(widget.txCode),
      amount: drift.Value(widget.amount),
      recipient: drift.Value(widget.recipient),
      direction: drift.Value(widget.direction),
      type: drift.Value(widget.direction == 'out'
          ? 'transfer'
          : 'transfer_in'),
      bucketName: drift.Value(bucketName),
      balanceAfter: drift.Value(widget.balance),
      rawSms: drift.Value(''),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
    await _completeAndClose();
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
    await _completeAndClose();
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
    await _completeAndClose();
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
    await _completeAndClose();
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
    await _completeAndClose();
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
    await _completeAndClose();
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
    await _completeAndClose();
  }

  Future<void> _saveUntagged() async {
    final existing = await (db.select(db.transactions)
      ..where((t) =>
          t.txCode.equals(widget.txCode) &
          t.isTagged.equals(false)))
        .getSingleOrNull();

    if (existing != null) {
      if (mounted) Navigator.pop(context);
      return;
    }

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
}