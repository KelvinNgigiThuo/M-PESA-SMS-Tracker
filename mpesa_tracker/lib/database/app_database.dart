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

  /// Sums `amount` grouped by [column] for rows matching [type], via SQL
  /// SUM/GROUP BY rather than pulling every row into Dart.
  Future<Map<String, double>> _sumGroupedByType(
    String type,
    GeneratedColumn<String> column,
  ) async {
    final sumExp = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([column, sumExp])
      ..where(transactions.type.equals(type))
      ..groupBy([column]);
    final rows = await query.get();
    final Map<String, double> result = {};
    for (final row in rows) {
      final key = row.read(column);
      if (key == null) continue;
      result[key] = row.read(sumExp) ?? 0;
    }
    return result;
  }

  Future<Map<String, double>> getBucketBalances() async {
    final out = await _sumGroupedByType('transfer', transactions.bucketName);
    final inn = await _sumGroupedByType('transfer_in', transactions.bucketName);
    final Map<String, double> balances = {};
    for (final entry in out.entries) {
      balances[entry.key] = (balances[entry.key] ?? 0) + entry.value;
    }
    for (final entry in inn.entries) {
      balances[entry.key] = (balances[entry.key] ?? 0) - entry.value;
    }
    return balances;
  }

  /// Open custody pools (money held on behalf of someone else) with a
  /// positive remaining balance, keyed by their pool label.
  Future<List<Map<String, dynamic>>> getCustodyPoolBalances() async {
    final received =
        await _sumGroupedByType('custody_receive', transactions.poolLabel);
    final spent =
        await _sumGroupedByType('custody_spend', transactions.poolLabel);
    final Map<String, double> poolMap = {};
    for (final entry in received.entries) {
      poolMap[entry.key] = (poolMap[entry.key] ?? 0) + entry.value;
    }
    for (final entry in spent.entries) {
      poolMap[entry.key] = (poolMap[entry.key] ?? 0) - entry.value;
    }
    return poolMap.entries
        .where((e) => e.value > 0)
        .map((e) => {'label': e.key, 'balance': e.value})
        .toList();
  }

  /// Total `amount` of rows matching [type] — 0 if none.
  Future<double> _sumAmountForType(String type) async {
    final sumExp = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([sumExp])
      ..where(transactions.type.equals(type));
    final row = await query.getSingleOrNull();
    return row?.read(sumExp) ?? 0;
  }

  /// Net money currently held on behalf of others (custody received minus
  /// custody spent), clamped to 0 or above.
  Future<double> getCustodyHeldTotal() async {
    final received = await _sumAmountForType('custody_receive');
    final spent = await _sumAmountForType('custody_spend');
    return (received - spent).clamp(0, double.infinity);
  }

  /// Net money fronted for others still outstanding (receivables created
  /// minus receivables cleared), clamped to 0 or above.
  Future<double> getOpenReceivablesTotal() async {
    final created = await _sumAmountForType('receivable_create');
    final cleared = await _sumAmountForType('receivable_clear');
    return (created - cleared).clamp(0, double.infinity);
  }

  /// Sum of `amount` for transactions moving in [direction] within
  /// [start, endExclusive) — e.g. a calendar month.
  Future<double> getSumByDirectionInRange(
    String direction,
    DateTime start,
    DateTime endExclusive,
  ) async {
    final sumExp = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([sumExp])
      ..where(transactions.direction.equals(direction) &
          transactions.createdAt.isBiggerOrEqualValue(start) &
          transactions.createdAt.isSmallerThanValue(endExclusive));
    final row = await query.getSingleOrNull();
    return row?.read(sumExp) ?? 0;
  }

  /// The most recent `balanceAfter` reading across all transactions — the
  /// M-Pesa account's live balance, since every SMS carries the balance at
  /// the time it was sent.
  Future<double> getLatestBalanceAfter() async {
    final row = await (select(transactions)
          ..where((t) => t.balanceAfter.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .getSingleOrNull();
    return row?.balanceAfter ?? 0;
  }

  Future<List<Transaction>> getRecentTagged(int limit) =>
      (select(transactions)
        ..where((t) => t.isTagged.equals(true))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(limit))
      .get();

  Future<void> updateTaggedTransaction(
    int id, {
    required String type,
    String? category,
    String? bucketName,
    String? poolLabel,
    String? receivableLabel,
    double? amount,
  }) =>
      (update(transactions)..where((t) => t.id.equals(id)))
      .write(TransactionsCompanion(
        amount: amount == null ? const Value.absent() : Value(amount),
        type: Value(type),
        isTagged: const Value(true),
        category: Value(category),
        bucketName: Value(bucketName),
        poolLabel: Value(poolLabel),
        receivableLabel: Value(receivableLabel),
      ));

  /// Reverts a tagged transaction back to untagged so it can be re-tagged.
  /// Removes rows auto-split from it at tagging time (`_income` from a
  /// receivable overpayment, `_expense` from a custody spend remainder) and
  /// folds their amount back in. The `_fee` row is kept — the fee was real.
  Future<void> untagTransaction(int id) => transaction(() async {
        final row = await (select(transactions)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (row == null || !row.isTagged) return;
        var amount = row.amount;
        final splitCodes = ['${row.txCode}_income', '${row.txCode}_expense'];
        final splits = await (select(transactions)
              ..where((t) => t.txCode.isIn(splitCodes)))
            .get();
        for (final split in splits) {
          amount += split.amount;
        }
        await (delete(transactions)..where((t) => t.txCode.isIn(splitCodes)))
            .go();
        await (update(transactions)..where((t) => t.id.equals(id)))
            .write(TransactionsCompanion(
          amount: Value(amount),
          type: const Value(null),
          category: const Value(null),
          bucketName: const Value(null),
          poolLabel: const Value(null),
          receivableLabel: const Value(null),
          isTagged: const Value(false),
        ));
      });

  /// Manual settlement rows (see [settleCustodyPool]) aren't real M-Pesa
  /// movements, so they use this direction to stay out of in/out totals.
  static const adjustmentDirection = 'adjust';

  /// Zeroes a custody pool's remaining balance (e.g. the money was handed
  /// back in cash) by recording a manual `custody_spend` adjustment.
  Future<void> settleCustodyPool(String label, double balance) =>
      into(transactions).insert(TransactionsCompanion(
        txCode: Value('settle_${DateTime.now().millisecondsSinceEpoch}'),
        amount: Value(balance),
        recipient: const Value('Manual settlement'),
        direction: const Value(adjustmentDirection),
        type: const Value('custody_spend'),
        poolLabel: Value(label),
        rawSms: const Value('manual custody settlement'),
        createdAt: Value(DateTime.now()),
        isTagged: const Value(true),
      ));

  /// Untags every transaction in a custody pool — for a pool created by
  /// mistake. Its SMS rows go back to untagged; manual settlements are
  /// deleted outright since they have no SMS behind them.
  Future<void> untagCustodyPool(String label) async {
    await (delete(transactions)
          ..where((t) =>
              t.poolLabel.equals(label) &
              t.direction.equals(adjustmentDirection)))
        .go();
    final rows = await (select(transactions)
          ..where((t) =>
              t.poolLabel.equals(label) &
              t.type.isIn(['custody_receive', 'custody_spend'])))
        .get();
    for (final r in rows) {
      await untagTransaction(r.id);
    }
  }

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
    // WAL lets separate connections (main app, tag card engine, headless
    // recorder engine) read/write the same file concurrently without
    // one write blocking/failing another — required given this app runs
    // multiple Flutter engines against the same sqlite file at once.
    return NativeDatabase.createInBackground(
      file,
      setup: (db) => db.execute('PRAGMA journal_mode=WAL;'),
    );
  });
}