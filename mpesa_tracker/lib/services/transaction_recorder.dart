import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../main.dart';

/// Writes a transaction as untagged if one doesn't already exist for its
/// txCode, so a parsed M-Pesa message is never lost regardless of whether
/// its overlay bubble is ever tapped, dismissed, replaced by a newer
/// message, or auto-times-out unseen. Tagging later finds and updates this
/// same row (see `TagCardState.upsert`) rather than duplicating it.
Future<void> recordUntaggedIfNeeded(Map<String, dynamic> data) async {
  final txCode = data['txCode'] as String;
  final amount = (data['amount'] as num).toDouble();
  final recipient = data['recipient'] as String;
  final direction = data['direction'] as String;
  final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;

  final existing = await (db.select(db.transactions)
        ..where((t) =>
            t.txCode.equals(txCode) & t.isTagged.equals(false)))
      .getSingleOrNull();
  if (existing != null) return;

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
}
