import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../main.dart';
import 'tag_card.dart';

// ── Root screen ───────────────────────────────────────────────────────
Widget buildInflowRoot(TagCardState s) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: s.buildAmountRow(
                  'from ${s.widget.recipient}')),
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
        title: 'From my account',
        subtitle: 'Transfer from a bucket',
        onTap: () => s.setState(() => s.screen = 'bucket'),
      ),
      s.buildFlowRow(
        icon: Icons.swap_horiz,
        iconColor: const Color(0xFF4a9eff),
        iconBg: const Color(0xFF4a9eff).withOpacity(0.12),
        title: 'Not mine',
        subtitle: "Holding it for someone's task",
        onTap: () => s.setState(() {
          s.noteController.clear();
          s.screen = 'custody_receive';
        }),
      ),
      s.buildFlowRow(
        icon: Icons.trending_up,
        iconColor: const Color(0xFF5ec47a),
        iconBg: const Color(0xFF5ec47a).withOpacity(0.12),
        title: 'True income',
        subtitle: 'Into my own pocket',
        onTap: () {
          if (s.trueIncomeCategories.isEmpty && !s.loadingTrueIncome) {
            s.loadTrueIncomeCategories();
          }
          if (s.otherIncomeCategories.isEmpty && !s.loadingOtherIncome) {
            s.loadOtherIncomeCategories();
          }
          s.setState(() => s.screen = 'income_type');
        },
        last: true,
      ),
    ],
  );
}

// ── Income type (true income + other, two groups) ──────────────────────
Widget buildIncomeType(TagCardState s) {
  if (s.loadingTrueIncome || s.loadingOtherIncome) {
    return Column(
      children: [
        s.buildHeader(
            'True income · Ksh ${s.widget.amount.toInt()}',
            backScreen: 'root'),
        const SizedBox(height: 24),
        const Center(
            child: CircularProgressIndicator(color: tagCardGold)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget buildChipGroup(String label, List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: tagCardWhite.withOpacity(0.5))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((c) {
            final selected = s.selectedIncomeType == c.name;
            return GestureDetector(
              onTap: () =>
                  s.setState(() => s.selectedIncomeType = c.name),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF5ec47a).withOpacity(0.2)
                      : tagCardWhite.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF5ec47a).withOpacity(0.6)
                        : tagCardWhite.withOpacity(0.12),
                    width: 0.5,
                  ),
                ),
                child: Text(c.name,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? const Color(0xFF5ec47a)
                            : tagCardWhite.withOpacity(0.8))),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  final isDebtRepayment = s.selectedIncomeType == 'Debt repayment';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      s.buildHeader(
          'True income · Ksh ${s.widget.amount.toInt()}',
          backScreen: 'root'),
      const SizedBox(height: 16),
      buildChipGroup('True income', s.trueIncomeCategories),
      const SizedBox(height: 20),
      buildChipGroup('Other', s.otherIncomeCategories),
      const SizedBox(height: 20),
      // Note field — not shown for Debt repayment, which has its own flow
      if (s.selectedIncomeType != null && !isDebtRepayment) ...[
        Text("Add a note (optional)",
            style: TextStyle(
                fontSize: 11,
                color: tagCardWhite.withOpacity(0.5))),
        const SizedBox(height: 8),
        s.buildNoteField('e.g. Mum, side job payment'),
        const SizedBox(height: 16),
      ],
      s.buildSaveBtn(
          isDebtRepayment ? 'Continue' : 'Save',
          s.selectedIncomeType == null
              ? null
              : () {
                  if (isDebtRepayment) {
                    loadReceivables(s);
                  } else {
                    saveIncome(s);
                  }
                }),
    ],
  );
}

// ── Custody receive ───────────────────────────────────────────────────
Widget buildCustodyReceive(TagCardState s) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      s.buildHeader(
          "Adding to pool · Ksh ${s.widget.amount.toInt()}",
          backScreen: 'root'),
      const SizedBox(height: 16),
      Text("What pool is this for?",
          style: TextStyle(
              fontSize: 11,
              color: tagCardWhite.withOpacity(0.5))),
      const SizedBox(height: 8),
      s.buildNoteField('e.g. Fuel float, Westlands job'),
      const SizedBox(height: 20),
      s.buildSaveBtn('Save', () => saveCustodyReceive(s)),
    ],
  );
}

// ── Debt repayment match ────────────────────────────────────────────────
Widget buildReceivableMatch(TagCardState s) {
  if (s.loadingReceivables) {
    return Column(children: [
      s.buildHeader(
          "Debt repayment · Ksh ${s.widget.amount.toInt()}",
          backScreen: 'income_type'),
      const SizedBox(height: 24),
      const Center(
          child:
              CircularProgressIndicator(color: tagCardGold)),
      const SizedBox(height: 24),
    ]);
  }
  if (s.receivables.isEmpty) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          s.buildHeader(
              "Debt repayment · Ksh ${s.widget.amount.toInt()}",
              backScreen: 'income_type'),
          const SizedBox(height: 16),
          Text(
            'No tracked debts found.',
            style: TextStyle(
                fontSize: 13,
                color: tagCardWhite.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          s.buildSaveBtn(
              'Log as debt repayment', () => saveIncome(s)),
        ]);
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      s.buildHeader(
          "Debt repayment · Ksh ${s.widget.amount.toInt()}",
          backScreen: 'income_type'),
      const SizedBox(height: 10),
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: s.receivables.length,
          separatorBuilder: (_, __) => Divider(
              color: tagCardWhite.withOpacity(0.08),
              height: 1),
          itemBuilder: (_, i) {
            final r = s.receivables[i];
            final label = r.receivableLabel ?? 'Unnamed';
            final owed = r.amount;
            final incoming = s.widget.amount;
            final cleared =
                incoming >= owed ? owed : incoming;
            final income =
                incoming > owed ? incoming - owed : 0.0;
            return GestureDetector(
              onTap: () => saveReceivableMatch(s, r),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
                child: Row(children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5ec47a)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(9),
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
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => saveIncome(s),
        child: Text(
          'Not one of these — log as debt repayment',
          style: TextStyle(
              fontSize: 12,
              color: tagCardGold.withOpacity(0.9),
              fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );
}

// ── Save methods ──────────────────────────────────────────────────────
Future<void> loadReceivables(TagCardState s) async {
  s.setState(() {
    s.loadingReceivables = true;
    s.screen = 'debt_repayment_match';
  });
  final results = await db.getOpenReceivables();
  s.setState(() {
    s.receivables = results;
    s.loadingReceivables = false;
  });
}

Future<void> saveCustodyReceive(TagCardState s) async {
  final label = s.noteController.text.trim().isEmpty
      ? 'Custody – ${DateTime.now().day}/${DateTime.now().month}'
      : s.noteController.text.trim();
  await s.upsert(TransactionsCompanion(
    txCode: drift.Value(s.widget.txCode),
    amount: drift.Value(s.widget.amount),
    recipient: drift.Value(s.widget.recipient),
    direction: drift.Value('in'),
    type: drift.Value('custody_receive'),
    poolLabel: drift.Value(label),
    balanceAfter: drift.Value(s.widget.balance),
    rawSms: drift.Value(''),
    createdAt: drift.Value(DateTime.now()),
    isTagged: drift.Value(true),
  ));
  await s.completeAndClose();
}

Future<void> saveReceivableMatch(
    TagCardState s, Transaction receivable) async {
  final owed = receivable.amount;
  final incoming = s.widget.amount;
  await s.upsert(TransactionsCompanion(
    txCode: drift.Value(s.widget.txCode),
    amount: drift.Value(incoming >= owed ? owed : incoming),
    recipient: drift.Value(s.widget.recipient),
    direction: drift.Value('in'),
    type: drift.Value('receivable_clear'),
    receivableLabel: drift.Value(receivable.receivableLabel),
    balanceAfter: drift.Value(s.widget.balance),
    rawSms: drift.Value(''),
    createdAt: drift.Value(DateTime.now()),
    isTagged: drift.Value(true),
  ));
  if (incoming > owed) {
    final excess = incoming - owed;
    await db.insertTransaction(TransactionsCompanion(
      txCode: drift.Value('${s.widget.txCode}_income'),
      amount: drift.Value(excess),
      recipient: drift.Value(s.widget.recipient),
      direction: drift.Value('in'),
      type: drift.Value('income'),
      receivableLabel: drift.Value(
          '${receivable.receivableLabel} – income split'),
      balanceAfter: drift.Value(s.widget.balance),
      rawSms: drift.Value('auto-split from receivable'),
      createdAt: drift.Value(DateTime.now()),
      isTagged: drift.Value(true),
    ));
  }
  await s.completeAndClose();
}

Future<void> saveIncome(TagCardState s) async {
  final typeLabel = (s.selectedIncomeType == 'Other' ||
              s.selectedIncomeType == 'Family Support') &&
          s.noteController.text.trim().isNotEmpty
      ? '${s.selectedIncomeType}: ${s.noteController.text.trim()}'
      : s.selectedIncomeType ?? 'Income';

  await s.upsert(TransactionsCompanion(
    txCode: drift.Value(s.widget.txCode),
    amount: drift.Value(s.widget.amount),
    recipient: drift.Value(s.widget.recipient),
    direction: drift.Value('in'),
    type: drift.Value('income'),
    category: drift.Value(typeLabel),
    balanceAfter: drift.Value(s.widget.balance),
    rawSms: drift.Value(''),
    createdAt: drift.Value(DateTime.now()),
    isTagged: drift.Value(true),
  ));
  await s.completeAndClose();
}
