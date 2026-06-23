// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _txCodeMeta = const VerificationMeta('txCode');
  @override
  late final GeneratedColumn<String> txCode = GeneratedColumn<String>(
    'tx_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txCostMeta = const VerificationMeta('txCost');
  @override
  late final GeneratedColumn<double> txCost = GeneratedColumn<double>(
    'tx_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _recipientMeta = const VerificationMeta(
    'recipient',
  );
  @override
  late final GeneratedColumn<String> recipient = GeneratedColumn<String>(
    'recipient',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bucketNameMeta = const VerificationMeta(
    'bucketName',
  );
  @override
  late final GeneratedColumn<String> bucketName = GeneratedColumn<String>(
    'bucket_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _poolLabelMeta = const VerificationMeta(
    'poolLabel',
  );
  @override
  late final GeneratedColumn<String> poolLabel = GeneratedColumn<String>(
    'pool_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivableLabelMeta = const VerificationMeta(
    'receivableLabel',
  );
  @override
  late final GeneratedColumn<String> receivableLabel = GeneratedColumn<String>(
    'receivable_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _balanceAfterMeta = const VerificationMeta(
    'balanceAfter',
  );
  @override
  late final GeneratedColumn<double> balanceAfter = GeneratedColumn<double>(
    'balance_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _rawSmsMeta = const VerificationMeta('rawSms');
  @override
  late final GeneratedColumn<String> rawSms = GeneratedColumn<String>(
    'raw_sms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTaggedMeta = const VerificationMeta(
    'isTagged',
  );
  @override
  late final GeneratedColumn<bool> isTagged = GeneratedColumn<bool>(
    'is_tagged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tagged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    txCode,
    amount,
    txCost,
    recipient,
    direction,
    type,
    category,
    bucketName,
    poolLabel,
    receivableLabel,
    balanceAfter,
    rawSms,
    createdAt,
    isTagged,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tx_code')) {
      context.handle(
        _txCodeMeta,
        txCode.isAcceptableOrUnknown(data['tx_code']!, _txCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_txCodeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('tx_cost')) {
      context.handle(
        _txCostMeta,
        txCost.isAcceptableOrUnknown(data['tx_cost']!, _txCostMeta),
      );
    }
    if (data.containsKey('recipient')) {
      context.handle(
        _recipientMeta,
        recipient.isAcceptableOrUnknown(data['recipient']!, _recipientMeta),
      );
    } else if (isInserting) {
      context.missing(_recipientMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('bucket_name')) {
      context.handle(
        _bucketNameMeta,
        bucketName.isAcceptableOrUnknown(data['bucket_name']!, _bucketNameMeta),
      );
    }
    if (data.containsKey('pool_label')) {
      context.handle(
        _poolLabelMeta,
        poolLabel.isAcceptableOrUnknown(data['pool_label']!, _poolLabelMeta),
      );
    }
    if (data.containsKey('receivable_label')) {
      context.handle(
        _receivableLabelMeta,
        receivableLabel.isAcceptableOrUnknown(
          data['receivable_label']!,
          _receivableLabelMeta,
        ),
      );
    }
    if (data.containsKey('balance_after')) {
      context.handle(
        _balanceAfterMeta,
        balanceAfter.isAcceptableOrUnknown(
          data['balance_after']!,
          _balanceAfterMeta,
        ),
      );
    }
    if (data.containsKey('raw_sms')) {
      context.handle(
        _rawSmsMeta,
        rawSms.isAcceptableOrUnknown(data['raw_sms']!, _rawSmsMeta),
      );
    } else if (isInserting) {
      context.missing(_rawSmsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_tagged')) {
      context.handle(
        _isTaggedMeta,
        isTagged.isAcceptableOrUnknown(data['is_tagged']!, _isTaggedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      txCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tx_code'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      txCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tx_cost'],
      )!,
      recipient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      bucketName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket_name'],
      ),
      poolLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pool_label'],
      ),
      receivableLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receivable_label'],
      ),
      balanceAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance_after'],
      )!,
      rawSms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_sms'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isTagged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tagged'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final String txCode;
  final double amount;
  final double txCost;
  final String recipient;
  final String direction;
  final String? type;
  final String? category;
  final String? bucketName;
  final String? poolLabel;
  final String? receivableLabel;
  final double balanceAfter;
  final String rawSms;
  final DateTime createdAt;
  final bool isTagged;
  const Transaction({
    required this.id,
    required this.txCode,
    required this.amount,
    required this.txCost,
    required this.recipient,
    required this.direction,
    this.type,
    this.category,
    this.bucketName,
    this.poolLabel,
    this.receivableLabel,
    required this.balanceAfter,
    required this.rawSms,
    required this.createdAt,
    required this.isTagged,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tx_code'] = Variable<String>(txCode);
    map['amount'] = Variable<double>(amount);
    map['tx_cost'] = Variable<double>(txCost);
    map['recipient'] = Variable<String>(recipient);
    map['direction'] = Variable<String>(direction);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || bucketName != null) {
      map['bucket_name'] = Variable<String>(bucketName);
    }
    if (!nullToAbsent || poolLabel != null) {
      map['pool_label'] = Variable<String>(poolLabel);
    }
    if (!nullToAbsent || receivableLabel != null) {
      map['receivable_label'] = Variable<String>(receivableLabel);
    }
    map['balance_after'] = Variable<double>(balanceAfter);
    map['raw_sms'] = Variable<String>(rawSms);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_tagged'] = Variable<bool>(isTagged);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      txCode: Value(txCode),
      amount: Value(amount),
      txCost: Value(txCost),
      recipient: Value(recipient),
      direction: Value(direction),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      bucketName: bucketName == null && nullToAbsent
          ? const Value.absent()
          : Value(bucketName),
      poolLabel: poolLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(poolLabel),
      receivableLabel: receivableLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(receivableLabel),
      balanceAfter: Value(balanceAfter),
      rawSms: Value(rawSms),
      createdAt: Value(createdAt),
      isTagged: Value(isTagged),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      txCode: serializer.fromJson<String>(json['txCode']),
      amount: serializer.fromJson<double>(json['amount']),
      txCost: serializer.fromJson<double>(json['txCost']),
      recipient: serializer.fromJson<String>(json['recipient']),
      direction: serializer.fromJson<String>(json['direction']),
      type: serializer.fromJson<String?>(json['type']),
      category: serializer.fromJson<String?>(json['category']),
      bucketName: serializer.fromJson<String?>(json['bucketName']),
      poolLabel: serializer.fromJson<String?>(json['poolLabel']),
      receivableLabel: serializer.fromJson<String?>(json['receivableLabel']),
      balanceAfter: serializer.fromJson<double>(json['balanceAfter']),
      rawSms: serializer.fromJson<String>(json['rawSms']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isTagged: serializer.fromJson<bool>(json['isTagged']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'txCode': serializer.toJson<String>(txCode),
      'amount': serializer.toJson<double>(amount),
      'txCost': serializer.toJson<double>(txCost),
      'recipient': serializer.toJson<String>(recipient),
      'direction': serializer.toJson<String>(direction),
      'type': serializer.toJson<String?>(type),
      'category': serializer.toJson<String?>(category),
      'bucketName': serializer.toJson<String?>(bucketName),
      'poolLabel': serializer.toJson<String?>(poolLabel),
      'receivableLabel': serializer.toJson<String?>(receivableLabel),
      'balanceAfter': serializer.toJson<double>(balanceAfter),
      'rawSms': serializer.toJson<String>(rawSms),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isTagged': serializer.toJson<bool>(isTagged),
    };
  }

  Transaction copyWith({
    int? id,
    String? txCode,
    double? amount,
    double? txCost,
    String? recipient,
    String? direction,
    Value<String?> type = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> bucketName = const Value.absent(),
    Value<String?> poolLabel = const Value.absent(),
    Value<String?> receivableLabel = const Value.absent(),
    double? balanceAfter,
    String? rawSms,
    DateTime? createdAt,
    bool? isTagged,
  }) => Transaction(
    id: id ?? this.id,
    txCode: txCode ?? this.txCode,
    amount: amount ?? this.amount,
    txCost: txCost ?? this.txCost,
    recipient: recipient ?? this.recipient,
    direction: direction ?? this.direction,
    type: type.present ? type.value : this.type,
    category: category.present ? category.value : this.category,
    bucketName: bucketName.present ? bucketName.value : this.bucketName,
    poolLabel: poolLabel.present ? poolLabel.value : this.poolLabel,
    receivableLabel: receivableLabel.present
        ? receivableLabel.value
        : this.receivableLabel,
    balanceAfter: balanceAfter ?? this.balanceAfter,
    rawSms: rawSms ?? this.rawSms,
    createdAt: createdAt ?? this.createdAt,
    isTagged: isTagged ?? this.isTagged,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      txCode: data.txCode.present ? data.txCode.value : this.txCode,
      amount: data.amount.present ? data.amount.value : this.amount,
      txCost: data.txCost.present ? data.txCost.value : this.txCost,
      recipient: data.recipient.present ? data.recipient.value : this.recipient,
      direction: data.direction.present ? data.direction.value : this.direction,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      bucketName: data.bucketName.present
          ? data.bucketName.value
          : this.bucketName,
      poolLabel: data.poolLabel.present ? data.poolLabel.value : this.poolLabel,
      receivableLabel: data.receivableLabel.present
          ? data.receivableLabel.value
          : this.receivableLabel,
      balanceAfter: data.balanceAfter.present
          ? data.balanceAfter.value
          : this.balanceAfter,
      rawSms: data.rawSms.present ? data.rawSms.value : this.rawSms,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isTagged: data.isTagged.present ? data.isTagged.value : this.isTagged,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('txCode: $txCode, ')
          ..write('amount: $amount, ')
          ..write('txCost: $txCost, ')
          ..write('recipient: $recipient, ')
          ..write('direction: $direction, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('bucketName: $bucketName, ')
          ..write('poolLabel: $poolLabel, ')
          ..write('receivableLabel: $receivableLabel, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('rawSms: $rawSms, ')
          ..write('createdAt: $createdAt, ')
          ..write('isTagged: $isTagged')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    txCode,
    amount,
    txCost,
    recipient,
    direction,
    type,
    category,
    bucketName,
    poolLabel,
    receivableLabel,
    balanceAfter,
    rawSms,
    createdAt,
    isTagged,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.txCode == this.txCode &&
          other.amount == this.amount &&
          other.txCost == this.txCost &&
          other.recipient == this.recipient &&
          other.direction == this.direction &&
          other.type == this.type &&
          other.category == this.category &&
          other.bucketName == this.bucketName &&
          other.poolLabel == this.poolLabel &&
          other.receivableLabel == this.receivableLabel &&
          other.balanceAfter == this.balanceAfter &&
          other.rawSms == this.rawSms &&
          other.createdAt == this.createdAt &&
          other.isTagged == this.isTagged);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<String> txCode;
  final Value<double> amount;
  final Value<double> txCost;
  final Value<String> recipient;
  final Value<String> direction;
  final Value<String?> type;
  final Value<String?> category;
  final Value<String?> bucketName;
  final Value<String?> poolLabel;
  final Value<String?> receivableLabel;
  final Value<double> balanceAfter;
  final Value<String> rawSms;
  final Value<DateTime> createdAt;
  final Value<bool> isTagged;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.txCode = const Value.absent(),
    this.amount = const Value.absent(),
    this.txCost = const Value.absent(),
    this.recipient = const Value.absent(),
    this.direction = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.bucketName = const Value.absent(),
    this.poolLabel = const Value.absent(),
    this.receivableLabel = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    this.rawSms = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isTagged = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String txCode,
    required double amount,
    this.txCost = const Value.absent(),
    required String recipient,
    required String direction,
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.bucketName = const Value.absent(),
    this.poolLabel = const Value.absent(),
    this.receivableLabel = const Value.absent(),
    this.balanceAfter = const Value.absent(),
    required String rawSms,
    required DateTime createdAt,
    this.isTagged = const Value.absent(),
  }) : txCode = Value(txCode),
       amount = Value(amount),
       recipient = Value(recipient),
       direction = Value(direction),
       rawSms = Value(rawSms),
       createdAt = Value(createdAt);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<String>? txCode,
    Expression<double>? amount,
    Expression<double>? txCost,
    Expression<String>? recipient,
    Expression<String>? direction,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? bucketName,
    Expression<String>? poolLabel,
    Expression<String>? receivableLabel,
    Expression<double>? balanceAfter,
    Expression<String>? rawSms,
    Expression<DateTime>? createdAt,
    Expression<bool>? isTagged,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (txCode != null) 'tx_code': txCode,
      if (amount != null) 'amount': amount,
      if (txCost != null) 'tx_cost': txCost,
      if (recipient != null) 'recipient': recipient,
      if (direction != null) 'direction': direction,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (bucketName != null) 'bucket_name': bucketName,
      if (poolLabel != null) 'pool_label': poolLabel,
      if (receivableLabel != null) 'receivable_label': receivableLabel,
      if (balanceAfter != null) 'balance_after': balanceAfter,
      if (rawSms != null) 'raw_sms': rawSms,
      if (createdAt != null) 'created_at': createdAt,
      if (isTagged != null) 'is_tagged': isTagged,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? txCode,
    Value<double>? amount,
    Value<double>? txCost,
    Value<String>? recipient,
    Value<String>? direction,
    Value<String?>? type,
    Value<String?>? category,
    Value<String?>? bucketName,
    Value<String?>? poolLabel,
    Value<String?>? receivableLabel,
    Value<double>? balanceAfter,
    Value<String>? rawSms,
    Value<DateTime>? createdAt,
    Value<bool>? isTagged,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      txCode: txCode ?? this.txCode,
      amount: amount ?? this.amount,
      txCost: txCost ?? this.txCost,
      recipient: recipient ?? this.recipient,
      direction: direction ?? this.direction,
      type: type ?? this.type,
      category: category ?? this.category,
      bucketName: bucketName ?? this.bucketName,
      poolLabel: poolLabel ?? this.poolLabel,
      receivableLabel: receivableLabel ?? this.receivableLabel,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      rawSms: rawSms ?? this.rawSms,
      createdAt: createdAt ?? this.createdAt,
      isTagged: isTagged ?? this.isTagged,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (txCode.present) {
      map['tx_code'] = Variable<String>(txCode.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (txCost.present) {
      map['tx_cost'] = Variable<double>(txCost.value);
    }
    if (recipient.present) {
      map['recipient'] = Variable<String>(recipient.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (bucketName.present) {
      map['bucket_name'] = Variable<String>(bucketName.value);
    }
    if (poolLabel.present) {
      map['pool_label'] = Variable<String>(poolLabel.value);
    }
    if (receivableLabel.present) {
      map['receivable_label'] = Variable<String>(receivableLabel.value);
    }
    if (balanceAfter.present) {
      map['balance_after'] = Variable<double>(balanceAfter.value);
    }
    if (rawSms.present) {
      map['raw_sms'] = Variable<String>(rawSms.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isTagged.present) {
      map['is_tagged'] = Variable<bool>(isTagged.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('txCode: $txCode, ')
          ..write('amount: $amount, ')
          ..write('txCost: $txCost, ')
          ..write('recipient: $recipient, ')
          ..write('direction: $direction, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('bucketName: $bucketName, ')
          ..write('poolLabel: $poolLabel, ')
          ..write('receivableLabel: $receivableLabel, ')
          ..write('balanceAfter: $balanceAfter, ')
          ..write('rawSms: $rawSms, ')
          ..write('createdAt: $createdAt, ')
          ..write('isTagged: $isTagged')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [transactions];
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required String txCode,
      required double amount,
      Value<double> txCost,
      required String recipient,
      required String direction,
      Value<String?> type,
      Value<String?> category,
      Value<String?> bucketName,
      Value<String?> poolLabel,
      Value<String?> receivableLabel,
      Value<double> balanceAfter,
      required String rawSms,
      required DateTime createdAt,
      Value<bool> isTagged,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<String> txCode,
      Value<double> amount,
      Value<double> txCost,
      Value<String> recipient,
      Value<String> direction,
      Value<String?> type,
      Value<String?> category,
      Value<String?> bucketName,
      Value<String?> poolLabel,
      Value<String?> receivableLabel,
      Value<double> balanceAfter,
      Value<String> rawSms,
      Value<DateTime> createdAt,
      Value<bool> isTagged,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get txCode => $composableBuilder(
    column: $table.txCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get txCost => $composableBuilder(
    column: $table.txCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucketName => $composableBuilder(
    column: $table.bucketName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get poolLabel => $composableBuilder(
    column: $table.poolLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receivableLabel => $composableBuilder(
    column: $table.receivableLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawSms => $composableBuilder(
    column: $table.rawSms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTagged => $composableBuilder(
    column: $table.isTagged,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get txCode => $composableBuilder(
    column: $table.txCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get txCost => $composableBuilder(
    column: $table.txCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucketName => $composableBuilder(
    column: $table.bucketName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get poolLabel => $composableBuilder(
    column: $table.poolLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receivableLabel => $composableBuilder(
    column: $table.receivableLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawSms => $composableBuilder(
    column: $table.rawSms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTagged => $composableBuilder(
    column: $table.isTagged,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get txCode =>
      $composableBuilder(column: $table.txCode, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get txCost =>
      $composableBuilder(column: $table.txCost, builder: (column) => column);

  GeneratedColumn<String> get recipient =>
      $composableBuilder(column: $table.recipient, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get bucketName => $composableBuilder(
    column: $table.bucketName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get poolLabel =>
      $composableBuilder(column: $table.poolLabel, builder: (column) => column);

  GeneratedColumn<String> get receivableLabel => $composableBuilder(
    column: $table.receivableLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get balanceAfter => $composableBuilder(
    column: $table.balanceAfter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawSms =>
      $composableBuilder(column: $table.rawSms, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isTagged =>
      $composableBuilder(column: $table.isTagged, builder: (column) => column);
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> txCode = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> txCost = const Value.absent(),
                Value<String> recipient = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> bucketName = const Value.absent(),
                Value<String?> poolLabel = const Value.absent(),
                Value<String?> receivableLabel = const Value.absent(),
                Value<double> balanceAfter = const Value.absent(),
                Value<String> rawSms = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isTagged = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                txCode: txCode,
                amount: amount,
                txCost: txCost,
                recipient: recipient,
                direction: direction,
                type: type,
                category: category,
                bucketName: bucketName,
                poolLabel: poolLabel,
                receivableLabel: receivableLabel,
                balanceAfter: balanceAfter,
                rawSms: rawSms,
                createdAt: createdAt,
                isTagged: isTagged,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String txCode,
                required double amount,
                Value<double> txCost = const Value.absent(),
                required String recipient,
                required String direction,
                Value<String?> type = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> bucketName = const Value.absent(),
                Value<String?> poolLabel = const Value.absent(),
                Value<String?> receivableLabel = const Value.absent(),
                Value<double> balanceAfter = const Value.absent(),
                required String rawSms,
                required DateTime createdAt,
                Value<bool> isTagged = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                txCode: txCode,
                amount: amount,
                txCost: txCost,
                recipient: recipient,
                direction: direction,
                type: type,
                category: category,
                bucketName: bucketName,
                poolLabel: poolLabel,
                receivableLabel: receivableLabel,
                balanceAfter: balanceAfter,
                rawSms: rawSms,
                createdAt: createdAt,
                isTagged: isTagged,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
