import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../main.dart';
import 'tag_card.dart';

// ── Root screen ───────────────────────────────────────────────────────
Widget buildOutflowRoot(TagCardState s) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: s.buildAmountRow('to ${s.widget.recipient}')),
          GestureDetector(
            onTap: () => s.saveUntagged(),
            child: Icon(Icons.close,
                color: tagCardWhite.withOpacity(0.4), size: 20),
          ),
        ],
      ),
      s.buildFlowRow(
        icon: Icons.account_balance_outlined,
        iconColor: tagCardGold,
        iconBg: tagCardGold.withOpacity(0.12),
        title: 'My account',
        subtitle: 'Transfer to a bucket',
        onTap: () => s.setState(() => s.screen = 'bucket'),
      ),
      s.buildFlowRow(
        icon: Icons.swap_horiz,
        iconColor: const Color(0xFF4a9eff),
        iconBg: const Color(0xFF4a9eff).withOpacity(0.12),
        title: 'Not mine',
        subtitle: 'Custody or reimbursable',
        onTap: () => s.setState(() => s.screen = 'not_mine'),
      ),
      s.buildFlowRow(
        icon: Icons.receipt_outlined,
        iconColor: const Color(0xFFe87070),
        iconBg: const Color(0xFFe87070).withOpacity(0.12),
        title: 'True expense',
        subtitle: 'From my own pocket',
        onTap: () => s.setState(() => s.screen = 'expense'),
        last: true,
      ),
    ],
  );
}

// ── Bucket picker (shared outflow + inflow) ───────────────────────────
Widget buildBucketPicker(TagCardState s) {
  final isOut = s.widget.direction == 'out';
  final label = isOut
      ? 'My account · Ksh ${s.widget.amount.toInt()}'
      : 'From my account · Ksh ${s.widget.amount.toInt()}';

  if (s.loadingAccounts) {
    return Column(
      children: [
        s.buildHeader(label, backScreen: 'root'),
        const SizedBox(height: 24),
        const Center(
            child: CircularProgressIndicator(color: tagCardGold)),
        const SizedBox(height: 24),
      ],
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      s.buildHeader(label, backScreen: 'root'),
      const SizedBox(height: 14),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.4,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ...s.bucketAccounts.map((a) => GestureDetector(
            onTap: () => saveTransfer(s, a.name),
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
                  Icon(_zoneIcon(a.zone),
                      color: tagCardGold, size: 15),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(a.name,
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
            onTap: () => _showAddBucket(s),
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

IconData _zoneIcon(int zone) {
  switch (zone) {
    case 1: return Icons.phone_android;
    case 2: return Icons.savings;
    case 3: return Icons.account_balance;
    case 4: return Icons.trending_up;
    default: return Icons.wallet;
  }
}

void _showAddBucket(TagCardState s) {
  final controller = TextEditingController();
  showDialog(
    context: s.context,
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
          onPressed: () => Navigator.pop(s.context),
          child: Text('Cancel',
              style: TextStyle(
                  color: tagCardWhite.withOpacity(0.5))),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(s.context);
              saveTransfer(s, name);
            }
          },
          child: const Text('Save',
              style: TextStyle(color: tagCardGold)),
        ),
      ],
    ),
  );
}

// ── Not mine sub-choice ───────────────────────────────────────────────
Widget buildOutflowNotMine(TagCardState s) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      s.buildHeader(
          'Not mine · Ksh ${s.widget.amount.toInt()}',
          backScreen: 'root'),
      const SizedBox(height: 14),
      s.buildFlowRow(
        icon: Icons.wallet_outlined,
        iconColor: const Color(0xFF4a9eff),
        iconBg: const Color(0xFF4a9eff).withOpacity(0.12),
        title: "I'm holding their money",
        subtitle: 'Spending from a custody pool',
        onTap: () => s.setState(() {
          s.noteController.clear();
          s.screen = 'custody';
        }),
      ),
      s.buildFlowRow(
        icon: Icons.undo,
        iconColor: tagCardGold,
        iconBg: tagCardGold.withOpacity(0.12),
        title: "I'll be paid back",
        subtitle: 'Creates a reimbursable record',
        onTap: () => s.setState(() {
          s.noteController.clear();
          s.screen = 'reimbursable';
        }),
        last: true,
      ),
    ],
  );
}

// ── Custody note ──────────────────────────────────────────────────────
Widget buildCustodyNote(TagCardState s) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      s.buildHeader(
          "Holding their money · Ksh ${s.widget.amount.toInt()}",
          backScreen: 'not_mine'),
      const SizedBox(height: 16),
      Text("What's this for?",
          style: TextStyle(
              fontSize: 11,
              color: tagCardWhite.withOpacity(0.5))),
      const SizedBox(height: 8),
      s.buildNoteField('e.g. Fuel float, Westlands job'),
      const SizedBox(height: 20),
      s.buildSaveBtn('Save', () => saveCustodySpend(s)),
    ],
  );
}

// ── Reimbursable note ─────────────────────────────────────────────────
Widget buildReimbursableNote(TagCardState s) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      s.buildHeader(
          "Pay me back · Ksh ${s.widget.amount.toInt()}",
          backScreen: 'not_mine'),
      const SizedBox(height: 16),
      Text("Which job is this for?",
          style: TextStyle(
              fontSize: 11,
              color: tagCardWhite.withOpacity(0.5))),
      const SizedBox(height: 8),
      s.buildNoteField('e.g. Client X supplies'),
      const SizedBox(height: 20),
      s.buildSaveBtn('Save', () => saveReimbursable(s)),
    ],
  );
}

// ── Expense picker ────────────────────────────────────────────────────
Widget buildExpense(TagCardState s) {
  const categories = [
    'Food', 'Transport', 'Supplies', 'Bills', 'Airtime', 'Other'
  ];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      s.buildHeader(
          'True expense · Ksh ${s.widget.amount.toInt()}',
          backScreen: 'root'),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: categories.map((c) {
          final selected = s.selectedCategory == c;
          return GestureDetector(
            onTap: () =>
                s.setState(() => s.selectedCategory = c),
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
      s.buildSaveBtn(
          'Save',
          s.selectedCategory == null
              ? null
              : () => saveExpense(s)),
    ],
  );
}

// ── Save methods ──────────────────────────────────────────────────────
Future<void> saveTransfer(TagCardState s, String bucketName) async {
  await s.upsert(TransactionsCompanion(
    txCode: drift.Value(s.widget.txCode),
    amount: drift.Value(s.widget.amount),
    recipient: drift.Value(s.widget.recipient),
    direction: drift.Value(s.widget.direction),
    type: drift.Value(s.widget.direction == 'out'
        ? 'transfer'
        : 'transfer_in'),
    bucketName: drift.Value(bucketName),
    balanceAfter: drift.Value(s.widget.balance),
    rawSms: drift.Value(''),
    createdAt: drift.Value(DateTime.now()),
    isTagged: drift.Value(true),
  ));
  await s.completeAndClose();
}

Future<void> saveCustodySpend(TagCardState s) async {
  final label = s.noteController.text.trim().isEmpty
      ? 'Custody – ${DateTime.now().day}/${DateTime.now().month}'
      : s.noteController.text.trim();
  await s.upsert(TransactionsCompanion(
    txCode: drift.Value(s.widget.txCode),
    amount: drift.Value(s.widget.amount),
    recipient: drift.Value(s.widget.recipient),
    direction: drift.Value('out'),
    type: drift.Value('custody_spend'),
    poolLabel: drift.Value(label),
    balanceAfter: drift.Value(s.widget.balance),
    rawSms: drift.Value(''),
    createdAt: drift.Value(DateTime.now()),
    isTagged: drift.Value(true),
  ));
  await s.completeAndClose();
}

Future<void> saveReimbursable(TagCardState s) async {
  final label = s.noteController.text.trim().isEmpty
      ? 'Reimbursement – ${DateTime.now().day}/${DateTime.now().month}'
      : s.noteController.text.trim();
  await s.upsert(TransactionsCompanion(
    txCode: drift.Value(s.widget.txCode),
    amount: drift.Value(s.widget.amount),
    recipient: drift.Value(s.widget.recipient),
    direction: drift.Value('out'),
    type: drift.Value('receivable_create'),
    receivableLabel: drift.Value(label),
    balanceAfter: drift.Value(s.widget.balance),
    rawSms: drift.Value(''),
    createdAt: drift.Value(DateTime.now()),
    isTagged: drift.Value(true),
  ));
  await s.completeAndClose();
}

Future<void> saveExpense(TagCardState s) async {
  await s.upsert(TransactionsCompanion(
    txCode: drift.Value(s.widget.txCode),
    amount: drift.Value(s.widget.amount),
    recipient: drift.Value(s.widget.recipient),
    direction: drift.Value('out'),
    type: drift.Value('expense'),
    category: drift.Value(s.selectedCategory!),
    balanceAfter: drift.Value(s.widget.balance),
    rawSms: drift.Value(''),
    createdAt: drift.Value(DateTime.now()),
    isTagged: drift.Value(true),
  ));
  await s.completeAndClose();
}