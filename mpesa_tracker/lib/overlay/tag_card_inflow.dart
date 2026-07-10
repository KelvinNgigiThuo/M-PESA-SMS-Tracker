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
        subtitle: 'Custody or payment received',
        onTap: () =>
            s.setState(() => s.screen = 'inflow_not_mine'),
      ),
      s.buildFlowRow(
        icon: Icons.trending_up,
        iconColor: const Color(0xFF5ec47a),
        iconBg: const Color(0xFF5ec47a).withOpacity(0.12),
        title: 'True income',
        subtitle: 'Into my own pocket',
        onTap: () => saveIncome(s),
        last: true,
      ),
    ],
  );
}

// ── Not mine sub-choice ───────────────────────────────────────────────
Widget buildInflowNotMine(TagCardState s) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      s.buildHeader(
          'Not mine · Ksh ${s.widget.amount.toInt()}',
          backScreen: 'root'),
      const SizedBox(height: 14),
      s.buildFlowRow(
        icon: Icons.add_circle_outline,
        iconColor: const Color(0xFF4a9eff),
        iconBg: const Color(0xFF4a9eff).withOpacity(0.12),
        title: "Adding to a pool I'm holding",
        subtitle: 'Tops up a custody pool',
        onTap: () => s.setState(() {
          s.noteController.clear();
          s.screen = 'custody_receive';
        }),
      ),
      s.buildFlowRow(
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF5ec47a),
        iconBg: const Color(0xFF5ec47a).withOpacity(0.12),
        title: "Clears what I'm owed",
        subtitle: 'Match to an open receivable',
        onTap: () => loadReceivables(s),
        last: true,
      ),
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
          backScreen: 'inflow_not_mine'),
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

// ── Receivable match ──────────────────────────────────────────────────
Widget buildReceivableMatch(TagCardState s) {
  if (s.loadingReceivables) {
    return Column(children: [
      s.buildHeader(
          "Clears what I'm owed · Ksh ${s.widget.amount.toInt()}",
          backScreen: 'inflow_not_mine'),
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
              "Clears what I'm owed · Ksh ${s.widget.amount.toInt()}",
              backScreen: 'inflow_not_mine'),
          const SizedBox(height: 16),
          Text(
            'No open receivables found.\nTag as True income instead.',
            style: TextStyle(
                fontSize: 13,
                color: tagCardWhite.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          s.buildSaveBtn(
              'Save as income', () => saveIncome(s)),
        ]);
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      s.buildHeader(
          "Clears what I'm owed · Ksh ${s.widget.amount.toInt()}",
          backScreen: 'inflow_not_mine'),
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
    ],
  );
}

// ── Save methods ──────────────────────────────────────────────────────
Future<void> loadReceivables(TagCardState s) async {
  s.setState(() {
    s.loadingReceivables = true;
    s.screen = 'receivable_match';
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
  await s.upsert(TransactionsCompanion(
    txCode: drift.Value(s.widget.txCode),
    amount: drift.Value(s.widget.amount),
    recipient: drift.Value(s.widget.recipient),
    direction: drift.Value('in'),
    type: drift.Value('income'),
    balanceAfter: drift.Value(s.widget.balance),
    rawSms: drift.Value(''),
    createdAt: drift.Value(DateTime.now()),
    isTagged: drift.Value(true),
  ));
  await s.completeAndClose();
}