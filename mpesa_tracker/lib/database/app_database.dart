import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Transactions table (unchanged) ───────────────────────────────────
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get txCode => text()();
  RealColumn get amount => real()();
  RealColumn get txCost => real().withDefault(const Constant(0.0))();
  TextColumn get recipient => text()();
  TextColumn get direction => text()();
  TextColumn get type => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get bucketName => text().nullable()();
  TextColumn get poolLabel => text().nullable()();
  TextColumn get receivableLabel => text().nullable()();
  RealColumn get balanceAfter => real().withDefault(const Constant(0.0))();
  TextColumn get rawSms => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isTagged => boolean().withDefault(const Constant(false))();
}

// ── Accounts table (new) ──────────────────────────────────────────────
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // group: mpesa | bank | mobile_savings | investment
  TextColumn get group => text()();
  // zone: 1 (operating) | 2 (reserves) | 3 (committed) | 4 (invested)
  IntColumn get zone => integer().withDefault(const Constant(1))();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get manualBalance => real().nullable()();
  DateTimeColumn get manualBalanceSetAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Transactions, Accounts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Seed default accounts on fresh install
      await _seedAccounts();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(accounts);
        await _seedAccounts();
      }
      if (from < 3) {
        await m.addColumn(accounts, accounts.zone);
        await _assignDefaultZones();
      }
    },
  );

  // Assign zones to existing accounts based on their name
  Future<void> _assignDefaultZones() async {
    final zoneMap = {
      'M-Pesa': 1,
      'Other M-Pesa': 1,
      'M-Shwari': 2,
      'KCB M-Pesa': 2,
      'M-Shwari Lock': 3,
      'KCB M-Pesa Lock': 3,
      'NCBA': 3,
      'KCB Bank': 3,
      'Etica': 4,
      'Company': 4,
    };

    final all = await select(accounts).get();
    for (final a in all) {
      final z = zoneMap[a.name] ?? 1;
      await (update(accounts)..where((acc) => acc.id.equals(a.id)))
        .write(AccountsCompanion(zone: Value(z)));
    }
  }

  // ── Seed default accounts ───────────────────────────────────────────
  Future<void> _seedAccounts() async {
    final defaults = [
      ('M-Pesa',          'mpesa',          1),
      ('Other M-Pesa',    'mpesa',          1),
      ('M-Shwari',        'mobile_savings', 2),
      ('KCB M-Pesa',      'mobile_savings', 2),
      ('M-Shwari Lock',   'mobile_savings', 3),
      ('KCB M-Pesa Lock', 'mobile_savings', 3),
      ('NCBA',            'bank',           3),
      ('KCB Bank',        'bank',           3),
      ('Etica',           'investment',     4),
      ('Company',         'investment',     4),
    ];

    for (final (name, group, zone) in defaults) {
      await into(accounts).insert(AccountsCompanion(
        name: Value(name),
        group: Value(group),
        zone: Value(zone),
        openingBalance: const Value(0.0),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
      ));
    }
  }

  // ── Transaction queries ─────────────────────────────────────────────
  Future<int> insertTransaction(TransactionsCompanion t) =>
      into(transactions).insert(t);

  Future<List<Transaction>> getUntagged() =>
      (select(transactions)
        ..where((t) => t.isTagged.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();

  Stream<List<Transaction>> watchAll() =>
      (select(transactions)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  Future<List<Transaction>> getOpenReceivables() =>
      (select(transactions)
        ..where((t) => t.type.equals('receivable_create'))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();

  Future<Map<String, double>> getBucketBalances() async {
    final all = await select(transactions).get();
    final Map<String, double> balances = {};

    for (final t in all) {
      if (t.bucketName == null) continue;
      final bucket = t.bucketName!;
      final current = balances[bucket] ?? 0.0;
      if (t.type == 'transfer') {
        balances[bucket] = current + t.amount;
      } else if (t.type == 'transfer_in') {
        balances[bucket] = current - t.amount;
      }
    }
    return balances;
  }

  // ── Account queries ─────────────────────────────────────────────────
  Future<List<Account>> getAllAccounts() =>
      (select(accounts)
        ..where((a) => a.isActive.equals(true))
        ..orderBy([(a) => OrderingTerm.asc(a.id)]))
      .get();
  
  Future<List<Account>> getAccountsByZone(int zone) =>
    (select(accounts)
      ..where((a) => a.zone.equals(zone) & a.isActive.equals(true))
      ..orderBy([(a) => OrderingTerm.asc(a.id)]))
    .get();

  Future<void> updateAccountZone(int id, int zone) =>
      (update(accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(zone: Value(zone)));

  Future<Account?> getAccountByName(String name) =>
      (select(accounts)..where((a) => a.name.equals(name)))
      .getSingleOrNull();


  Future<void> updateOpeningBalance(int id, double balance) =>
      (update(accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(
        openingBalance: Value(balance),
      ));

  Future<void> setManualBalance(int id, double balance) =>
      (update(accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(
        manualBalance: Value(balance),
        manualBalanceSetAt: Value(DateTime.now()),
      ));

  Future<void> addCustomAccount(String name, String group) =>
      into(accounts).insert(AccountsCompanion(
        name: Value(name),
        group: Value(group),
        openingBalance: const Value(0.0),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
      ));

  Future<void> updateTaggedTransaction(
    int id, {
    required String type,
    String? category,
    String? bucketName,
    String? poolLabel,
    String? receivableLabel,
  }) =>
      (update(transactions)..where((t) => t.id.equals(id)))
      .write(TransactionsCompanion(
        type: Value(type),
        isTagged: const Value(true),
        category: Value(category),
        bucketName: Value(bucketName),
        poolLabel: Value(poolLabel),
        receivableLabel: Value(receivableLabel),
      ));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mpesa_tracker.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}