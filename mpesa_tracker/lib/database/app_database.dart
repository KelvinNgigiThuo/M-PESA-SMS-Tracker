import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Transactions table ────────────────────────────────────────────────
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

// ── Accounts table ────────────────────────────────────────────────────
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get group => text()();
  IntColumn get zone => integer().withDefault(const Constant(1))();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get manualBalance => real().nullable()();
  DateTimeColumn get manualBalanceSetAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

// ── Categories table ──────────────────────────────────────────────────
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // direction: 'in' | 'out'
  TextColumn get direction => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Transactions, Accounts, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedAccounts();
      await _seedCategories();
    },
  );

  // ── Seeds ─────────────────────────────────────────────────────────
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
        isHidden: const Value(false),
        createdAt: Value(DateTime.now()),
      ));
    }
  }

  Future<void> _seedCategories() async {
    final outCategories = [
      ('Food',      true,  0),
      ('Transport', true,  1),
      ('Bills',     true,  2),
      ('Supplies',  true,  3),
      ('Airtime',   true,  4),
      ('Other',     true,  5),
    ];

    final inCategories = [
      ('Freelance',       true,  0),
      ('Business',        true,  1),
      ('Family Support',  false, 2),
      ('Gift',            false, 3),
      ('Other',           true,  4),
    ];

    for (final (name, isSystem, sort) in outCategories) {
      await into(categories).insert(CategoriesCompanion(
        name: Value(name),
        direction: const Value('out'),
        isSystem: Value(isSystem),
        isActive: const Value(true),
        sortOrder: Value(sort),
        createdAt: Value(DateTime.now()),
      ));
    }

    for (final (name, isSystem, sort) in inCategories) {
      await into(categories).insert(CategoriesCompanion(
        name: Value(name),
        direction: const Value('in'),
        isSystem: Value(isSystem),
        isActive: const Value(true),
        sortOrder: Value(sort),
        createdAt: Value(DateTime.now()),
      ));
    }
  }

  // ── Transaction queries ───────────────────────────────────────────
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

  // ── Account queries ───────────────────────────────────────────────
  Future<List<Account>> getAllAccounts() =>
      (select(accounts)
        ..where((a) => a.isActive.equals(true))
        ..orderBy([
          (a) => OrderingTerm.asc(a.zone),
          (a) => OrderingTerm.asc(a.id),
        ]))
      .get();

  Future<Account?> getAccountByName(String name) =>
      (select(accounts)..where((a) => a.name.equals(name)))
      .getSingleOrNull();

  Future<bool> hasCompletedSetup() async {
    final result = await (select(accounts)
      ..where((a) => a.openingBalance.isBiggerThanValue(0)))
    .getSingleOrNull();
    return result != null;
  }

  Future<void> updateOpeningBalance(int id, double balance) =>
      (update(accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(openingBalance: Value(balance)));

  Future<void> setManualBalance(int id, double balance) =>
      (update(accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(
        manualBalance: Value(balance),
        manualBalanceSetAt: Value(DateTime.now()),
      ));

  Future<void> addCustomAccount(
      String name, String group, int zone) =>
      into(accounts).insert(AccountsCompanion(
        name: Value(name),
        group: Value(group),
        zone: Value(zone),
        openingBalance: const Value(0.0),
        isActive: const Value(true),
        isHidden: const Value(false),
        createdAt: Value(DateTime.now()),
      ));

  Future<void> renameAccount(int id, String newName) =>
      (update(accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(name: Value(newName)));

  Future<void> updateAccountZone(int id, int zone) =>
      (update(accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(zone: Value(zone)));

  Future<void> toggleAccountHidden(int id, bool hidden) =>
      (update(accounts)..where((a) => a.id.equals(id)))
      .write(AccountsCompanion(isHidden: Value(hidden)));

  Future<void> deactivateAccount(int id) =>
      (update(accounts)..where((a) => a.id.equals(id)))
      .write(const AccountsCompanion(isActive: Value(false)));

  // ── Category queries ──────────────────────────────────────────────
  Future<List<Category>> getCategories(String direction) =>
      (select(categories)
        ..where((c) =>
            c.direction.equals(direction) &
            c.isActive.equals(true))
        ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
      .get();

  Future<void> addCategory(
      String name, String direction, bool isSystem) =>
      into(categories).insert(CategoriesCompanion(
        name: Value(name),
        direction: Value(direction),
        isSystem: Value(isSystem),
        isActive: const Value(true),
        sortOrder: const Value(99),
        createdAt: Value(DateTime.now()),
      ));

  Future<void> renameCategory(int id, String newName) =>
      (update(categories)..where((c) => c.id.equals(id)))
      .write(CategoriesCompanion(name: Value(newName)));

  Future<void> deactivateCategory(int id) =>
      (update(categories)..where((c) => c.id.equals(id)))
      .write(const CategoriesCompanion(isActive: Value(false)));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file =
        File(p.join(dir.path, 'dhahiri.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}