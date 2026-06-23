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