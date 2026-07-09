import 'package:flutter/material.dart';
import '../main.dart';
import '../database/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'tag_card.dart';

Future<void> showTagCard(
    BuildContext context, Map<String, dynamic> data) async {
  final amount = (data['amount'] as num).toDouble();
  final txCost = (data['txCost'] as num?)?.toDouble() ?? 0.0;
  final recipient = data['recipient'] as String;
  final direction = data['direction'] as String;
  final txCode = data['txCode'] as String;
  final balance = (data['balance'] as num).toDouble();

  // Auto-save transaction fee
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

  // Auto-update secondary account balance (M-Shwari, KCB M-Pesa)
  final secondaryBalance =
      (data['secondaryBalance'] as num?)?.toDouble() ?? 0.0;
  final secondaryAccount =
      data['secondaryAccount'] as String? ?? '';

  if (secondaryBalance > 0 && secondaryAccount.isNotEmpty) {
    final account = await db.getAccountByName(secondaryAccount);
    if (account != null) {
      await db.setManualBalance(account.id, secondaryBalance);
    }
  }

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (_) => TagCard(
      amount: amount,
      recipient: recipient,
      direction: direction,
      txCode: txCode,
      balance: balance,
    ),
  );
}