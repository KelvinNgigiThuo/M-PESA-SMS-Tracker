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

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupMeta = const VerificationMeta('group');
  @override
  late final GeneratedColumn<String> group = GeneratedColumn<String>(
    'group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneMeta = const VerificationMeta('zone');
  @override
  late final GeneratedColumn<int> zone = GeneratedColumn<int>(
    'zone',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _manualBalanceMeta = const VerificationMeta(
    'manualBalance',
  );
  @override
  late final GeneratedColumn<double> manualBalance = GeneratedColumn<double>(
    'manual_balance',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manualBalanceSetAtMeta =
      const VerificationMeta('manualBalanceSetAt');
  @override
  late final GeneratedColumn<DateTime> manualBalanceSetAt =
      GeneratedColumn<DateTime>(
        'manual_balance_set_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    group,
    zone,
    openingBalance,
    manualBalance,
    manualBalanceSetAt,
    isActive,
    isHidden,
    isSystem,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group')) {
      context.handle(
        _groupMeta,
        group.isAcceptableOrUnknown(data['group']!, _groupMeta),
      );
    } else if (isInserting) {
      context.missing(_groupMeta);
    }
    if (data.containsKey('zone')) {
      context.handle(
        _zoneMeta,
        zone.isAcceptableOrUnknown(data['zone']!, _zoneMeta),
      );
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('manual_balance')) {
      context.handle(
        _manualBalanceMeta,
        manualBalance.isAcceptableOrUnknown(
          data['manual_balance']!,
          _manualBalanceMeta,
        ),
      );
    }
    if (data.containsKey('manual_balance_set_at')) {
      context.handle(
        _manualBalanceSetAtMeta,
        manualBalanceSetAt.isAcceptableOrUnknown(
          data['manual_balance_set_at']!,
          _manualBalanceSetAtMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      group: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group'],
      )!,
      zone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone'],
      )!,
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_balance'],
      )!,
      manualBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}manual_balance'],
      ),
      manualBalanceSetAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}manual_balance_set_at'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String name;
  final String group;
  final int zone;
  final double openingBalance;
  final double? manualBalance;
  final DateTime? manualBalanceSetAt;
  final bool isActive;
  final bool isHidden;
  final bool isSystem;
  final DateTime createdAt;
  const Account({
    required this.id,
    required this.name,
    required this.group,
    required this.zone,
    required this.openingBalance,
    this.manualBalance,
    this.manualBalanceSetAt,
    required this.isActive,
    required this.isHidden,
    required this.isSystem,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['group'] = Variable<String>(group);
    map['zone'] = Variable<int>(zone);
    map['opening_balance'] = Variable<double>(openingBalance);
    if (!nullToAbsent || manualBalance != null) {
      map['manual_balance'] = Variable<double>(manualBalance);
    }
    if (!nullToAbsent || manualBalanceSetAt != null) {
      map['manual_balance_set_at'] = Variable<DateTime>(manualBalanceSetAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['is_system'] = Variable<bool>(isSystem);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      group: Value(group),
      zone: Value(zone),
      openingBalance: Value(openingBalance),
      manualBalance: manualBalance == null && nullToAbsent
          ? const Value.absent()
          : Value(manualBalance),
      manualBalanceSetAt: manualBalanceSetAt == null && nullToAbsent
          ? const Value.absent()
          : Value(manualBalanceSetAt),
      isActive: Value(isActive),
      isHidden: Value(isHidden),
      isSystem: Value(isSystem),
      createdAt: Value(createdAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      group: serializer.fromJson<String>(json['group']),
      zone: serializer.fromJson<int>(json['zone']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      manualBalance: serializer.fromJson<double?>(json['manualBalance']),
      manualBalanceSetAt: serializer.fromJson<DateTime?>(
        json['manualBalanceSetAt'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'group': serializer.toJson<String>(group),
      'zone': serializer.toJson<int>(zone),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'manualBalance': serializer.toJson<double?>(manualBalance),
      'manualBalanceSetAt': serializer.toJson<DateTime?>(manualBalanceSetAt),
      'isActive': serializer.toJson<bool>(isActive),
      'isHidden': serializer.toJson<bool>(isHidden),
      'isSystem': serializer.toJson<bool>(isSystem),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Account copyWith({
    int? id,
    String? name,
    String? group,
    int? zone,
    double? openingBalance,
    Value<double?> manualBalance = const Value.absent(),
    Value<DateTime?> manualBalanceSetAt = const Value.absent(),
    bool? isActive,
    bool? isHidden,
    bool? isSystem,
    DateTime? createdAt,
  }) => Account(
    id: id ?? this.id,
    name: name ?? this.name,
    group: group ?? this.group,
    zone: zone ?? this.zone,
    openingBalance: openingBalance ?? this.openingBalance,
    manualBalance: manualBalance.present
        ? manualBalance.value
        : this.manualBalance,
    manualBalanceSetAt: manualBalanceSetAt.present
        ? manualBalanceSetAt.value
        : this.manualBalanceSetAt,
    isActive: isActive ?? this.isActive,
    isHidden: isHidden ?? this.isHidden,
    isSystem: isSystem ?? this.isSystem,
    createdAt: createdAt ?? this.createdAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      group: data.group.present ? data.group.value : this.group,
      zone: data.zone.present ? data.zone.value : this.zone,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      manualBalance: data.manualBalance.present
          ? data.manualBalance.value
          : this.manualBalance,
      manualBalanceSetAt: data.manualBalanceSetAt.present
          ? data.manualBalanceSetAt.value
          : this.manualBalanceSetAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('group: $group, ')
          ..write('zone: $zone, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('manualBalance: $manualBalance, ')
          ..write('manualBalanceSetAt: $manualBalanceSetAt, ')
          ..write('isActive: $isActive, ')
          ..write('isHidden: $isHidden, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    group,
    zone,
    openingBalance,
    manualBalance,
    manualBalanceSetAt,
    isActive,
    isHidden,
    isSystem,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.name == this.name &&
          other.group == this.group &&
          other.zone == this.zone &&
          other.openingBalance == this.openingBalance &&
          other.manualBalance == this.manualBalance &&
          other.manualBalanceSetAt == this.manualBalanceSetAt &&
          other.isActive == this.isActive &&
          other.isHidden == this.isHidden &&
          other.isSystem == this.isSystem &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> group;
  final Value<int> zone;
  final Value<double> openingBalance;
  final Value<double?> manualBalance;
  final Value<DateTime?> manualBalanceSetAt;
  final Value<bool> isActive;
  final Value<bool> isHidden;
  final Value<bool> isSystem;
  final Value<DateTime> createdAt;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.group = const Value.absent(),
    this.zone = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.manualBalance = const Value.absent(),
    this.manualBalanceSetAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String group,
    this.zone = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.manualBalance = const Value.absent(),
    this.manualBalanceSetAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.isSystem = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       group = Value(group),
       createdAt = Value(createdAt);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? group,
    Expression<int>? zone,
    Expression<double>? openingBalance,
    Expression<double>? manualBalance,
    Expression<DateTime>? manualBalanceSetAt,
    Expression<bool>? isActive,
    Expression<bool>? isHidden,
    Expression<bool>? isSystem,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (group != null) 'group': group,
      if (zone != null) 'zone': zone,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (manualBalance != null) 'manual_balance': manualBalance,
      if (manualBalanceSetAt != null)
        'manual_balance_set_at': manualBalanceSetAt,
      if (isActive != null) 'is_active': isActive,
      if (isHidden != null) 'is_hidden': isHidden,
      if (isSystem != null) 'is_system': isSystem,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? group,
    Value<int>? zone,
    Value<double>? openingBalance,
    Value<double?>? manualBalance,
    Value<DateTime?>? manualBalanceSetAt,
    Value<bool>? isActive,
    Value<bool>? isHidden,
    Value<bool>? isSystem,
    Value<DateTime>? createdAt,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      group: group ?? this.group,
      zone: zone ?? this.zone,
      openingBalance: openingBalance ?? this.openingBalance,
      manualBalance: manualBalance ?? this.manualBalance,
      manualBalanceSetAt: manualBalanceSetAt ?? this.manualBalanceSetAt,
      isActive: isActive ?? this.isActive,
      isHidden: isHidden ?? this.isHidden,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (group.present) {
      map['group'] = Variable<String>(group.value);
    }
    if (zone.present) {
      map['zone'] = Variable<int>(zone.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (manualBalance.present) {
      map['manual_balance'] = Variable<double>(manualBalance.value);
    }
    if (manualBalanceSetAt.present) {
      map['manual_balance_set_at'] = Variable<DateTime>(
        manualBalanceSetAt.value,
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('group: $group, ')
          ..write('zone: $zone, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('manualBalance: $manualBalance, ')
          ..write('manualBalanceSetAt: $manualBalanceSetAt, ')
          ..write('isActive: $isActive, ')
          ..write('isHidden: $isHidden, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    direction,
    isSystem,
    isActive,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String direction;
  final bool isSystem;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  const Category({
    required this.id,
    required this.name,
    required this.direction,
    required this.isSystem,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['direction'] = Variable<String>(direction);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      direction: Value(direction),
      isSystem: Value(isSystem),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      direction: serializer.fromJson<String>(json['direction']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'direction': serializer.toJson<String>(direction),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? direction,
    bool? isSystem,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    direction: direction ?? this.direction,
    isSystem: isSystem ?? this.isSystem,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      direction: data.direction.present ? data.direction.value : this.direction,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('direction: $direction, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    direction,
    isSystem,
    isActive,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.direction == this.direction &&
          other.isSystem == this.isSystem &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> direction;
  final Value<bool> isSystem;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.direction = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String direction,
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       direction = Value(direction),
       createdAt = Value(createdAt);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? direction,
    Expression<bool>? isSystem,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (direction != null) 'direction': direction,
      if (isSystem != null) 'is_system': isSystem,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? direction,
    Value<bool>? isSystem,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      direction: direction ?? this.direction,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('direction: $direction, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    accounts,
    categories,
  ];
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
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      required String name,
      required String group,
      Value<int> zone,
      Value<double> openingBalance,
      Value<double?> manualBalance,
      Value<DateTime?> manualBalanceSetAt,
      Value<bool> isActive,
      Value<bool> isHidden,
      Value<bool> isSystem,
      required DateTime createdAt,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> group,
      Value<int> zone,
      Value<double> openingBalance,
      Value<double?> manualBalance,
      Value<DateTime?> manualBalanceSetAt,
      Value<bool> isActive,
      Value<bool> isHidden,
      Value<bool> isSystem,
      Value<DateTime> createdAt,
    });

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get manualBalance => $composableBuilder(
    column: $table.manualBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get manualBalanceSetAt => $composableBuilder(
    column: $table.manualBalanceSetAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get group => $composableBuilder(
    column: $table.group,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zone => $composableBuilder(
    column: $table.zone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get manualBalance => $composableBuilder(
    column: $table.manualBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get manualBalanceSetAt => $composableBuilder(
    column: $table.manualBalanceSetAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  GeneratedColumn<int> get zone =>
      $composableBuilder(column: $table.zone, builder: (column) => column);

  GeneratedColumn<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get manualBalance => $composableBuilder(
    column: $table.manualBalance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get manualBalanceSetAt => $composableBuilder(
    column: $table.manualBalanceSetAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> group = const Value.absent(),
                Value<int> zone = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<double?> manualBalance = const Value.absent(),
                Value<DateTime?> manualBalanceSetAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                group: group,
                zone: zone,
                openingBalance: openingBalance,
                manualBalance: manualBalance,
                manualBalanceSetAt: manualBalanceSetAt,
                isActive: isActive,
                isHidden: isHidden,
                isSystem: isSystem,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String group,
                Value<int> zone = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<double?> manualBalance = const Value.absent(),
                Value<DateTime?> manualBalanceSetAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                required DateTime createdAt,
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                group: group,
                zone: zone,
                openingBalance: openingBalance,
                manualBalance: manualBalance,
                manualBalanceSetAt: manualBalanceSetAt,
                isActive: isActive,
                isHidden: isHidden,
                isSystem: isSystem,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String direction,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<int> sortOrder,
      required DateTime createdAt,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> direction,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                direction: direction,
                isSystem: isSystem,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String direction,
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                direction: direction,
                isSystem: isSystem,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
}
