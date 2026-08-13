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
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
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
  // group: only meaningful for direction == 'in' — 'true_income' | 'other'
  TextColumn get group => text().nullable()();
  // parentId: only meaningful for direction == 'out' — self-references Categories.id
  IntColumn get parentId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Transactions, Accounts, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedAccounts();
      await _seedCategories();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(accounts, accounts.isSystem);
      }
      if (from < 3) {
        await m.addColumn(categories, categories.group);
      }
      if (from < 4) {
        await m.addColumn(categories, categories.parentId);
      }
    },
  );

  // ── Seeds ─────────────────────────────────────────────────────────
  Future<void> _seedAccounts() async {
    final defaults = [
      ('M-Pesa',          'mpesa',          1),
      ('M-Shwari',        'mobile_savings', 2),
      ('KCB M-Pesa',      'mobile_savings', 2),
      ('M-Shwari Lock',   'mobile_savings', 3),
      ('KCB M-Pesa Lock', 'mobile_savings', 3),
    ];

    for (final (name, group, zone) in defaults) {
      await into(accounts).insert(AccountsCompanion(
        name: Value(name),
        group: Value(group),
        zone: Value(zone),
        openingBalance: const Value(0.0),
        isActive: const Value(true),
        isHidden: const Value(false),
        isSystem: const Value(true),
        createdAt: Value(DateTime.now()),
      ));
    }
  }

  Future<void> _seedCategories() async {
    final outCategories = [
      'Food',
      'Transport',
      'Bills',
      'Supplies',
      'Airtime',
      'Clothing',
      'Grooming',
      'Gift',
      'Other',
    ];

    final outSubcategories = {
      'Food':      ['Breakfast', 'Lunch', 'Supper', 'Snack'],
      'Transport': ['Fueling', 'Service', 'Public'],
    };

    final trueIncomeCategories = [
      ('Salary',           0),
      ('Business profit',  1),
      ('Debt repayment',   2),
    ];

    final otherIncomeCategories = [
      ('Family Support',  0),
      ('Gift',             1),
      ('Other',            2),
    ];

    for (var i = 0; i < outCategories.length; i++) {
      final name = outCategories[i];
      final parentId = await into(categories).insert(CategoriesCompanion(
        name: Value(name),
        direction: const Value('out'),
        isSystem: const Value(false),
        isActive: const Value(true),
        sortOrder: Value(i),
        createdAt: Value(DateTime.now()),
      ));

      final children = outSubcategories[name];
      if (children != null) {
        for (var j = 0; j < children.length; j++) {
          await into(categories).insert(CategoriesCompanion(
            name: Value(children[j]),
            direction: const Value('out'),
            isSystem: const Value(false),
            isActive: const Value(true),
            sortOrder: Value(j),
            parentId: Value(parentId),
            createdAt: Value(DateTime.now()),
          ));
        }
      }
    }

    for (final (name, sort) in trueIncomeCategories) {
      await into(categories).insert(CategoriesCompanion(
        name: Value(name),
        direction: const Value('in'),
        isSystem: const Value(false),
        isActive: const Value(true),
        sortOrder: Value(sort),
        group: const Value('true_income'),
        createdAt: Value(DateTime.now()),
      ));
    }

    for (final (name, sort) in otherIncomeCategories) {
      await into(categories).insert(CategoriesCompanion(
        name: Value(name),
        direction: const Value('in'),
        isSystem: const Value(false),
        isActive: const Value(true),
        sortOrder: Value(sort),
        group: const Value('other'),
        createdAt: Value(DateTime.now()),
      ));
    }
  }

  // ── Transaction queries ───────────────────────────────────────────
  Future<int> insertTransaction(TransactionsCompanion t) =>
      into(transactions).insert(t);

  Future<void> clearAllTransactions() => delete(transactions).go();

  Future<void> resetAllAccountBalances() =>
      update(accounts).write(const AccountsCompanion(
        openingBalance: Value(0.0),
        manualBalance: Value(null),
        manualBalanceSetAt: Value(null),
      ));

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

  /// Open custody pools (money held on behalf of someone else) with a
  /// positive remaining balance, keyed by their pool label.
  Future<List<Map<String, dynamic>>> getCustodyPoolBalances() async {
    final all = await select(transactions).get();
    final Map<String, double> poolMap = {};
    for (final t in all) {
      if (t.type == 'custody_receive') {
        final label = t.poolLabel ?? 'Unnamed';
        poolMap[label] = (poolMap[label] ?? 0) + t.amount;
      }
      if (t.type == 'custody_spend') {
        final label = t.poolLabel ?? 'Unnamed';
        poolMap[label] = (poolMap[label] ?? 0) - t.amount;
      }
    }
    return poolMap.entries
        .where((e) => e.value > 0)
        .map((e) => {'label': e.key, 'balance': e.value})
        .toList();
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

  Future<List<Account>> getInactiveAccounts() =>
      (select(accounts)
        ..where((a) => a.isActive.equals(false))
        ..orderBy([(a) => OrderingTerm.asc(a.name)]))
      .get();

  Future<void> reactivateAccount(int id) =>
      (update(accounts)..where((a) => a.id.equals(id)))
      .write(const AccountsCompanion(isActive: Value(true)));

  // ── Category queries ──────────────────────────────────────────────
  Future<List<Category>> getCategories(String direction, {String? group}) =>
      (select(categories)
        ..where((c) {
          final base =
              c.direction.equals(direction) & c.isActive.equals(true);
          return group == null ? base : base & c.group.equals(group);
        })
        ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
      .get();

  Future<void> addCategory(
      String name, String direction, bool isSystem,
      {String? group, int? parentId}) =>
      into(categories).insert(CategoriesCompanion(
        name: Value(name),
        direction: Value(direction),
        isSystem: Value(isSystem),
        isActive: const Value(true),
        sortOrder: const Value(99),
        group: Value(group),
        parentId: Value(parentId),
        createdAt: Value(DateTime.now()),
      ));

  Future<void> renameCategory(int id, String newName) =>
      (update(categories)..where((c) => c.id.equals(id)))
      .write(CategoriesCompanion(name: Value(newName)));

  Future<void> deactivateCategory(int id) =>
      (update(categories)..where((c) => c.id.equals(id)))
      .write(const CategoriesCompanion(isActive: Value(false)));

  Future<void> deactivateCategoryAndChildren(int id) async {
    await deactivateCategory(id);
    await (update(categories)..where((c) => c.parentId.equals(id)))
        .write(const CategoriesCompanion(isActive: Value(false)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file =
        File(p.join(dir.path, 'dhahiri.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}