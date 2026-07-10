import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';
import 'tag_card_outflow.dart';
import 'tag_card_inflow.dart';
import 'package:drift/drift.dart' as drift;

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
  State<TagCard> createState() => TagCardState();
}

class TagCardState extends State<TagCard> {
  String screen = 'root';
  String? selectedCategory;
  final noteController = TextEditingController();
  List<Transaction> receivables = [];
  bool loadingReceivables = false;
  bool showSuccess = false;

  @override
  void dispose() {
    noteController.dispose();
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
        child: showSuccess
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
    final isOut = widget.direction == 'out';
    switch (screen) {
      case 'root':
        return isOut
            ? buildOutflowRoot(this)
            : buildInflowRoot(this);
      case 'bucket':
        return buildBucketPicker(this);
      case 'not_mine':
        return buildOutflowNotMine(this);
      case 'custody':
        return buildCustodyNote(this);
      case 'reimbursable':
        return buildReimbursableNote(this);
      case 'expense':
        return buildExpense(this);
      case 'inflow_not_mine':
        return buildInflowNotMine(this);
      case 'custody_receive':
        return buildCustodyReceive(this);
      case 'receivable_match':
        return buildReceivableMatch(this);
      default:
        return isOut
            ? buildOutflowRoot(this)
            : buildInflowRoot(this);
    }
  }

  // ── Shared UI helpers ─────────────────────────────────────────
  Widget buildHeader(String label, {String? backScreen}) {
    return Row(
      children: [
        if (backScreen != null)
          GestureDetector(
            onTap: () => setState(() => screen = backScreen),
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
          onTap: () => saveUntagged(),
          child: Icon(Icons.close,
              color: tagCardWhite.withOpacity(0.4), size: 18),
        ),
      ],
    );
  }

  Widget buildAmountRow(String subLabel) {
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

  Widget buildFlowRow({
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
                    color: iconColor.withOpacity(0.3),
                    width: 0.5),
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

  Widget buildNoteField(String hint) {
    return TextField(
      controller: noteController,
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

  Widget buildSaveBtn(String label, VoidCallback? onTap) {
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

  // ── Shared save helpers ───────────────────────────────────────
  Future<void> upsert(TransactionsCompanion companion) async {
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

  Future<void> completeAndClose() async {
    if (!mounted) return;
    setState(() => showSuccess = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.pop(context);
  }

  Future<void> saveUntagged() async {
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