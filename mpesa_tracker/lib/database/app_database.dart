import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Single table for v1 — covers both outflow and inflow
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get txCode => text()();
  RealColumn get amount => real()();
  RealColumn get txCost => real().withDefault(const Constant(0.0))();
  TextColumn get recipient => text()();
  TextColumn get direction => text()(); // "in" or "out"
  TextColumn get type => text().nullable()();
  // out types: transfer | custody_spend | receivable_create | expense | fee
  // in types:  transfer_in | custody_receive | receivable_clear | income
  TextColumn get category => text().nullable()();   // expense category
  TextColumn get bucketName => text().nullable()();  // for transfers
  TextColumn get poolLabel => text().nullable()();   // for custody
  TextColumn get receivableLabel => text().nullable()(); // for receivables
  RealColumn get balanceAfter => real().withDefault(const Constant(0.0))();
  TextColumn get rawSms => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isTagged => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Save a transaction
  Future<int> insertTransaction(TransactionsCompanion t) =>
      into(transactions).insert(t);

  // All untagged transactions — for the untagged queue in M6
  Future<List<Transaction>> getUntagged() =>
      (select(transactions)
        ..where((t) => t.isTagged.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();

  // Open receivables — for matching incoming payments against
  Future<List<Transaction>> getOpenReceivables() =>
      (select(transactions)
        ..where((t) => t.type.equals('receivable_create'))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();

  // Sum all transfers per bucket — positive for transfers in, negative for transfers out
  Future<Map<String, double>> getBucketBalances() async {
    final all = await select(transactions).get();
    final Map<String, double> balances = {};

    for (final t in all) {
      if (t.bucketName == null) continue;
      final bucket = t.bucketName!;
      final current = balances[bucket] ?? 0.0;

      if (t.type == 'transfer') {
        // Money left M-Pesa and went into this bucket
        balances[bucket] = current + t.amount;
      } else if (t.type == 'transfer_in') {
        // Money came back from this bucket into M-Pesa
        balances[bucket] = current - t.amount;
      }
    }

    return balances;
  }

  // All transactions — for history later
  Stream<List<Transaction>> watchAll() =>
      (select(transactions)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mpesa_tracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}