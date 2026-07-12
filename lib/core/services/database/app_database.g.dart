// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LayoutsTable extends Layouts with TableInfo<$LayoutsTable, LayoutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LayoutsTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('geral'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPresetMeta = const VerificationMeta(
    'isPreset',
  );
  @override
  late final GeneratedColumn<bool> isPreset = GeneratedColumn<bool>(
    'is_preset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shortcutMeta = const VerificationMeta(
    'shortcut',
  );
  @override
  late final GeneratedColumn<String> shortcut = GeneratedColumn<String>(
    'shortcut',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    isFavorite,
    isPreset,
    shortcut,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'layouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LayoutRow> instance, {
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_preset')) {
      context.handle(
        _isPresetMeta,
        isPreset.isAcceptableOrUnknown(data['is_preset']!, _isPresetMeta),
      );
    }
    if (data.containsKey('shortcut')) {
      context.handle(
        _shortcutMeta,
        shortcut.isAcceptableOrUnknown(data['shortcut']!, _shortcutMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LayoutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LayoutRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isPreset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preset'],
      )!,
      shortcut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shortcut'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LayoutsTable createAlias(String alias) {
    return $LayoutsTable(attachedDatabase, alias);
  }
}

class LayoutRow extends DataClass implements Insertable<LayoutRow> {
  final int id;
  final String name;
  final String category;
  final bool isFavorite;
  final bool isPreset;
  final String? shortcut;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LayoutRow({
    required this.id,
    required this.name,
    required this.category,
    required this.isFavorite,
    required this.isPreset,
    this.shortcut,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_preset'] = Variable<bool>(isPreset);
    if (!nullToAbsent || shortcut != null) {
      map['shortcut'] = Variable<String>(shortcut);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LayoutsCompanion toCompanion(bool nullToAbsent) {
    return LayoutsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      isFavorite: Value(isFavorite),
      isPreset: Value(isPreset),
      shortcut: shortcut == null && nullToAbsent
          ? const Value.absent()
          : Value(shortcut),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LayoutRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LayoutRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isPreset: serializer.fromJson<bool>(json['isPreset']),
      shortcut: serializer.fromJson<String?>(json['shortcut']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isPreset': serializer.toJson<bool>(isPreset),
      'shortcut': serializer.toJson<String?>(shortcut),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LayoutRow copyWith({
    int? id,
    String? name,
    String? category,
    bool? isFavorite,
    bool? isPreset,
    Value<String?> shortcut = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LayoutRow(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    isFavorite: isFavorite ?? this.isFavorite,
    isPreset: isPreset ?? this.isPreset,
    shortcut: shortcut.present ? shortcut.value : this.shortcut,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LayoutRow copyWithCompanion(LayoutsCompanion data) {
    return LayoutRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isPreset: data.isPreset.present ? data.isPreset.value : this.isPreset,
      shortcut: data.shortcut.present ? data.shortcut.value : this.shortcut,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LayoutRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isPreset: $isPreset, ')
          ..write('shortcut: $shortcut, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    isFavorite,
    isPreset,
    shortcut,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LayoutRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.isFavorite == this.isFavorite &&
          other.isPreset == this.isPreset &&
          other.shortcut == this.shortcut &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LayoutsCompanion extends UpdateCompanion<LayoutRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> category;
  final Value<bool> isFavorite;
  final Value<bool> isPreset;
  final Value<String?> shortcut;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const LayoutsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.shortcut = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  LayoutsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.shortcut = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<LayoutRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<bool>? isFavorite,
    Expression<bool>? isPreset,
    Expression<String>? shortcut,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isPreset != null) 'is_preset': isPreset,
      if (shortcut != null) 'shortcut': shortcut,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  LayoutsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? category,
    Value<bool>? isFavorite,
    Value<bool>? isPreset,
    Value<String?>? shortcut,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return LayoutsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isPreset: isPreset ?? this.isPreset,
      shortcut: shortcut ?? this.shortcut,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isPreset.present) {
      map['is_preset'] = Variable<bool>(isPreset.value);
    }
    if (shortcut.present) {
      map['shortcut'] = Variable<String>(shortcut.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LayoutsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isPreset: $isPreset, ')
          ..write('shortcut: $shortcut, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $LayoutRegionsTable extends LayoutRegions
    with TableInfo<$LayoutRegionsTable, LayoutRegionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LayoutRegionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _layoutIdMeta = const VerificationMeta(
    'layoutId',
  );
  @override
  late final GeneratedColumn<int> layoutId = GeneratedColumn<int>(
    'layout_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES layouts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#0A84FF'),
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
  static const VerificationMeta _appBundleIdMeta = const VerificationMeta(
    'appBundleId',
  );
  @override
  late final GeneratedColumn<String> appBundleId = GeneratedColumn<String>(
    'app_bundle_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appWindowTitleMeta = const VerificationMeta(
    'appWindowTitle',
  );
  @override
  late final GeneratedColumn<String> appWindowTitle = GeneratedColumn<String>(
    'app_window_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    layoutId,
    name,
    x,
    y,
    width,
    height,
    colorHex,
    sortOrder,
    appBundleId,
    appName,
    appWindowTitle,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'layout_regions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LayoutRegionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('layout_id')) {
      context.handle(
        _layoutIdMeta,
        layoutId.isAcceptableOrUnknown(data['layout_id']!, _layoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_layoutIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('app_bundle_id')) {
      context.handle(
        _appBundleIdMeta,
        appBundleId.isAcceptableOrUnknown(
          data['app_bundle_id']!,
          _appBundleIdMeta,
        ),
      );
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    }
    if (data.containsKey('app_window_title')) {
      context.handle(
        _appWindowTitleMeta,
        appWindowTitle.isAcceptableOrUnknown(
          data['app_window_title']!,
          _appWindowTitleMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LayoutRegionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LayoutRegionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      layoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}layout_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      appBundleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_bundle_id'],
      ),
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      ),
      appWindowTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_window_title'],
      ),
    );
  }

  @override
  $LayoutRegionsTable createAlias(String alias) {
    return $LayoutRegionsTable(attachedDatabase, alias);
  }
}

class LayoutRegionRow extends DataClass implements Insertable<LayoutRegionRow> {
  final int id;
  final int layoutId;
  final String name;
  final double x;
  final double y;
  final double width;
  final double height;
  final String colorHex;
  final int sortOrder;

  /// App associado à região — sempre recebe a janela desse app ao aplicar
  /// o layout (adicionados no schema v3).
  final String? appBundleId;
  final String? appName;

  /// Título da janela escolhida quando o app tem várias instâncias
  /// (adicionado no schema v5).
  final String? appWindowTitle;
  const LayoutRegionRow({
    required this.id,
    required this.layoutId,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.colorHex,
    required this.sortOrder,
    this.appBundleId,
    this.appName,
    this.appWindowTitle,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['layout_id'] = Variable<int>(layoutId);
    map['name'] = Variable<String>(name);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    map['color_hex'] = Variable<String>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || appBundleId != null) {
      map['app_bundle_id'] = Variable<String>(appBundleId);
    }
    if (!nullToAbsent || appName != null) {
      map['app_name'] = Variable<String>(appName);
    }
    if (!nullToAbsent || appWindowTitle != null) {
      map['app_window_title'] = Variable<String>(appWindowTitle);
    }
    return map;
  }

  LayoutRegionsCompanion toCompanion(bool nullToAbsent) {
    return LayoutRegionsCompanion(
      id: Value(id),
      layoutId: Value(layoutId),
      name: Value(name),
      x: Value(x),
      y: Value(y),
      width: Value(width),
      height: Value(height),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
      appBundleId: appBundleId == null && nullToAbsent
          ? const Value.absent()
          : Value(appBundleId),
      appName: appName == null && nullToAbsent
          ? const Value.absent()
          : Value(appName),
      appWindowTitle: appWindowTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(appWindowTitle),
    );
  }

  factory LayoutRegionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LayoutRegionRow(
      id: serializer.fromJson<int>(json['id']),
      layoutId: serializer.fromJson<int>(json['layoutId']),
      name: serializer.fromJson<String>(json['name']),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      appBundleId: serializer.fromJson<String?>(json['appBundleId']),
      appName: serializer.fromJson<String?>(json['appName']),
      appWindowTitle: serializer.fromJson<String?>(json['appWindowTitle']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'layoutId': serializer.toJson<int>(layoutId),
      'name': serializer.toJson<String>(name),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
      'colorHex': serializer.toJson<String>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'appBundleId': serializer.toJson<String?>(appBundleId),
      'appName': serializer.toJson<String?>(appName),
      'appWindowTitle': serializer.toJson<String?>(appWindowTitle),
    };
  }

  LayoutRegionRow copyWith({
    int? id,
    int? layoutId,
    String? name,
    double? x,
    double? y,
    double? width,
    double? height,
    String? colorHex,
    int? sortOrder,
    Value<String?> appBundleId = const Value.absent(),
    Value<String?> appName = const Value.absent(),
    Value<String?> appWindowTitle = const Value.absent(),
  }) => LayoutRegionRow(
    id: id ?? this.id,
    layoutId: layoutId ?? this.layoutId,
    name: name ?? this.name,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
    colorHex: colorHex ?? this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
    appBundleId: appBundleId.present ? appBundleId.value : this.appBundleId,
    appName: appName.present ? appName.value : this.appName,
    appWindowTitle: appWindowTitle.present
        ? appWindowTitle.value
        : this.appWindowTitle,
  );
  LayoutRegionRow copyWithCompanion(LayoutRegionsCompanion data) {
    return LayoutRegionRow(
      id: data.id.present ? data.id.value : this.id,
      layoutId: data.layoutId.present ? data.layoutId.value : this.layoutId,
      name: data.name.present ? data.name.value : this.name,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      appBundleId: data.appBundleId.present
          ? data.appBundleId.value
          : this.appBundleId,
      appName: data.appName.present ? data.appName.value : this.appName,
      appWindowTitle: data.appWindowTitle.present
          ? data.appWindowTitle.value
          : this.appWindowTitle,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LayoutRegionRow(')
          ..write('id: $id, ')
          ..write('layoutId: $layoutId, ')
          ..write('name: $name, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('appBundleId: $appBundleId, ')
          ..write('appName: $appName, ')
          ..write('appWindowTitle: $appWindowTitle')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    layoutId,
    name,
    x,
    y,
    width,
    height,
    colorHex,
    sortOrder,
    appBundleId,
    appName,
    appWindowTitle,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LayoutRegionRow &&
          other.id == this.id &&
          other.layoutId == this.layoutId &&
          other.name == this.name &&
          other.x == this.x &&
          other.y == this.y &&
          other.width == this.width &&
          other.height == this.height &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder &&
          other.appBundleId == this.appBundleId &&
          other.appName == this.appName &&
          other.appWindowTitle == this.appWindowTitle);
}

class LayoutRegionsCompanion extends UpdateCompanion<LayoutRegionRow> {
  final Value<int> id;
  final Value<int> layoutId;
  final Value<String> name;
  final Value<double> x;
  final Value<double> y;
  final Value<double> width;
  final Value<double> height;
  final Value<String> colorHex;
  final Value<int> sortOrder;
  final Value<String?> appBundleId;
  final Value<String?> appName;
  final Value<String?> appWindowTitle;
  const LayoutRegionsCompanion({
    this.id = const Value.absent(),
    this.layoutId = const Value.absent(),
    this.name = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.appBundleId = const Value.absent(),
    this.appName = const Value.absent(),
    this.appWindowTitle = const Value.absent(),
  });
  LayoutRegionsCompanion.insert({
    this.id = const Value.absent(),
    required int layoutId,
    required String name,
    required double x,
    required double y,
    required double width,
    required double height,
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.appBundleId = const Value.absent(),
    this.appName = const Value.absent(),
    this.appWindowTitle = const Value.absent(),
  }) : layoutId = Value(layoutId),
       name = Value(name),
       x = Value(x),
       y = Value(y),
       width = Value(width),
       height = Value(height);
  static Insertable<LayoutRegionRow> custom({
    Expression<int>? id,
    Expression<int>? layoutId,
    Expression<String>? name,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? width,
    Expression<double>? height,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<String>? appBundleId,
    Expression<String>? appName,
    Expression<String>? appWindowTitle,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (layoutId != null) 'layout_id': layoutId,
      if (name != null) 'name': name,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (appBundleId != null) 'app_bundle_id': appBundleId,
      if (appName != null) 'app_name': appName,
      if (appWindowTitle != null) 'app_window_title': appWindowTitle,
    });
  }

  LayoutRegionsCompanion copyWith({
    Value<int>? id,
    Value<int>? layoutId,
    Value<String>? name,
    Value<double>? x,
    Value<double>? y,
    Value<double>? width,
    Value<double>? height,
    Value<String>? colorHex,
    Value<int>? sortOrder,
    Value<String?>? appBundleId,
    Value<String?>? appName,
    Value<String?>? appWindowTitle,
  }) {
    return LayoutRegionsCompanion(
      id: id ?? this.id,
      layoutId: layoutId ?? this.layoutId,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      appBundleId: appBundleId ?? this.appBundleId,
      appName: appName ?? this.appName,
      appWindowTitle: appWindowTitle ?? this.appWindowTitle,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (layoutId.present) {
      map['layout_id'] = Variable<int>(layoutId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (appBundleId.present) {
      map['app_bundle_id'] = Variable<String>(appBundleId.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (appWindowTitle.present) {
      map['app_window_title'] = Variable<String>(appWindowTitle.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LayoutRegionsCompanion(')
          ..write('id: $id, ')
          ..write('layoutId: $layoutId, ')
          ..write('name: $name, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('appBundleId: $appBundleId, ')
          ..write('appName: $appName, ')
          ..write('appWindowTitle: $appWindowTitle')
          ..write(')'))
        .toString();
  }
}

class $AppliedLayoutsTable extends AppliedLayouts
    with TableInfo<$AppliedLayoutsTable, AppliedLayoutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppliedLayoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _monitorKeyMeta = const VerificationMeta(
    'monitorKey',
  );
  @override
  late final GeneratedColumn<String> monitorKey = GeneratedColumn<String>(
    'monitor_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _layoutIdMeta = const VerificationMeta(
    'layoutId',
  );
  @override
  late final GeneratedColumn<int> layoutId = GeneratedColumn<int>(
    'layout_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES layouts (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [monitorKey, layoutId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'applied_layouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppliedLayoutRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('monitor_key')) {
      context.handle(
        _monitorKeyMeta,
        monitorKey.isAcceptableOrUnknown(data['monitor_key']!, _monitorKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monitorKeyMeta);
    }
    if (data.containsKey('layout_id')) {
      context.handle(
        _layoutIdMeta,
        layoutId.isAcceptableOrUnknown(data['layout_id']!, _layoutIdMeta),
      );
    } else if (isInserting) {
      context.missing(_layoutIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {monitorKey};
  @override
  AppliedLayoutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppliedLayoutRow(
      monitorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monitor_key'],
      )!,
      layoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}layout_id'],
      )!,
    );
  }

  @override
  $AppliedLayoutsTable createAlias(String alias) {
    return $AppliedLayoutsTable(attachedDatabase, alias);
  }
}

class AppliedLayoutRow extends DataClass
    implements Insertable<AppliedLayoutRow> {
  final String monitorKey;
  final int layoutId;
  const AppliedLayoutRow({required this.monitorKey, required this.layoutId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['monitor_key'] = Variable<String>(monitorKey);
    map['layout_id'] = Variable<int>(layoutId);
    return map;
  }

  AppliedLayoutsCompanion toCompanion(bool nullToAbsent) {
    return AppliedLayoutsCompanion(
      monitorKey: Value(monitorKey),
      layoutId: Value(layoutId),
    );
  }

  factory AppliedLayoutRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppliedLayoutRow(
      monitorKey: serializer.fromJson<String>(json['monitorKey']),
      layoutId: serializer.fromJson<int>(json['layoutId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'monitorKey': serializer.toJson<String>(monitorKey),
      'layoutId': serializer.toJson<int>(layoutId),
    };
  }

  AppliedLayoutRow copyWith({String? monitorKey, int? layoutId}) =>
      AppliedLayoutRow(
        monitorKey: monitorKey ?? this.monitorKey,
        layoutId: layoutId ?? this.layoutId,
      );
  AppliedLayoutRow copyWithCompanion(AppliedLayoutsCompanion data) {
    return AppliedLayoutRow(
      monitorKey: data.monitorKey.present
          ? data.monitorKey.value
          : this.monitorKey,
      layoutId: data.layoutId.present ? data.layoutId.value : this.layoutId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppliedLayoutRow(')
          ..write('monitorKey: $monitorKey, ')
          ..write('layoutId: $layoutId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(monitorKey, layoutId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppliedLayoutRow &&
          other.monitorKey == this.monitorKey &&
          other.layoutId == this.layoutId);
}

class AppliedLayoutsCompanion extends UpdateCompanion<AppliedLayoutRow> {
  final Value<String> monitorKey;
  final Value<int> layoutId;
  final Value<int> rowid;
  const AppliedLayoutsCompanion({
    this.monitorKey = const Value.absent(),
    this.layoutId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppliedLayoutsCompanion.insert({
    required String monitorKey,
    required int layoutId,
    this.rowid = const Value.absent(),
  }) : monitorKey = Value(monitorKey),
       layoutId = Value(layoutId);
  static Insertable<AppliedLayoutRow> custom({
    Expression<String>? monitorKey,
    Expression<int>? layoutId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (monitorKey != null) 'monitor_key': monitorKey,
      if (layoutId != null) 'layout_id': layoutId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppliedLayoutsCompanion copyWith({
    Value<String>? monitorKey,
    Value<int>? layoutId,
    Value<int>? rowid,
  }) {
    return AppliedLayoutsCompanion(
      monitorKey: monitorKey ?? this.monitorKey,
      layoutId: layoutId ?? this.layoutId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (monitorKey.present) {
      map['monitor_key'] = Variable<String>(monitorKey.value);
    }
    if (layoutId.present) {
      map['layout_id'] = Variable<int>(layoutId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppliedLayoutsCompanion(')
          ..write('monitorKey: $monitorKey, ')
          ..write('layoutId: $layoutId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkspacesTable extends Workspaces
    with TableInfo<$WorkspacesTable, WorkspaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspacesTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('💻'),
  );
  static const VerificationMeta _gradientStartHexMeta = const VerificationMeta(
    'gradientStartHex',
  );
  @override
  late final GeneratedColumn<String> gradientStartHex = GeneratedColumn<String>(
    'gradient_start_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#0A84FF'),
  );
  static const VerificationMeta _gradientEndHexMeta = const VerificationMeta(
    'gradientEndHex',
  );
  @override
  late final GeneratedColumn<String> gradientEndHex = GeneratedColumn<String>(
    'gradient_end_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#40C8E0'),
  );
  static const VerificationMeta _shortcutMeta = const VerificationMeta(
    'shortcut',
  );
  @override
  late final GeneratedColumn<String> shortcut = GeneratedColumn<String>(
    'shortcut',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _layoutIdMeta = const VerificationMeta(
    'layoutId',
  );
  @override
  late final GeneratedColumn<int> layoutId = GeneratedColumn<int>(
    'layout_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES layouts (id) ON DELETE SET NULL',
    ),
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
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    emoji,
    gradientStartHex,
    gradientEndHex,
    shortcut,
    layoutId,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkspaceRow> instance, {
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
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('gradient_start_hex')) {
      context.handle(
        _gradientStartHexMeta,
        gradientStartHex.isAcceptableOrUnknown(
          data['gradient_start_hex']!,
          _gradientStartHexMeta,
        ),
      );
    }
    if (data.containsKey('gradient_end_hex')) {
      context.handle(
        _gradientEndHexMeta,
        gradientEndHex.isAcceptableOrUnknown(
          data['gradient_end_hex']!,
          _gradientEndHexMeta,
        ),
      );
    }
    if (data.containsKey('shortcut')) {
      context.handle(
        _shortcutMeta,
        shortcut.isAcceptableOrUnknown(data['shortcut']!, _shortcutMeta),
      );
    }
    if (data.containsKey('layout_id')) {
      context.handle(
        _layoutIdMeta,
        layoutId.isAcceptableOrUnknown(data['layout_id']!, _layoutIdMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkspaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      )!,
      gradientStartHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gradient_start_hex'],
      )!,
      gradientEndHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gradient_end_hex'],
      )!,
      shortcut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shortcut'],
      ),
      layoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}layout_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $WorkspacesTable createAlias(String alias) {
    return $WorkspacesTable(attachedDatabase, alias);
  }
}

class WorkspaceRow extends DataClass implements Insertable<WorkspaceRow> {
  final int id;
  final String name;
  final String emoji;
  final String gradientStartHex;
  final String gradientEndHex;
  final String? shortcut;
  final int? layoutId;
  final bool isActive;
  final int sortOrder;
  const WorkspaceRow({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gradientStartHex,
    required this.gradientEndHex,
    this.shortcut,
    this.layoutId,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['gradient_start_hex'] = Variable<String>(gradientStartHex);
    map['gradient_end_hex'] = Variable<String>(gradientEndHex);
    if (!nullToAbsent || shortcut != null) {
      map['shortcut'] = Variable<String>(shortcut);
    }
    if (!nullToAbsent || layoutId != null) {
      map['layout_id'] = Variable<int>(layoutId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WorkspacesCompanion toCompanion(bool nullToAbsent) {
    return WorkspacesCompanion(
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      gradientStartHex: Value(gradientStartHex),
      gradientEndHex: Value(gradientEndHex),
      shortcut: shortcut == null && nullToAbsent
          ? const Value.absent()
          : Value(shortcut),
      layoutId: layoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(layoutId),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory WorkspaceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      gradientStartHex: serializer.fromJson<String>(json['gradientStartHex']),
      gradientEndHex: serializer.fromJson<String>(json['gradientEndHex']),
      shortcut: serializer.fromJson<String?>(json['shortcut']),
      layoutId: serializer.fromJson<int?>(json['layoutId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'gradientStartHex': serializer.toJson<String>(gradientStartHex),
      'gradientEndHex': serializer.toJson<String>(gradientEndHex),
      'shortcut': serializer.toJson<String?>(shortcut),
      'layoutId': serializer.toJson<int?>(layoutId),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WorkspaceRow copyWith({
    int? id,
    String? name,
    String? emoji,
    String? gradientStartHex,
    String? gradientEndHex,
    Value<String?> shortcut = const Value.absent(),
    Value<int?> layoutId = const Value.absent(),
    bool? isActive,
    int? sortOrder,
  }) => WorkspaceRow(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    gradientStartHex: gradientStartHex ?? this.gradientStartHex,
    gradientEndHex: gradientEndHex ?? this.gradientEndHex,
    shortcut: shortcut.present ? shortcut.value : this.shortcut,
    layoutId: layoutId.present ? layoutId.value : this.layoutId,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  WorkspaceRow copyWithCompanion(WorkspacesCompanion data) {
    return WorkspaceRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      gradientStartHex: data.gradientStartHex.present
          ? data.gradientStartHex.value
          : this.gradientStartHex,
      gradientEndHex: data.gradientEndHex.present
          ? data.gradientEndHex.value
          : this.gradientEndHex,
      shortcut: data.shortcut.present ? data.shortcut.value : this.shortcut,
      layoutId: data.layoutId.present ? data.layoutId.value : this.layoutId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('gradientStartHex: $gradientStartHex, ')
          ..write('gradientEndHex: $gradientEndHex, ')
          ..write('shortcut: $shortcut, ')
          ..write('layoutId: $layoutId, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    emoji,
    gradientStartHex,
    gradientEndHex,
    shortcut,
    layoutId,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.gradientStartHex == this.gradientStartHex &&
          other.gradientEndHex == this.gradientEndHex &&
          other.shortcut == this.shortcut &&
          other.layoutId == this.layoutId &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class WorkspacesCompanion extends UpdateCompanion<WorkspaceRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<String> gradientStartHex;
  final Value<String> gradientEndHex;
  final Value<String?> shortcut;
  final Value<int?> layoutId;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  const WorkspacesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.gradientStartHex = const Value.absent(),
    this.gradientEndHex = const Value.absent(),
    this.shortcut = const Value.absent(),
    this.layoutId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WorkspacesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.emoji = const Value.absent(),
    this.gradientStartHex = const Value.absent(),
    this.gradientEndHex = const Value.absent(),
    this.shortcut = const Value.absent(),
    this.layoutId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<WorkspaceRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<String>? gradientStartHex,
    Expression<String>? gradientEndHex,
    Expression<String>? shortcut,
    Expression<int>? layoutId,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (gradientStartHex != null) 'gradient_start_hex': gradientStartHex,
      if (gradientEndHex != null) 'gradient_end_hex': gradientEndHex,
      if (shortcut != null) 'shortcut': shortcut,
      if (layoutId != null) 'layout_id': layoutId,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WorkspacesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? emoji,
    Value<String>? gradientStartHex,
    Value<String>? gradientEndHex,
    Value<String?>? shortcut,
    Value<int?>? layoutId,
    Value<bool>? isActive,
    Value<int>? sortOrder,
  }) {
    return WorkspacesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      gradientStartHex: gradientStartHex ?? this.gradientStartHex,
      gradientEndHex: gradientEndHex ?? this.gradientEndHex,
      shortcut: shortcut ?? this.shortcut,
      layoutId: layoutId ?? this.layoutId,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (gradientStartHex.present) {
      map['gradient_start_hex'] = Variable<String>(gradientStartHex.value);
    }
    if (gradientEndHex.present) {
      map['gradient_end_hex'] = Variable<String>(gradientEndHex.value);
    }
    if (shortcut.present) {
      map['shortcut'] = Variable<String>(shortcut.value);
    }
    if (layoutId.present) {
      map['layout_id'] = Variable<int>(layoutId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('gradientStartHex: $gradientStartHex, ')
          ..write('gradientEndHex: $gradientEndHex, ')
          ..write('shortcut: $shortcut, ')
          ..write('layoutId: $layoutId, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $WorkspaceAppsTable extends WorkspaceApps
    with TableInfo<$WorkspaceAppsTable, WorkspaceAppRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspaceAppsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bundleIdMeta = const VerificationMeta(
    'bundleId',
  );
  @override
  late final GeneratedColumn<String> bundleId = GeneratedColumn<String>(
    'bundle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionIdMeta = const VerificationMeta(
    'regionId',
  );
  @override
  late final GeneratedColumn<int> regionId = GeneratedColumn<int>(
    'region_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES layout_regions (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _monitorRefMeta = const VerificationMeta(
    'monitorRef',
  );
  @override
  late final GeneratedColumn<String> monitorRef = GeneratedColumn<String>(
    'monitor_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    bundleId,
    appName,
    regionId,
    monitorRef,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspace_apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkspaceAppRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('bundle_id')) {
      context.handle(
        _bundleIdMeta,
        bundleId.isAcceptableOrUnknown(data['bundle_id']!, _bundleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bundleIdMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('region_id')) {
      context.handle(
        _regionIdMeta,
        regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta),
      );
    }
    if (data.containsKey('monitor_ref')) {
      context.handle(
        _monitorRefMeta,
        monitorRef.isAcceptableOrUnknown(data['monitor_ref']!, _monitorRefMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkspaceAppRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceAppRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      )!,
      bundleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bundle_id'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      regionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}region_id'],
      ),
      monitorRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monitor_ref'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $WorkspaceAppsTable createAlias(String alias) {
    return $WorkspaceAppsTable(attachedDatabase, alias);
  }
}

class WorkspaceAppRow extends DataClass implements Insertable<WorkspaceAppRow> {
  final int id;
  final int workspaceId;
  final String bundleId;
  final String appName;
  final int? regionId;
  final String? monitorRef;
  final int sortOrder;
  const WorkspaceAppRow({
    required this.id,
    required this.workspaceId,
    required this.bundleId,
    required this.appName,
    this.regionId,
    this.monitorRef,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workspace_id'] = Variable<int>(workspaceId);
    map['bundle_id'] = Variable<String>(bundleId);
    map['app_name'] = Variable<String>(appName);
    if (!nullToAbsent || regionId != null) {
      map['region_id'] = Variable<int>(regionId);
    }
    if (!nullToAbsent || monitorRef != null) {
      map['monitor_ref'] = Variable<String>(monitorRef);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WorkspaceAppsCompanion toCompanion(bool nullToAbsent) {
    return WorkspaceAppsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      bundleId: Value(bundleId),
      appName: Value(appName),
      regionId: regionId == null && nullToAbsent
          ? const Value.absent()
          : Value(regionId),
      monitorRef: monitorRef == null && nullToAbsent
          ? const Value.absent()
          : Value(monitorRef),
      sortOrder: Value(sortOrder),
    );
  }

  factory WorkspaceAppRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceAppRow(
      id: serializer.fromJson<int>(json['id']),
      workspaceId: serializer.fromJson<int>(json['workspaceId']),
      bundleId: serializer.fromJson<String>(json['bundleId']),
      appName: serializer.fromJson<String>(json['appName']),
      regionId: serializer.fromJson<int?>(json['regionId']),
      monitorRef: serializer.fromJson<String?>(json['monitorRef']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workspaceId': serializer.toJson<int>(workspaceId),
      'bundleId': serializer.toJson<String>(bundleId),
      'appName': serializer.toJson<String>(appName),
      'regionId': serializer.toJson<int?>(regionId),
      'monitorRef': serializer.toJson<String?>(monitorRef),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WorkspaceAppRow copyWith({
    int? id,
    int? workspaceId,
    String? bundleId,
    String? appName,
    Value<int?> regionId = const Value.absent(),
    Value<String?> monitorRef = const Value.absent(),
    int? sortOrder,
  }) => WorkspaceAppRow(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    bundleId: bundleId ?? this.bundleId,
    appName: appName ?? this.appName,
    regionId: regionId.present ? regionId.value : this.regionId,
    monitorRef: monitorRef.present ? monitorRef.value : this.monitorRef,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  WorkspaceAppRow copyWithCompanion(WorkspaceAppsCompanion data) {
    return WorkspaceAppRow(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      bundleId: data.bundleId.present ? data.bundleId.value : this.bundleId,
      appName: data.appName.present ? data.appName.value : this.appName,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      monitorRef: data.monitorRef.present
          ? data.monitorRef.value
          : this.monitorRef,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceAppRow(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('bundleId: $bundleId, ')
          ..write('appName: $appName, ')
          ..write('regionId: $regionId, ')
          ..write('monitorRef: $monitorRef, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    bundleId,
    appName,
    regionId,
    monitorRef,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceAppRow &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.bundleId == this.bundleId &&
          other.appName == this.appName &&
          other.regionId == this.regionId &&
          other.monitorRef == this.monitorRef &&
          other.sortOrder == this.sortOrder);
}

class WorkspaceAppsCompanion extends UpdateCompanion<WorkspaceAppRow> {
  final Value<int> id;
  final Value<int> workspaceId;
  final Value<String> bundleId;
  final Value<String> appName;
  final Value<int?> regionId;
  final Value<String?> monitorRef;
  final Value<int> sortOrder;
  const WorkspaceAppsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.bundleId = const Value.absent(),
    this.appName = const Value.absent(),
    this.regionId = const Value.absent(),
    this.monitorRef = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WorkspaceAppsCompanion.insert({
    this.id = const Value.absent(),
    required int workspaceId,
    required String bundleId,
    required String appName,
    this.regionId = const Value.absent(),
    this.monitorRef = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       bundleId = Value(bundleId),
       appName = Value(appName);
  static Insertable<WorkspaceAppRow> custom({
    Expression<int>? id,
    Expression<int>? workspaceId,
    Expression<String>? bundleId,
    Expression<String>? appName,
    Expression<int>? regionId,
    Expression<String>? monitorRef,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (bundleId != null) 'bundle_id': bundleId,
      if (appName != null) 'app_name': appName,
      if (regionId != null) 'region_id': regionId,
      if (monitorRef != null) 'monitor_ref': monitorRef,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WorkspaceAppsCompanion copyWith({
    Value<int>? id,
    Value<int>? workspaceId,
    Value<String>? bundleId,
    Value<String>? appName,
    Value<int?>? regionId,
    Value<String?>? monitorRef,
    Value<int>? sortOrder,
  }) {
    return WorkspaceAppsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      bundleId: bundleId ?? this.bundleId,
      appName: appName ?? this.appName,
      regionId: regionId ?? this.regionId,
      monitorRef: monitorRef ?? this.monitorRef,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (bundleId.present) {
      map['bundle_id'] = Variable<String>(bundleId.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (regionId.present) {
      map['region_id'] = Variable<int>(regionId.value);
    }
    if (monitorRef.present) {
      map['monitor_ref'] = Variable<String>(monitorRef.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceAppsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('bundleId: $bundleId, ')
          ..write('appName: $appName, ')
          ..write('regionId: $regionId, ')
          ..write('monitorRef: $monitorRef, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $MonitorProfilesTable extends MonitorProfiles
    with TableInfo<$MonitorProfilesTable, MonitorProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitorProfilesTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<int> workspaceId = GeneratedColumn<int>(
    'workspace_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspaces (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _layoutIdMeta = const VerificationMeta(
    'layoutId',
  );
  @override
  late final GeneratedColumn<int> layoutId = GeneratedColumn<int>(
    'layout_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES layouts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _autoApplyMeta = const VerificationMeta(
    'autoApply',
  );
  @override
  late final GeneratedColumn<bool> autoApply = GeneratedColumn<bool>(
    'auto_apply',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_apply" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fingerprint,
    workspaceId,
    layoutId,
    autoApply,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitor_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonitorProfileRow> instance, {
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
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    }
    if (data.containsKey('layout_id')) {
      context.handle(
        _layoutIdMeta,
        layoutId.isAcceptableOrUnknown(data['layout_id']!, _layoutIdMeta),
      );
    }
    if (data.containsKey('auto_apply')) {
      context.handle(
        _autoApplyMeta,
        autoApply.isAcceptableOrUnknown(data['auto_apply']!, _autoApplyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonitorProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitorProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}workspace_id'],
      ),
      layoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}layout_id'],
      ),
      autoApply: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_apply'],
      )!,
    );
  }

  @override
  $MonitorProfilesTable createAlias(String alias) {
    return $MonitorProfilesTable(attachedDatabase, alias);
  }
}

class MonitorProfileRow extends DataClass
    implements Insertable<MonitorProfileRow> {
  final int id;
  final String name;
  final String fingerprint;
  final int? workspaceId;
  final int? layoutId;
  final bool autoApply;
  const MonitorProfileRow({
    required this.id,
    required this.name,
    required this.fingerprint,
    this.workspaceId,
    this.layoutId,
    required this.autoApply,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['fingerprint'] = Variable<String>(fingerprint);
    if (!nullToAbsent || workspaceId != null) {
      map['workspace_id'] = Variable<int>(workspaceId);
    }
    if (!nullToAbsent || layoutId != null) {
      map['layout_id'] = Variable<int>(layoutId);
    }
    map['auto_apply'] = Variable<bool>(autoApply);
    return map;
  }

  MonitorProfilesCompanion toCompanion(bool nullToAbsent) {
    return MonitorProfilesCompanion(
      id: Value(id),
      name: Value(name),
      fingerprint: Value(fingerprint),
      workspaceId: workspaceId == null && nullToAbsent
          ? const Value.absent()
          : Value(workspaceId),
      layoutId: layoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(layoutId),
      autoApply: Value(autoApply),
    );
  }

  factory MonitorProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitorProfileRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      workspaceId: serializer.fromJson<int?>(json['workspaceId']),
      layoutId: serializer.fromJson<int?>(json['layoutId']),
      autoApply: serializer.fromJson<bool>(json['autoApply']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'workspaceId': serializer.toJson<int?>(workspaceId),
      'layoutId': serializer.toJson<int?>(layoutId),
      'autoApply': serializer.toJson<bool>(autoApply),
    };
  }

  MonitorProfileRow copyWith({
    int? id,
    String? name,
    String? fingerprint,
    Value<int?> workspaceId = const Value.absent(),
    Value<int?> layoutId = const Value.absent(),
    bool? autoApply,
  }) => MonitorProfileRow(
    id: id ?? this.id,
    name: name ?? this.name,
    fingerprint: fingerprint ?? this.fingerprint,
    workspaceId: workspaceId.present ? workspaceId.value : this.workspaceId,
    layoutId: layoutId.present ? layoutId.value : this.layoutId,
    autoApply: autoApply ?? this.autoApply,
  );
  MonitorProfileRow copyWithCompanion(MonitorProfilesCompanion data) {
    return MonitorProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      layoutId: data.layoutId.present ? data.layoutId.value : this.layoutId,
      autoApply: data.autoApply.present ? data.autoApply.value : this.autoApply,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitorProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('layoutId: $layoutId, ')
          ..write('autoApply: $autoApply')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, fingerprint, workspaceId, layoutId, autoApply);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitorProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.fingerprint == this.fingerprint &&
          other.workspaceId == this.workspaceId &&
          other.layoutId == this.layoutId &&
          other.autoApply == this.autoApply);
}

class MonitorProfilesCompanion extends UpdateCompanion<MonitorProfileRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> fingerprint;
  final Value<int?> workspaceId;
  final Value<int?> layoutId;
  final Value<bool> autoApply;
  const MonitorProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.layoutId = const Value.absent(),
    this.autoApply = const Value.absent(),
  });
  MonitorProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String fingerprint,
    this.workspaceId = const Value.absent(),
    this.layoutId = const Value.absent(),
    this.autoApply = const Value.absent(),
  }) : name = Value(name),
       fingerprint = Value(fingerprint);
  static Insertable<MonitorProfileRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? fingerprint,
    Expression<int>? workspaceId,
    Expression<int>? layoutId,
    Expression<bool>? autoApply,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (layoutId != null) 'layout_id': layoutId,
      if (autoApply != null) 'auto_apply': autoApply,
    });
  }

  MonitorProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? fingerprint,
    Value<int?>? workspaceId,
    Value<int?>? layoutId,
    Value<bool>? autoApply,
  }) {
    return MonitorProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fingerprint: fingerprint ?? this.fingerprint,
      workspaceId: workspaceId ?? this.workspaceId,
      layoutId: layoutId ?? this.layoutId,
      autoApply: autoApply ?? this.autoApply,
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
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<int>(workspaceId.value);
    }
    if (layoutId.present) {
      map['layout_id'] = Variable<int>(layoutId.value);
    }
    if (autoApply.present) {
      map['auto_apply'] = Variable<bool>(autoApply.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitorProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('layoutId: $layoutId, ')
          ..write('autoApply: $autoApply')
          ..write(')'))
        .toString();
  }
}

class $RulesTable extends Rules with TableInfo<$RulesTable, RuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bundleIdMeta = const VerificationMeta(
    'bundleId',
  );
  @override
  late final GeneratedColumn<String> bundleId = GeneratedColumn<String>(
    'bundle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  @override
  late final GeneratedColumn<String> targetValue = GeneratedColumn<String>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bundleId,
    appName,
    actionType,
    targetValue,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bundle_id')) {
      context.handle(
        _bundleIdMeta,
        bundleId.isAcceptableOrUnknown(data['bundle_id']!, _bundleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bundleIdMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bundleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bundle_id'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_value'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $RulesTable createAlias(String alias) {
    return $RulesTable(attachedDatabase, alias);
  }
}

class RuleRow extends DataClass implements Insertable<RuleRow> {
  final int id;
  final String bundleId;
  final String appName;

  /// Tipo da ação (ex.: `moveToRegion`, `moveToMonitor`, `applyLayout`).
  final String actionType;

  /// Alvo da ação (id da região, fingerprint do monitor, id do layout…).
  final String targetValue;
  final bool isActive;
  const RuleRow({
    required this.id,
    required this.bundleId,
    required this.appName,
    required this.actionType,
    required this.targetValue,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bundle_id'] = Variable<String>(bundleId);
    map['app_name'] = Variable<String>(appName);
    map['action_type'] = Variable<String>(actionType);
    map['target_value'] = Variable<String>(targetValue);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RulesCompanion toCompanion(bool nullToAbsent) {
    return RulesCompanion(
      id: Value(id),
      bundleId: Value(bundleId),
      appName: Value(appName),
      actionType: Value(actionType),
      targetValue: Value(targetValue),
      isActive: Value(isActive),
    );
  }

  factory RuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleRow(
      id: serializer.fromJson<int>(json['id']),
      bundleId: serializer.fromJson<String>(json['bundleId']),
      appName: serializer.fromJson<String>(json['appName']),
      actionType: serializer.fromJson<String>(json['actionType']),
      targetValue: serializer.fromJson<String>(json['targetValue']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bundleId': serializer.toJson<String>(bundleId),
      'appName': serializer.toJson<String>(appName),
      'actionType': serializer.toJson<String>(actionType),
      'targetValue': serializer.toJson<String>(targetValue),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  RuleRow copyWith({
    int? id,
    String? bundleId,
    String? appName,
    String? actionType,
    String? targetValue,
    bool? isActive,
  }) => RuleRow(
    id: id ?? this.id,
    bundleId: bundleId ?? this.bundleId,
    appName: appName ?? this.appName,
    actionType: actionType ?? this.actionType,
    targetValue: targetValue ?? this.targetValue,
    isActive: isActive ?? this.isActive,
  );
  RuleRow copyWithCompanion(RulesCompanion data) {
    return RuleRow(
      id: data.id.present ? data.id.value : this.id,
      bundleId: data.bundleId.present ? data.bundleId.value : this.bundleId,
      appName: data.appName.present ? data.appName.value : this.appName,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleRow(')
          ..write('id: $id, ')
          ..write('bundleId: $bundleId, ')
          ..write('appName: $appName, ')
          ..write('actionType: $actionType, ')
          ..write('targetValue: $targetValue, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bundleId, appName, actionType, targetValue, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleRow &&
          other.id == this.id &&
          other.bundleId == this.bundleId &&
          other.appName == this.appName &&
          other.actionType == this.actionType &&
          other.targetValue == this.targetValue &&
          other.isActive == this.isActive);
}

class RulesCompanion extends UpdateCompanion<RuleRow> {
  final Value<int> id;
  final Value<String> bundleId;
  final Value<String> appName;
  final Value<String> actionType;
  final Value<String> targetValue;
  final Value<bool> isActive;
  const RulesCompanion({
    this.id = const Value.absent(),
    this.bundleId = const Value.absent(),
    this.appName = const Value.absent(),
    this.actionType = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  RulesCompanion.insert({
    this.id = const Value.absent(),
    required String bundleId,
    required String appName,
    required String actionType,
    required String targetValue,
    this.isActive = const Value.absent(),
  }) : bundleId = Value(bundleId),
       appName = Value(appName),
       actionType = Value(actionType),
       targetValue = Value(targetValue);
  static Insertable<RuleRow> custom({
    Expression<int>? id,
    Expression<String>? bundleId,
    Expression<String>? appName,
    Expression<String>? actionType,
    Expression<String>? targetValue,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bundleId != null) 'bundle_id': bundleId,
      if (appName != null) 'app_name': appName,
      if (actionType != null) 'action_type': actionType,
      if (targetValue != null) 'target_value': targetValue,
      if (isActive != null) 'is_active': isActive,
    });
  }

  RulesCompanion copyWith({
    Value<int>? id,
    Value<String>? bundleId,
    Value<String>? appName,
    Value<String>? actionType,
    Value<String>? targetValue,
    Value<bool>? isActive,
  }) {
    return RulesCompanion(
      id: id ?? this.id,
      bundleId: bundleId ?? this.bundleId,
      appName: appName ?? this.appName,
      actionType: actionType ?? this.actionType,
      targetValue: targetValue ?? this.targetValue,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bundleId.present) {
      map['bundle_id'] = Variable<String>(bundleId.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<String>(targetValue.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RulesCompanion(')
          ..write('id: $id, ')
          ..write('bundleId: $bundleId, ')
          ..write('appName: $appName, ')
          ..write('actionType: $actionType, ')
          ..write('targetValue: $targetValue, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $ShortcutsTable extends Shortcuts
    with TableInfo<$ShortcutsTable, ShortcutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShortcutsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _comboMeta = const VerificationMeta('combo');
  @override
  late final GeneratedColumn<String> combo = GeneratedColumn<String>(
    'combo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, action, combo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shortcuts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShortcutRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('combo')) {
      context.handle(
        _comboMeta,
        combo.isAcceptableOrUnknown(data['combo']!, _comboMeta),
      );
    } else if (isInserting) {
      context.missing(_comboMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShortcutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShortcutRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      combo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}combo'],
      )!,
    );
  }

  @override
  $ShortcutsTable createAlias(String alias) {
    return $ShortcutsTable(attachedDatabase, alias);
  }
}

class ShortcutRow extends DataClass implements Insertable<ShortcutRow> {
  final int id;

  /// Identificador da ação (ex.: `applyLayout:3`, `centerWindow`).
  final String action;

  /// Combinação serializada (ex.: `alt+cmd+1`).
  final String combo;
  const ShortcutRow({
    required this.id,
    required this.action,
    required this.combo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action'] = Variable<String>(action);
    map['combo'] = Variable<String>(combo);
    return map;
  }

  ShortcutsCompanion toCompanion(bool nullToAbsent) {
    return ShortcutsCompanion(
      id: Value(id),
      action: Value(action),
      combo: Value(combo),
    );
  }

  factory ShortcutRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShortcutRow(
      id: serializer.fromJson<int>(json['id']),
      action: serializer.fromJson<String>(json['action']),
      combo: serializer.fromJson<String>(json['combo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'action': serializer.toJson<String>(action),
      'combo': serializer.toJson<String>(combo),
    };
  }

  ShortcutRow copyWith({int? id, String? action, String? combo}) => ShortcutRow(
    id: id ?? this.id,
    action: action ?? this.action,
    combo: combo ?? this.combo,
  );
  ShortcutRow copyWithCompanion(ShortcutsCompanion data) {
    return ShortcutRow(
      id: data.id.present ? data.id.value : this.id,
      action: data.action.present ? data.action.value : this.action,
      combo: data.combo.present ? data.combo.value : this.combo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShortcutRow(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('combo: $combo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, action, combo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShortcutRow &&
          other.id == this.id &&
          other.action == this.action &&
          other.combo == this.combo);
}

class ShortcutsCompanion extends UpdateCompanion<ShortcutRow> {
  final Value<int> id;
  final Value<String> action;
  final Value<String> combo;
  const ShortcutsCompanion({
    this.id = const Value.absent(),
    this.action = const Value.absent(),
    this.combo = const Value.absent(),
  });
  ShortcutsCompanion.insert({
    this.id = const Value.absent(),
    required String action,
    required String combo,
  }) : action = Value(action),
       combo = Value(combo);
  static Insertable<ShortcutRow> custom({
    Expression<int>? id,
    Expression<String>? action,
    Expression<String>? combo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (action != null) 'action': action,
      if (combo != null) 'combo': combo,
    });
  }

  ShortcutsCompanion copyWith({
    Value<int>? id,
    Value<String>? action,
    Value<String>? combo,
  }) {
    return ShortcutsCompanion(
      id: id ?? this.id,
      action: action ?? this.action,
      combo: combo ?? this.combo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (combo.present) {
      map['combo'] = Variable<String>(combo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShortcutsCompanion(')
          ..write('id: $id, ')
          ..write('action: $action, ')
          ..write('combo: $combo')
          ..write(')'))
        .toString();
  }
}

class $HistoryEntriesTable extends HistoryEntries
    with TableInfo<$HistoryEntriesTable, HistoryEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, title, subtitle, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }
}

class HistoryEntryRow extends DataClass implements Insertable<HistoryEntryRow> {
  final int id;
  final String type;
  final String title;
  final String? subtitle;
  final DateTime createdAt;
  const HistoryEntryRow({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      createdAt: Value(createdAt),
    );
  }

  factory HistoryEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntryRow(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HistoryEntryRow copyWith({
    int? id,
    String? type,
    String? title,
    Value<String?> subtitle = const Value.absent(),
    DateTime? createdAt,
  }) => HistoryEntryRow(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    createdAt: createdAt ?? this.createdAt,
  );
  HistoryEntryRow copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryEntryRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntryRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, title, subtitle, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntryRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.createdAt == this.createdAt);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryEntryRow> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> subtitle;
  final Value<DateTime> createdAt;
  const HistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String title,
    this.subtitle = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : type = Value(type),
       title = Value(title);
  static Insertable<HistoryEntryRow> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? title,
    Value<String?>? subtitle,
    Value<DateTime>? createdAt,
  }) {
    return HistoryEntriesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WindowPositionsTable extends WindowPositions
    with TableInfo<$WindowPositionsTable, WindowPositionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WindowPositionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bundleIdMeta = const VerificationMeta(
    'bundleId',
  );
  @override
  late final GeneratedColumn<String> bundleId = GeneratedColumn<String>(
    'bundle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monitorFingerprintMeta =
      const VerificationMeta('monitorFingerprint');
  @override
  late final GeneratedColumn<String> monitorFingerprint =
      GeneratedColumn<String>(
        'monitor_fingerprint',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<double> x = GeneratedColumn<double>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<double> y = GeneratedColumn<double>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<double> width = GeneratedColumn<double>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bundleId,
    monitorFingerprint,
    x,
    y,
    width,
    height,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'window_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WindowPositionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bundle_id')) {
      context.handle(
        _bundleIdMeta,
        bundleId.isAcceptableOrUnknown(data['bundle_id']!, _bundleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bundleIdMeta);
    }
    if (data.containsKey('monitor_fingerprint')) {
      context.handle(
        _monitorFingerprintMeta,
        monitorFingerprint.isAcceptableOrUnknown(
          data['monitor_fingerprint']!,
          _monitorFingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monitorFingerprintMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WindowPositionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WindowPositionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bundleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bundle_id'],
      )!,
      monitorFingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}monitor_fingerprint'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}y'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WindowPositionsTable createAlias(String alias) {
    return $WindowPositionsTable(attachedDatabase, alias);
  }
}

class WindowPositionRow extends DataClass
    implements Insertable<WindowPositionRow> {
  final int id;
  final String bundleId;
  final String monitorFingerprint;
  final double x;
  final double y;
  final double width;
  final double height;
  final DateTime updatedAt;
  const WindowPositionRow({
    required this.id,
    required this.bundleId,
    required this.monitorFingerprint,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bundle_id'] = Variable<String>(bundleId);
    map['monitor_fingerprint'] = Variable<String>(monitorFingerprint);
    map['x'] = Variable<double>(x);
    map['y'] = Variable<double>(y);
    map['width'] = Variable<double>(width);
    map['height'] = Variable<double>(height);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WindowPositionsCompanion toCompanion(bool nullToAbsent) {
    return WindowPositionsCompanion(
      id: Value(id),
      bundleId: Value(bundleId),
      monitorFingerprint: Value(monitorFingerprint),
      x: Value(x),
      y: Value(y),
      width: Value(width),
      height: Value(height),
      updatedAt: Value(updatedAt),
    );
  }

  factory WindowPositionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WindowPositionRow(
      id: serializer.fromJson<int>(json['id']),
      bundleId: serializer.fromJson<String>(json['bundleId']),
      monitorFingerprint: serializer.fromJson<String>(
        json['monitorFingerprint'],
      ),
      x: serializer.fromJson<double>(json['x']),
      y: serializer.fromJson<double>(json['y']),
      width: serializer.fromJson<double>(json['width']),
      height: serializer.fromJson<double>(json['height']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bundleId': serializer.toJson<String>(bundleId),
      'monitorFingerprint': serializer.toJson<String>(monitorFingerprint),
      'x': serializer.toJson<double>(x),
      'y': serializer.toJson<double>(y),
      'width': serializer.toJson<double>(width),
      'height': serializer.toJson<double>(height),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WindowPositionRow copyWith({
    int? id,
    String? bundleId,
    String? monitorFingerprint,
    double? x,
    double? y,
    double? width,
    double? height,
    DateTime? updatedAt,
  }) => WindowPositionRow(
    id: id ?? this.id,
    bundleId: bundleId ?? this.bundleId,
    monitorFingerprint: monitorFingerprint ?? this.monitorFingerprint,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WindowPositionRow copyWithCompanion(WindowPositionsCompanion data) {
    return WindowPositionRow(
      id: data.id.present ? data.id.value : this.id,
      bundleId: data.bundleId.present ? data.bundleId.value : this.bundleId,
      monitorFingerprint: data.monitorFingerprint.present
          ? data.monitorFingerprint.value
          : this.monitorFingerprint,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WindowPositionRow(')
          ..write('id: $id, ')
          ..write('bundleId: $bundleId, ')
          ..write('monitorFingerprint: $monitorFingerprint, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bundleId,
    monitorFingerprint,
    x,
    y,
    width,
    height,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WindowPositionRow &&
          other.id == this.id &&
          other.bundleId == this.bundleId &&
          other.monitorFingerprint == this.monitorFingerprint &&
          other.x == this.x &&
          other.y == this.y &&
          other.width == this.width &&
          other.height == this.height &&
          other.updatedAt == this.updatedAt);
}

class WindowPositionsCompanion extends UpdateCompanion<WindowPositionRow> {
  final Value<int> id;
  final Value<String> bundleId;
  final Value<String> monitorFingerprint;
  final Value<double> x;
  final Value<double> y;
  final Value<double> width;
  final Value<double> height;
  final Value<DateTime> updatedAt;
  const WindowPositionsCompanion({
    this.id = const Value.absent(),
    this.bundleId = const Value.absent(),
    this.monitorFingerprint = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WindowPositionsCompanion.insert({
    this.id = const Value.absent(),
    required String bundleId,
    required String monitorFingerprint,
    required double x,
    required double y,
    required double width,
    required double height,
    this.updatedAt = const Value.absent(),
  }) : bundleId = Value(bundleId),
       monitorFingerprint = Value(monitorFingerprint),
       x = Value(x),
       y = Value(y),
       width = Value(width),
       height = Value(height);
  static Insertable<WindowPositionRow> custom({
    Expression<int>? id,
    Expression<String>? bundleId,
    Expression<String>? monitorFingerprint,
    Expression<double>? x,
    Expression<double>? y,
    Expression<double>? width,
    Expression<double>? height,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bundleId != null) 'bundle_id': bundleId,
      if (monitorFingerprint != null) 'monitor_fingerprint': monitorFingerprint,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WindowPositionsCompanion copyWith({
    Value<int>? id,
    Value<String>? bundleId,
    Value<String>? monitorFingerprint,
    Value<double>? x,
    Value<double>? y,
    Value<double>? width,
    Value<double>? height,
    Value<DateTime>? updatedAt,
  }) {
    return WindowPositionsCompanion(
      id: id ?? this.id,
      bundleId: bundleId ?? this.bundleId,
      monitorFingerprint: monitorFingerprint ?? this.monitorFingerprint,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bundleId.present) {
      map['bundle_id'] = Variable<String>(bundleId.value);
    }
    if (monitorFingerprint.present) {
      map['monitor_fingerprint'] = Variable<String>(monitorFingerprint.value);
    }
    if (x.present) {
      map['x'] = Variable<double>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<double>(y.value);
    }
    if (width.present) {
      map['width'] = Variable<double>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WindowPositionsCompanion(')
          ..write('id: $id, ')
          ..write('bundleId: $bundleId, ')
          ..write('monitorFingerprint: $monitorFingerprint, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _themePreferenceMeta = const VerificationMeta(
    'themePreference',
  );
  @override
  late final GeneratedColumn<String> themePreference = GeneratedColumn<String>(
    'theme_preference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pt_BR'),
  );
  static const VerificationMeta _launchAtLoginMeta = const VerificationMeta(
    'launchAtLogin',
  );
  @override
  late final GeneratedColumn<bool> launchAtLogin = GeneratedColumn<bool>(
    'launch_at_login',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("launch_at_login" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _showMenuBarIconMeta = const VerificationMeta(
    'showMenuBarIcon',
  );
  @override
  late final GeneratedColumn<bool> showMenuBarIcon = GeneratedColumn<bool>(
    'show_menu_bar_icon',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_menu_bar_icon" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _showInDockMeta = const VerificationMeta(
    'showInDock',
  );
  @override
  late final GeneratedColumn<bool> showInDock = GeneratedColumn<bool>(
    'show_in_dock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("show_in_dock" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _magneticSnapMeta = const VerificationMeta(
    'magneticSnap',
  );
  @override
  late final GeneratedColumn<bool> magneticSnap = GeneratedColumn<bool>(
    'magnetic_snap',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("magnetic_snap" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _animateTransitionsMeta =
      const VerificationMeta('animateTransitions');
  @override
  late final GeneratedColumn<bool> animateTransitions = GeneratedColumn<bool>(
    'animate_transitions',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("animate_transitions" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _animationDurationMsMeta =
      const VerificationMeta('animationDurationMs');
  @override
  late final GeneratedColumn<int> animationDurationMs = GeneratedColumn<int>(
    'animation_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(200),
  );
  static const VerificationMeta _windowGapMeta = const VerificationMeta(
    'windowGap',
  );
  @override
  late final GeneratedColumn<double> windowGap = GeneratedColumn<double>(
    'window_gap',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _screenMarginMeta = const VerificationMeta(
    'screenMargin',
  );
  @override
  late final GeneratedColumn<double> screenMargin = GeneratedColumn<double>(
    'screen_margin',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _barTransparencyMeta = const VerificationMeta(
    'barTransparency',
  );
  @override
  late final GeneratedColumn<bool> barTransparency = GeneratedColumn<bool>(
    'bar_transparency',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bar_transparency" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _onboardingDoneMeta = const VerificationMeta(
    'onboardingDone',
  );
  @override
  late final GeneratedColumn<bool> onboardingDone = GeneratedColumn<bool>(
    'onboarding_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _snapToLayoutRegionsMeta =
      const VerificationMeta('snapToLayoutRegions');
  @override
  late final GeneratedColumn<bool> snapToLayoutRegions = GeneratedColumn<bool>(
    'snap_to_layout_regions',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("snap_to_layout_regions" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastAppliedLayoutIdMeta =
      const VerificationMeta('lastAppliedLayoutId');
  @override
  late final GeneratedColumn<int> lastAppliedLayoutId = GeneratedColumn<int>(
    'last_applied_layout_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAppliedMonitorIdMeta =
      const VerificationMeta('lastAppliedMonitorId');
  @override
  late final GeneratedColumn<int> lastAppliedMonitorId = GeneratedColumn<int>(
    'last_applied_monitor_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snapExcludedAppsMeta = const VerificationMeta(
    'snapExcludedApps',
  );
  @override
  late final GeneratedColumn<String> snapExcludedApps = GeneratedColumn<String>(
    'snap_excluded_apps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _preferredMonitorIdMeta =
      const VerificationMeta('preferredMonitorId');
  @override
  late final GeneratedColumn<int> preferredMonitorId = GeneratedColumn<int>(
    'preferred_monitor_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _featureTourDoneMeta = const VerificationMeta(
    'featureTourDone',
  );
  @override
  late final GeneratedColumn<bool> featureTourDone = GeneratedColumn<bool>(
    'feature_tour_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("feature_tour_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themePreference,
    language,
    launchAtLogin,
    showMenuBarIcon,
    showInDock,
    magneticSnap,
    animateTransitions,
    animationDurationMs,
    windowGap,
    screenMargin,
    barTransparency,
    onboardingDone,
    userName,
    snapToLayoutRegions,
    lastAppliedLayoutId,
    lastAppliedMonitorId,
    snapExcludedApps,
    preferredMonitorId,
    featureTourDone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_preference')) {
      context.handle(
        _themePreferenceMeta,
        themePreference.isAcceptableOrUnknown(
          data['theme_preference']!,
          _themePreferenceMeta,
        ),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('launch_at_login')) {
      context.handle(
        _launchAtLoginMeta,
        launchAtLogin.isAcceptableOrUnknown(
          data['launch_at_login']!,
          _launchAtLoginMeta,
        ),
      );
    }
    if (data.containsKey('show_menu_bar_icon')) {
      context.handle(
        _showMenuBarIconMeta,
        showMenuBarIcon.isAcceptableOrUnknown(
          data['show_menu_bar_icon']!,
          _showMenuBarIconMeta,
        ),
      );
    }
    if (data.containsKey('show_in_dock')) {
      context.handle(
        _showInDockMeta,
        showInDock.isAcceptableOrUnknown(
          data['show_in_dock']!,
          _showInDockMeta,
        ),
      );
    }
    if (data.containsKey('magnetic_snap')) {
      context.handle(
        _magneticSnapMeta,
        magneticSnap.isAcceptableOrUnknown(
          data['magnetic_snap']!,
          _magneticSnapMeta,
        ),
      );
    }
    if (data.containsKey('animate_transitions')) {
      context.handle(
        _animateTransitionsMeta,
        animateTransitions.isAcceptableOrUnknown(
          data['animate_transitions']!,
          _animateTransitionsMeta,
        ),
      );
    }
    if (data.containsKey('animation_duration_ms')) {
      context.handle(
        _animationDurationMsMeta,
        animationDurationMs.isAcceptableOrUnknown(
          data['animation_duration_ms']!,
          _animationDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('window_gap')) {
      context.handle(
        _windowGapMeta,
        windowGap.isAcceptableOrUnknown(data['window_gap']!, _windowGapMeta),
      );
    }
    if (data.containsKey('screen_margin')) {
      context.handle(
        _screenMarginMeta,
        screenMargin.isAcceptableOrUnknown(
          data['screen_margin']!,
          _screenMarginMeta,
        ),
      );
    }
    if (data.containsKey('bar_transparency')) {
      context.handle(
        _barTransparencyMeta,
        barTransparency.isAcceptableOrUnknown(
          data['bar_transparency']!,
          _barTransparencyMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_done')) {
      context.handle(
        _onboardingDoneMeta,
        onboardingDone.isAcceptableOrUnknown(
          data['onboarding_done']!,
          _onboardingDoneMeta,
        ),
      );
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    if (data.containsKey('snap_to_layout_regions')) {
      context.handle(
        _snapToLayoutRegionsMeta,
        snapToLayoutRegions.isAcceptableOrUnknown(
          data['snap_to_layout_regions']!,
          _snapToLayoutRegionsMeta,
        ),
      );
    }
    if (data.containsKey('last_applied_layout_id')) {
      context.handle(
        _lastAppliedLayoutIdMeta,
        lastAppliedLayoutId.isAcceptableOrUnknown(
          data['last_applied_layout_id']!,
          _lastAppliedLayoutIdMeta,
        ),
      );
    }
    if (data.containsKey('last_applied_monitor_id')) {
      context.handle(
        _lastAppliedMonitorIdMeta,
        lastAppliedMonitorId.isAcceptableOrUnknown(
          data['last_applied_monitor_id']!,
          _lastAppliedMonitorIdMeta,
        ),
      );
    }
    if (data.containsKey('snap_excluded_apps')) {
      context.handle(
        _snapExcludedAppsMeta,
        snapExcludedApps.isAcceptableOrUnknown(
          data['snap_excluded_apps']!,
          _snapExcludedAppsMeta,
        ),
      );
    }
    if (data.containsKey('preferred_monitor_id')) {
      context.handle(
        _preferredMonitorIdMeta,
        preferredMonitorId.isAcceptableOrUnknown(
          data['preferred_monitor_id']!,
          _preferredMonitorIdMeta,
        ),
      );
    }
    if (data.containsKey('feature_tour_done')) {
      context.handle(
        _featureTourDoneMeta,
        featureTourDone.isAcceptableOrUnknown(
          data['feature_tour_done']!,
          _featureTourDoneMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themePreference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_preference'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      launchAtLogin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}launch_at_login'],
      )!,
      showMenuBarIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_menu_bar_icon'],
      )!,
      showInDock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_in_dock'],
      )!,
      magneticSnap: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}magnetic_snap'],
      )!,
      animateTransitions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}animate_transitions'],
      )!,
      animationDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}animation_duration_ms'],
      )!,
      windowGap: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}window_gap'],
      )!,
      screenMargin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}screen_margin'],
      )!,
      barTransparency: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bar_transparency'],
      )!,
      onboardingDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_done'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      )!,
      snapToLayoutRegions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}snap_to_layout_regions'],
      )!,
      lastAppliedLayoutId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_applied_layout_id'],
      ),
      lastAppliedMonitorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_applied_monitor_id'],
      ),
      snapExcludedApps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snap_excluded_apps'],
      )!,
      preferredMonitorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preferred_monitor_id'],
      ),
      featureTourDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}feature_tour_done'],
      )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsRow extends DataClass implements Insertable<SettingsRow> {
  final int id;

  /// `system`, `light` ou `dark`.
  final String themePreference;
  final String language;
  final bool launchAtLogin;
  final bool showMenuBarIcon;
  final bool showInDock;
  final bool magneticSnap;
  final bool animateTransitions;
  final int animationDurationMs;
  final double windowGap;
  final double screenMargin;
  final bool barTransparency;

  /// Onboarding de primeiro uso já concluído (adicionada no schema v2).
  final bool onboardingDone;

  /// Nome do usuário, informado no onboarding (adicionada no schema v4).
  final String userName;

  /// Encaixe por regiões do último layout aplicado (adicionada no schema v7).
  final bool snapToLayoutRegions;

  /// Id do último layout aplicado, fonte das regiões de encaixe
  /// (adicionada no schema v7).
  final int? lastAppliedLayoutId;

  /// Monitor em que o último layout foi aplicado — as zonas de encaixe só
  /// aparecem nele (adicionada no schema v8).
  final int? lastAppliedMonitorId;

  /// Apps excluídos do encaixe ao arrastar, como JSON array de
  /// `{bundleId, appName}` (adicionada no schema v9).
  final String snapExcludedApps;

  /// Monitor padrão para aplicar layouts, escolhido no seletor da galeria;
  /// null = automático, pela janela em foco (adicionada no schema v10).
  final int? preferredMonitorId;

  /// Tour guiado de primeiro uso já exibido (adicionada no schema v11).
  final bool featureTourDone;
  const SettingsRow({
    required this.id,
    required this.themePreference,
    required this.language,
    required this.launchAtLogin,
    required this.showMenuBarIcon,
    required this.showInDock,
    required this.magneticSnap,
    required this.animateTransitions,
    required this.animationDurationMs,
    required this.windowGap,
    required this.screenMargin,
    required this.barTransparency,
    required this.onboardingDone,
    required this.userName,
    required this.snapToLayoutRegions,
    this.lastAppliedLayoutId,
    this.lastAppliedMonitorId,
    required this.snapExcludedApps,
    this.preferredMonitorId,
    required this.featureTourDone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_preference'] = Variable<String>(themePreference);
    map['language'] = Variable<String>(language);
    map['launch_at_login'] = Variable<bool>(launchAtLogin);
    map['show_menu_bar_icon'] = Variable<bool>(showMenuBarIcon);
    map['show_in_dock'] = Variable<bool>(showInDock);
    map['magnetic_snap'] = Variable<bool>(magneticSnap);
    map['animate_transitions'] = Variable<bool>(animateTransitions);
    map['animation_duration_ms'] = Variable<int>(animationDurationMs);
    map['window_gap'] = Variable<double>(windowGap);
    map['screen_margin'] = Variable<double>(screenMargin);
    map['bar_transparency'] = Variable<bool>(barTransparency);
    map['onboarding_done'] = Variable<bool>(onboardingDone);
    map['user_name'] = Variable<String>(userName);
    map['snap_to_layout_regions'] = Variable<bool>(snapToLayoutRegions);
    if (!nullToAbsent || lastAppliedLayoutId != null) {
      map['last_applied_layout_id'] = Variable<int>(lastAppliedLayoutId);
    }
    if (!nullToAbsent || lastAppliedMonitorId != null) {
      map['last_applied_monitor_id'] = Variable<int>(lastAppliedMonitorId);
    }
    map['snap_excluded_apps'] = Variable<String>(snapExcludedApps);
    if (!nullToAbsent || preferredMonitorId != null) {
      map['preferred_monitor_id'] = Variable<int>(preferredMonitorId);
    }
    map['feature_tour_done'] = Variable<bool>(featureTourDone);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      id: Value(id),
      themePreference: Value(themePreference),
      language: Value(language),
      launchAtLogin: Value(launchAtLogin),
      showMenuBarIcon: Value(showMenuBarIcon),
      showInDock: Value(showInDock),
      magneticSnap: Value(magneticSnap),
      animateTransitions: Value(animateTransitions),
      animationDurationMs: Value(animationDurationMs),
      windowGap: Value(windowGap),
      screenMargin: Value(screenMargin),
      barTransparency: Value(barTransparency),
      onboardingDone: Value(onboardingDone),
      userName: Value(userName),
      snapToLayoutRegions: Value(snapToLayoutRegions),
      lastAppliedLayoutId: lastAppliedLayoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAppliedLayoutId),
      lastAppliedMonitorId: lastAppliedMonitorId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAppliedMonitorId),
      snapExcludedApps: Value(snapExcludedApps),
      preferredMonitorId: preferredMonitorId == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredMonitorId),
      featureTourDone: Value(featureTourDone),
    );
  }

  factory SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsRow(
      id: serializer.fromJson<int>(json['id']),
      themePreference: serializer.fromJson<String>(json['themePreference']),
      language: serializer.fromJson<String>(json['language']),
      launchAtLogin: serializer.fromJson<bool>(json['launchAtLogin']),
      showMenuBarIcon: serializer.fromJson<bool>(json['showMenuBarIcon']),
      showInDock: serializer.fromJson<bool>(json['showInDock']),
      magneticSnap: serializer.fromJson<bool>(json['magneticSnap']),
      animateTransitions: serializer.fromJson<bool>(json['animateTransitions']),
      animationDurationMs: serializer.fromJson<int>(
        json['animationDurationMs'],
      ),
      windowGap: serializer.fromJson<double>(json['windowGap']),
      screenMargin: serializer.fromJson<double>(json['screenMargin']),
      barTransparency: serializer.fromJson<bool>(json['barTransparency']),
      onboardingDone: serializer.fromJson<bool>(json['onboardingDone']),
      userName: serializer.fromJson<String>(json['userName']),
      snapToLayoutRegions: serializer.fromJson<bool>(
        json['snapToLayoutRegions'],
      ),
      lastAppliedLayoutId: serializer.fromJson<int?>(
        json['lastAppliedLayoutId'],
      ),
      lastAppliedMonitorId: serializer.fromJson<int?>(
        json['lastAppliedMonitorId'],
      ),
      snapExcludedApps: serializer.fromJson<String>(json['snapExcludedApps']),
      preferredMonitorId: serializer.fromJson<int?>(json['preferredMonitorId']),
      featureTourDone: serializer.fromJson<bool>(json['featureTourDone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themePreference': serializer.toJson<String>(themePreference),
      'language': serializer.toJson<String>(language),
      'launchAtLogin': serializer.toJson<bool>(launchAtLogin),
      'showMenuBarIcon': serializer.toJson<bool>(showMenuBarIcon),
      'showInDock': serializer.toJson<bool>(showInDock),
      'magneticSnap': serializer.toJson<bool>(magneticSnap),
      'animateTransitions': serializer.toJson<bool>(animateTransitions),
      'animationDurationMs': serializer.toJson<int>(animationDurationMs),
      'windowGap': serializer.toJson<double>(windowGap),
      'screenMargin': serializer.toJson<double>(screenMargin),
      'barTransparency': serializer.toJson<bool>(barTransparency),
      'onboardingDone': serializer.toJson<bool>(onboardingDone),
      'userName': serializer.toJson<String>(userName),
      'snapToLayoutRegions': serializer.toJson<bool>(snapToLayoutRegions),
      'lastAppliedLayoutId': serializer.toJson<int?>(lastAppliedLayoutId),
      'lastAppliedMonitorId': serializer.toJson<int?>(lastAppliedMonitorId),
      'snapExcludedApps': serializer.toJson<String>(snapExcludedApps),
      'preferredMonitorId': serializer.toJson<int?>(preferredMonitorId),
      'featureTourDone': serializer.toJson<bool>(featureTourDone),
    };
  }

  SettingsRow copyWith({
    int? id,
    String? themePreference,
    String? language,
    bool? launchAtLogin,
    bool? showMenuBarIcon,
    bool? showInDock,
    bool? magneticSnap,
    bool? animateTransitions,
    int? animationDurationMs,
    double? windowGap,
    double? screenMargin,
    bool? barTransparency,
    bool? onboardingDone,
    String? userName,
    bool? snapToLayoutRegions,
    Value<int?> lastAppliedLayoutId = const Value.absent(),
    Value<int?> lastAppliedMonitorId = const Value.absent(),
    String? snapExcludedApps,
    Value<int?> preferredMonitorId = const Value.absent(),
    bool? featureTourDone,
  }) => SettingsRow(
    id: id ?? this.id,
    themePreference: themePreference ?? this.themePreference,
    language: language ?? this.language,
    launchAtLogin: launchAtLogin ?? this.launchAtLogin,
    showMenuBarIcon: showMenuBarIcon ?? this.showMenuBarIcon,
    showInDock: showInDock ?? this.showInDock,
    magneticSnap: magneticSnap ?? this.magneticSnap,
    animateTransitions: animateTransitions ?? this.animateTransitions,
    animationDurationMs: animationDurationMs ?? this.animationDurationMs,
    windowGap: windowGap ?? this.windowGap,
    screenMargin: screenMargin ?? this.screenMargin,
    barTransparency: barTransparency ?? this.barTransparency,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    userName: userName ?? this.userName,
    snapToLayoutRegions: snapToLayoutRegions ?? this.snapToLayoutRegions,
    lastAppliedLayoutId: lastAppliedLayoutId.present
        ? lastAppliedLayoutId.value
        : this.lastAppliedLayoutId,
    lastAppliedMonitorId: lastAppliedMonitorId.present
        ? lastAppliedMonitorId.value
        : this.lastAppliedMonitorId,
    snapExcludedApps: snapExcludedApps ?? this.snapExcludedApps,
    preferredMonitorId: preferredMonitorId.present
        ? preferredMonitorId.value
        : this.preferredMonitorId,
    featureTourDone: featureTourDone ?? this.featureTourDone,
  );
  SettingsRow copyWithCompanion(SettingsTableCompanion data) {
    return SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      themePreference: data.themePreference.present
          ? data.themePreference.value
          : this.themePreference,
      language: data.language.present ? data.language.value : this.language,
      launchAtLogin: data.launchAtLogin.present
          ? data.launchAtLogin.value
          : this.launchAtLogin,
      showMenuBarIcon: data.showMenuBarIcon.present
          ? data.showMenuBarIcon.value
          : this.showMenuBarIcon,
      showInDock: data.showInDock.present
          ? data.showInDock.value
          : this.showInDock,
      magneticSnap: data.magneticSnap.present
          ? data.magneticSnap.value
          : this.magneticSnap,
      animateTransitions: data.animateTransitions.present
          ? data.animateTransitions.value
          : this.animateTransitions,
      animationDurationMs: data.animationDurationMs.present
          ? data.animationDurationMs.value
          : this.animationDurationMs,
      windowGap: data.windowGap.present ? data.windowGap.value : this.windowGap,
      screenMargin: data.screenMargin.present
          ? data.screenMargin.value
          : this.screenMargin,
      barTransparency: data.barTransparency.present
          ? data.barTransparency.value
          : this.barTransparency,
      onboardingDone: data.onboardingDone.present
          ? data.onboardingDone.value
          : this.onboardingDone,
      userName: data.userName.present ? data.userName.value : this.userName,
      snapToLayoutRegions: data.snapToLayoutRegions.present
          ? data.snapToLayoutRegions.value
          : this.snapToLayoutRegions,
      lastAppliedLayoutId: data.lastAppliedLayoutId.present
          ? data.lastAppliedLayoutId.value
          : this.lastAppliedLayoutId,
      lastAppliedMonitorId: data.lastAppliedMonitorId.present
          ? data.lastAppliedMonitorId.value
          : this.lastAppliedMonitorId,
      snapExcludedApps: data.snapExcludedApps.present
          ? data.snapExcludedApps.value
          : this.snapExcludedApps,
      preferredMonitorId: data.preferredMonitorId.present
          ? data.preferredMonitorId.value
          : this.preferredMonitorId,
      featureTourDone: data.featureTourDone.present
          ? data.featureTourDone.value
          : this.featureTourDone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsRow(')
          ..write('id: $id, ')
          ..write('themePreference: $themePreference, ')
          ..write('language: $language, ')
          ..write('launchAtLogin: $launchAtLogin, ')
          ..write('showMenuBarIcon: $showMenuBarIcon, ')
          ..write('showInDock: $showInDock, ')
          ..write('magneticSnap: $magneticSnap, ')
          ..write('animateTransitions: $animateTransitions, ')
          ..write('animationDurationMs: $animationDurationMs, ')
          ..write('windowGap: $windowGap, ')
          ..write('screenMargin: $screenMargin, ')
          ..write('barTransparency: $barTransparency, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('userName: $userName, ')
          ..write('snapToLayoutRegions: $snapToLayoutRegions, ')
          ..write('lastAppliedLayoutId: $lastAppliedLayoutId, ')
          ..write('lastAppliedMonitorId: $lastAppliedMonitorId, ')
          ..write('snapExcludedApps: $snapExcludedApps, ')
          ..write('preferredMonitorId: $preferredMonitorId, ')
          ..write('featureTourDone: $featureTourDone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themePreference,
    language,
    launchAtLogin,
    showMenuBarIcon,
    showInDock,
    magneticSnap,
    animateTransitions,
    animationDurationMs,
    windowGap,
    screenMargin,
    barTransparency,
    onboardingDone,
    userName,
    snapToLayoutRegions,
    lastAppliedLayoutId,
    lastAppliedMonitorId,
    snapExcludedApps,
    preferredMonitorId,
    featureTourDone,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsRow &&
          other.id == this.id &&
          other.themePreference == this.themePreference &&
          other.language == this.language &&
          other.launchAtLogin == this.launchAtLogin &&
          other.showMenuBarIcon == this.showMenuBarIcon &&
          other.showInDock == this.showInDock &&
          other.magneticSnap == this.magneticSnap &&
          other.animateTransitions == this.animateTransitions &&
          other.animationDurationMs == this.animationDurationMs &&
          other.windowGap == this.windowGap &&
          other.screenMargin == this.screenMargin &&
          other.barTransparency == this.barTransparency &&
          other.onboardingDone == this.onboardingDone &&
          other.userName == this.userName &&
          other.snapToLayoutRegions == this.snapToLayoutRegions &&
          other.lastAppliedLayoutId == this.lastAppliedLayoutId &&
          other.lastAppliedMonitorId == this.lastAppliedMonitorId &&
          other.snapExcludedApps == this.snapExcludedApps &&
          other.preferredMonitorId == this.preferredMonitorId &&
          other.featureTourDone == this.featureTourDone);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsRow> {
  final Value<int> id;
  final Value<String> themePreference;
  final Value<String> language;
  final Value<bool> launchAtLogin;
  final Value<bool> showMenuBarIcon;
  final Value<bool> showInDock;
  final Value<bool> magneticSnap;
  final Value<bool> animateTransitions;
  final Value<int> animationDurationMs;
  final Value<double> windowGap;
  final Value<double> screenMargin;
  final Value<bool> barTransparency;
  final Value<bool> onboardingDone;
  final Value<String> userName;
  final Value<bool> snapToLayoutRegions;
  final Value<int?> lastAppliedLayoutId;
  final Value<int?> lastAppliedMonitorId;
  final Value<String> snapExcludedApps;
  final Value<int?> preferredMonitorId;
  final Value<bool> featureTourDone;
  const SettingsTableCompanion({
    this.id = const Value.absent(),
    this.themePreference = const Value.absent(),
    this.language = const Value.absent(),
    this.launchAtLogin = const Value.absent(),
    this.showMenuBarIcon = const Value.absent(),
    this.showInDock = const Value.absent(),
    this.magneticSnap = const Value.absent(),
    this.animateTransitions = const Value.absent(),
    this.animationDurationMs = const Value.absent(),
    this.windowGap = const Value.absent(),
    this.screenMargin = const Value.absent(),
    this.barTransparency = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.userName = const Value.absent(),
    this.snapToLayoutRegions = const Value.absent(),
    this.lastAppliedLayoutId = const Value.absent(),
    this.lastAppliedMonitorId = const Value.absent(),
    this.snapExcludedApps = const Value.absent(),
    this.preferredMonitorId = const Value.absent(),
    this.featureTourDone = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.themePreference = const Value.absent(),
    this.language = const Value.absent(),
    this.launchAtLogin = const Value.absent(),
    this.showMenuBarIcon = const Value.absent(),
    this.showInDock = const Value.absent(),
    this.magneticSnap = const Value.absent(),
    this.animateTransitions = const Value.absent(),
    this.animationDurationMs = const Value.absent(),
    this.windowGap = const Value.absent(),
    this.screenMargin = const Value.absent(),
    this.barTransparency = const Value.absent(),
    this.onboardingDone = const Value.absent(),
    this.userName = const Value.absent(),
    this.snapToLayoutRegions = const Value.absent(),
    this.lastAppliedLayoutId = const Value.absent(),
    this.lastAppliedMonitorId = const Value.absent(),
    this.snapExcludedApps = const Value.absent(),
    this.preferredMonitorId = const Value.absent(),
    this.featureTourDone = const Value.absent(),
  });
  static Insertable<SettingsRow> custom({
    Expression<int>? id,
    Expression<String>? themePreference,
    Expression<String>? language,
    Expression<bool>? launchAtLogin,
    Expression<bool>? showMenuBarIcon,
    Expression<bool>? showInDock,
    Expression<bool>? magneticSnap,
    Expression<bool>? animateTransitions,
    Expression<int>? animationDurationMs,
    Expression<double>? windowGap,
    Expression<double>? screenMargin,
    Expression<bool>? barTransparency,
    Expression<bool>? onboardingDone,
    Expression<String>? userName,
    Expression<bool>? snapToLayoutRegions,
    Expression<int>? lastAppliedLayoutId,
    Expression<int>? lastAppliedMonitorId,
    Expression<String>? snapExcludedApps,
    Expression<int>? preferredMonitorId,
    Expression<bool>? featureTourDone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themePreference != null) 'theme_preference': themePreference,
      if (language != null) 'language': language,
      if (launchAtLogin != null) 'launch_at_login': launchAtLogin,
      if (showMenuBarIcon != null) 'show_menu_bar_icon': showMenuBarIcon,
      if (showInDock != null) 'show_in_dock': showInDock,
      if (magneticSnap != null) 'magnetic_snap': magneticSnap,
      if (animateTransitions != null) 'animate_transitions': animateTransitions,
      if (animationDurationMs != null)
        'animation_duration_ms': animationDurationMs,
      if (windowGap != null) 'window_gap': windowGap,
      if (screenMargin != null) 'screen_margin': screenMargin,
      if (barTransparency != null) 'bar_transparency': barTransparency,
      if (onboardingDone != null) 'onboarding_done': onboardingDone,
      if (userName != null) 'user_name': userName,
      if (snapToLayoutRegions != null)
        'snap_to_layout_regions': snapToLayoutRegions,
      if (lastAppliedLayoutId != null)
        'last_applied_layout_id': lastAppliedLayoutId,
      if (lastAppliedMonitorId != null)
        'last_applied_monitor_id': lastAppliedMonitorId,
      if (snapExcludedApps != null) 'snap_excluded_apps': snapExcludedApps,
      if (preferredMonitorId != null)
        'preferred_monitor_id': preferredMonitorId,
      if (featureTourDone != null) 'feature_tour_done': featureTourDone,
    });
  }

  SettingsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? themePreference,
    Value<String>? language,
    Value<bool>? launchAtLogin,
    Value<bool>? showMenuBarIcon,
    Value<bool>? showInDock,
    Value<bool>? magneticSnap,
    Value<bool>? animateTransitions,
    Value<int>? animationDurationMs,
    Value<double>? windowGap,
    Value<double>? screenMargin,
    Value<bool>? barTransparency,
    Value<bool>? onboardingDone,
    Value<String>? userName,
    Value<bool>? snapToLayoutRegions,
    Value<int?>? lastAppliedLayoutId,
    Value<int?>? lastAppliedMonitorId,
    Value<String>? snapExcludedApps,
    Value<int?>? preferredMonitorId,
    Value<bool>? featureTourDone,
  }) {
    return SettingsTableCompanion(
      id: id ?? this.id,
      themePreference: themePreference ?? this.themePreference,
      language: language ?? this.language,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      showMenuBarIcon: showMenuBarIcon ?? this.showMenuBarIcon,
      showInDock: showInDock ?? this.showInDock,
      magneticSnap: magneticSnap ?? this.magneticSnap,
      animateTransitions: animateTransitions ?? this.animateTransitions,
      animationDurationMs: animationDurationMs ?? this.animationDurationMs,
      windowGap: windowGap ?? this.windowGap,
      screenMargin: screenMargin ?? this.screenMargin,
      barTransparency: barTransparency ?? this.barTransparency,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      userName: userName ?? this.userName,
      snapToLayoutRegions: snapToLayoutRegions ?? this.snapToLayoutRegions,
      lastAppliedLayoutId: lastAppliedLayoutId ?? this.lastAppliedLayoutId,
      lastAppliedMonitorId: lastAppliedMonitorId ?? this.lastAppliedMonitorId,
      snapExcludedApps: snapExcludedApps ?? this.snapExcludedApps,
      preferredMonitorId: preferredMonitorId ?? this.preferredMonitorId,
      featureTourDone: featureTourDone ?? this.featureTourDone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themePreference.present) {
      map['theme_preference'] = Variable<String>(themePreference.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (launchAtLogin.present) {
      map['launch_at_login'] = Variable<bool>(launchAtLogin.value);
    }
    if (showMenuBarIcon.present) {
      map['show_menu_bar_icon'] = Variable<bool>(showMenuBarIcon.value);
    }
    if (showInDock.present) {
      map['show_in_dock'] = Variable<bool>(showInDock.value);
    }
    if (magneticSnap.present) {
      map['magnetic_snap'] = Variable<bool>(magneticSnap.value);
    }
    if (animateTransitions.present) {
      map['animate_transitions'] = Variable<bool>(animateTransitions.value);
    }
    if (animationDurationMs.present) {
      map['animation_duration_ms'] = Variable<int>(animationDurationMs.value);
    }
    if (windowGap.present) {
      map['window_gap'] = Variable<double>(windowGap.value);
    }
    if (screenMargin.present) {
      map['screen_margin'] = Variable<double>(screenMargin.value);
    }
    if (barTransparency.present) {
      map['bar_transparency'] = Variable<bool>(barTransparency.value);
    }
    if (onboardingDone.present) {
      map['onboarding_done'] = Variable<bool>(onboardingDone.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (snapToLayoutRegions.present) {
      map['snap_to_layout_regions'] = Variable<bool>(snapToLayoutRegions.value);
    }
    if (lastAppliedLayoutId.present) {
      map['last_applied_layout_id'] = Variable<int>(lastAppliedLayoutId.value);
    }
    if (lastAppliedMonitorId.present) {
      map['last_applied_monitor_id'] = Variable<int>(
        lastAppliedMonitorId.value,
      );
    }
    if (snapExcludedApps.present) {
      map['snap_excluded_apps'] = Variable<String>(snapExcludedApps.value);
    }
    if (preferredMonitorId.present) {
      map['preferred_monitor_id'] = Variable<int>(preferredMonitorId.value);
    }
    if (featureTourDone.present) {
      map['feature_tour_done'] = Variable<bool>(featureTourDone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('themePreference: $themePreference, ')
          ..write('language: $language, ')
          ..write('launchAtLogin: $launchAtLogin, ')
          ..write('showMenuBarIcon: $showMenuBarIcon, ')
          ..write('showInDock: $showInDock, ')
          ..write('magneticSnap: $magneticSnap, ')
          ..write('animateTransitions: $animateTransitions, ')
          ..write('animationDurationMs: $animationDurationMs, ')
          ..write('windowGap: $windowGap, ')
          ..write('screenMargin: $screenMargin, ')
          ..write('barTransparency: $barTransparency, ')
          ..write('onboardingDone: $onboardingDone, ')
          ..write('userName: $userName, ')
          ..write('snapToLayoutRegions: $snapToLayoutRegions, ')
          ..write('lastAppliedLayoutId: $lastAppliedLayoutId, ')
          ..write('lastAppliedMonitorId: $lastAppliedMonitorId, ')
          ..write('snapExcludedApps: $snapExcludedApps, ')
          ..write('preferredMonitorId: $preferredMonitorId, ')
          ..write('featureTourDone: $featureTourDone')
          ..write(')'))
        .toString();
  }
}

class $LicenseTableTable extends LicenseTable
    with TableInfo<$LicenseTableTable, LicenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LicenseTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _licenseKeyMeta = const VerificationMeta(
    'licenseKey',
  );
  @override
  late final GeneratedColumn<String> licenseKey = GeneratedColumn<String>(
    'license_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _entitlementPayloadMeta =
      const VerificationMeta('entitlementPayload');
  @override
  late final GeneratedColumn<String> entitlementPayload =
      GeneratedColumn<String>(
        'entitlement_payload',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _entitlementSignatureMeta =
      const VerificationMeta('entitlementSignature');
  @override
  late final GeneratedColumn<String> entitlementSignature =
      GeneratedColumn<String>(
        'entitlement_signature',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _lastValidatedAtMeta = const VerificationMeta(
    'lastValidatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastValidatedAt =
      GeneratedColumn<DateTime>(
        'last_validated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    licenseKey,
    entitlementPayload,
    entitlementSignature,
    lastValidatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'license_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<LicenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('license_key')) {
      context.handle(
        _licenseKeyMeta,
        licenseKey.isAcceptableOrUnknown(data['license_key']!, _licenseKeyMeta),
      );
    }
    if (data.containsKey('entitlement_payload')) {
      context.handle(
        _entitlementPayloadMeta,
        entitlementPayload.isAcceptableOrUnknown(
          data['entitlement_payload']!,
          _entitlementPayloadMeta,
        ),
      );
    }
    if (data.containsKey('entitlement_signature')) {
      context.handle(
        _entitlementSignatureMeta,
        entitlementSignature.isAcceptableOrUnknown(
          data['entitlement_signature']!,
          _entitlementSignatureMeta,
        ),
      );
    }
    if (data.containsKey('last_validated_at')) {
      context.handle(
        _lastValidatedAtMeta,
        lastValidatedAt.isAcceptableOrUnknown(
          data['last_validated_at']!,
          _lastValidatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LicenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LicenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      licenseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_key'],
      )!,
      entitlementPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entitlement_payload'],
      )!,
      entitlementSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entitlement_signature'],
      )!,
      lastValidatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_validated_at'],
      ),
    );
  }

  @override
  $LicenseTableTable createAlias(String alias) {
    return $LicenseTableTable(attachedDatabase, alias);
  }
}

class LicenseRow extends DataClass implements Insertable<LicenseRow> {
  final int id;

  /// Identificador estável desta instalação, enviado na ativação.
  final String deviceId;
  final String licenseKey;

  /// Payload do entitlement em base64 e sua assinatura Ed25519.
  final String entitlementPayload;
  final String entitlementSignature;
  final DateTime? lastValidatedAt;
  const LicenseRow({
    required this.id,
    required this.deviceId,
    required this.licenseKey,
    required this.entitlementPayload,
    required this.entitlementSignature,
    this.lastValidatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['license_key'] = Variable<String>(licenseKey);
    map['entitlement_payload'] = Variable<String>(entitlementPayload);
    map['entitlement_signature'] = Variable<String>(entitlementSignature);
    if (!nullToAbsent || lastValidatedAt != null) {
      map['last_validated_at'] = Variable<DateTime>(lastValidatedAt);
    }
    return map;
  }

  LicenseTableCompanion toCompanion(bool nullToAbsent) {
    return LicenseTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      licenseKey: Value(licenseKey),
      entitlementPayload: Value(entitlementPayload),
      entitlementSignature: Value(entitlementSignature),
      lastValidatedAt: lastValidatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastValidatedAt),
    );
  }

  factory LicenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LicenseRow(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      licenseKey: serializer.fromJson<String>(json['licenseKey']),
      entitlementPayload: serializer.fromJson<String>(
        json['entitlementPayload'],
      ),
      entitlementSignature: serializer.fromJson<String>(
        json['entitlementSignature'],
      ),
      lastValidatedAt: serializer.fromJson<DateTime?>(json['lastValidatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'licenseKey': serializer.toJson<String>(licenseKey),
      'entitlementPayload': serializer.toJson<String>(entitlementPayload),
      'entitlementSignature': serializer.toJson<String>(entitlementSignature),
      'lastValidatedAt': serializer.toJson<DateTime?>(lastValidatedAt),
    };
  }

  LicenseRow copyWith({
    int? id,
    String? deviceId,
    String? licenseKey,
    String? entitlementPayload,
    String? entitlementSignature,
    Value<DateTime?> lastValidatedAt = const Value.absent(),
  }) => LicenseRow(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    licenseKey: licenseKey ?? this.licenseKey,
    entitlementPayload: entitlementPayload ?? this.entitlementPayload,
    entitlementSignature: entitlementSignature ?? this.entitlementSignature,
    lastValidatedAt: lastValidatedAt.present
        ? lastValidatedAt.value
        : this.lastValidatedAt,
  );
  LicenseRow copyWithCompanion(LicenseTableCompanion data) {
    return LicenseRow(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      licenseKey: data.licenseKey.present
          ? data.licenseKey.value
          : this.licenseKey,
      entitlementPayload: data.entitlementPayload.present
          ? data.entitlementPayload.value
          : this.entitlementPayload,
      entitlementSignature: data.entitlementSignature.present
          ? data.entitlementSignature.value
          : this.entitlementSignature,
      lastValidatedAt: data.lastValidatedAt.present
          ? data.lastValidatedAt.value
          : this.lastValidatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LicenseRow(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('licenseKey: $licenseKey, ')
          ..write('entitlementPayload: $entitlementPayload, ')
          ..write('entitlementSignature: $entitlementSignature, ')
          ..write('lastValidatedAt: $lastValidatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    licenseKey,
    entitlementPayload,
    entitlementSignature,
    lastValidatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LicenseRow &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.licenseKey == this.licenseKey &&
          other.entitlementPayload == this.entitlementPayload &&
          other.entitlementSignature == this.entitlementSignature &&
          other.lastValidatedAt == this.lastValidatedAt);
}

class LicenseTableCompanion extends UpdateCompanion<LicenseRow> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String> licenseKey;
  final Value<String> entitlementPayload;
  final Value<String> entitlementSignature;
  final Value<DateTime?> lastValidatedAt;
  const LicenseTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.licenseKey = const Value.absent(),
    this.entitlementPayload = const Value.absent(),
    this.entitlementSignature = const Value.absent(),
    this.lastValidatedAt = const Value.absent(),
  });
  LicenseTableCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    this.licenseKey = const Value.absent(),
    this.entitlementPayload = const Value.absent(),
    this.entitlementSignature = const Value.absent(),
    this.lastValidatedAt = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<LicenseRow> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? licenseKey,
    Expression<String>? entitlementPayload,
    Expression<String>? entitlementSignature,
    Expression<DateTime>? lastValidatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (licenseKey != null) 'license_key': licenseKey,
      if (entitlementPayload != null) 'entitlement_payload': entitlementPayload,
      if (entitlementSignature != null)
        'entitlement_signature': entitlementSignature,
      if (lastValidatedAt != null) 'last_validated_at': lastValidatedAt,
    });
  }

  LicenseTableCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<String>? licenseKey,
    Value<String>? entitlementPayload,
    Value<String>? entitlementSignature,
    Value<DateTime?>? lastValidatedAt,
  }) {
    return LicenseTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      licenseKey: licenseKey ?? this.licenseKey,
      entitlementPayload: entitlementPayload ?? this.entitlementPayload,
      entitlementSignature: entitlementSignature ?? this.entitlementSignature,
      lastValidatedAt: lastValidatedAt ?? this.lastValidatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (licenseKey.present) {
      map['license_key'] = Variable<String>(licenseKey.value);
    }
    if (entitlementPayload.present) {
      map['entitlement_payload'] = Variable<String>(entitlementPayload.value);
    }
    if (entitlementSignature.present) {
      map['entitlement_signature'] = Variable<String>(
        entitlementSignature.value,
      );
    }
    if (lastValidatedAt.present) {
      map['last_validated_at'] = Variable<DateTime>(lastValidatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LicenseTableCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('licenseKey: $licenseKey, ')
          ..write('entitlementPayload: $entitlementPayload, ')
          ..write('entitlementSignature: $entitlementSignature, ')
          ..write('lastValidatedAt: $lastValidatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LayoutsTable layouts = $LayoutsTable(this);
  late final $LayoutRegionsTable layoutRegions = $LayoutRegionsTable(this);
  late final $AppliedLayoutsTable appliedLayouts = $AppliedLayoutsTable(this);
  late final $WorkspacesTable workspaces = $WorkspacesTable(this);
  late final $WorkspaceAppsTable workspaceApps = $WorkspaceAppsTable(this);
  late final $MonitorProfilesTable monitorProfiles = $MonitorProfilesTable(
    this,
  );
  late final $RulesTable rules = $RulesTable(this);
  late final $ShortcutsTable shortcuts = $ShortcutsTable(this);
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  late final $WindowPositionsTable windowPositions = $WindowPositionsTable(
    this,
  );
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $LicenseTableTable licenseTable = $LicenseTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    layouts,
    layoutRegions,
    appliedLayouts,
    workspaces,
    workspaceApps,
    monitorProfiles,
    rules,
    shortcuts,
    historyEntries,
    windowPositions,
    settingsTable,
    licenseTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'layouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('layout_regions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'layouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('applied_layouts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'layouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workspaces', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workspaces',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workspace_apps', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'layout_regions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workspace_apps', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workspaces',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('monitor_profiles', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'layouts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('monitor_profiles', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$LayoutsTableCreateCompanionBuilder =
    LayoutsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> category,
      Value<bool> isFavorite,
      Value<bool> isPreset,
      Value<String?> shortcut,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$LayoutsTableUpdateCompanionBuilder =
    LayoutsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> category,
      Value<bool> isFavorite,
      Value<bool> isPreset,
      Value<String?> shortcut,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$LayoutsTableReferences
    extends BaseReferences<_$AppDatabase, $LayoutsTable, LayoutRow> {
  $$LayoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LayoutRegionsTable, List<LayoutRegionRow>>
  _layoutRegionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.layoutRegions,
    aliasName: 'layouts__id__layout_regions__layout_id',
  );

  $$LayoutRegionsTableProcessedTableManager get layoutRegionsRefs {
    final manager = $$LayoutRegionsTableTableManager(
      $_db,
      $_db.layoutRegions,
    ).filter((f) => f.layoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_layoutRegionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AppliedLayoutsTable, List<AppliedLayoutRow>>
  _appliedLayoutsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.appliedLayouts,
    aliasName: 'layouts__id__applied_layouts__layout_id',
  );

  $$AppliedLayoutsTableProcessedTableManager get appliedLayoutsRefs {
    final manager = $$AppliedLayoutsTableTableManager(
      $_db,
      $_db.appliedLayouts,
    ).filter((f) => f.layoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_appliedLayoutsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkspacesTable, List<WorkspaceRow>>
  _workspacesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workspaces,
    aliasName: 'layouts__id__workspaces__layout_id',
  );

  $$WorkspacesTableProcessedTableManager get workspacesRefs {
    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.layoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workspacesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MonitorProfilesTable, List<MonitorProfileRow>>
  _monitorProfilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.monitorProfiles,
    aliasName: 'layouts__id__monitor_profiles__layout_id',
  );

  $$MonitorProfilesTableProcessedTableManager get monitorProfilesRefs {
    final manager = $$MonitorProfilesTableTableManager(
      $_db,
      $_db.monitorProfiles,
    ).filter((f) => f.layoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _monitorProfilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LayoutsTableFilterComposer
    extends Composer<_$AppDatabase, $LayoutsTable> {
  $$LayoutsTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortcut => $composableBuilder(
    column: $table.shortcut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> layoutRegionsRefs(
    Expression<bool> Function($$LayoutRegionsTableFilterComposer f) f,
  ) {
    final $$LayoutRegionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.layoutRegions,
      getReferencedColumn: (t) => t.layoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutRegionsTableFilterComposer(
            $db: $db,
            $table: $db.layoutRegions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> appliedLayoutsRefs(
    Expression<bool> Function($$AppliedLayoutsTableFilterComposer f) f,
  ) {
    final $$AppliedLayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appliedLayouts,
      getReferencedColumn: (t) => t.layoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppliedLayoutsTableFilterComposer(
            $db: $db,
            $table: $db.appliedLayouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workspacesRefs(
    Expression<bool> Function($$WorkspacesTableFilterComposer f) f,
  ) {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.layoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> monitorProfilesRefs(
    Expression<bool> Function($$MonitorProfilesTableFilterComposer f) f,
  ) {
    final $$MonitorProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.monitorProfiles,
      getReferencedColumn: (t) => t.layoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonitorProfilesTableFilterComposer(
            $db: $db,
            $table: $db.monitorProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LayoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $LayoutsTable> {
  $$LayoutsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortcut => $composableBuilder(
    column: $table.shortcut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LayoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LayoutsTable> {
  $$LayoutsTableAnnotationComposer({
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPreset =>
      $composableBuilder(column: $table.isPreset, builder: (column) => column);

  GeneratedColumn<String> get shortcut =>
      $composableBuilder(column: $table.shortcut, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> layoutRegionsRefs<T extends Object>(
    Expression<T> Function($$LayoutRegionsTableAnnotationComposer a) f,
  ) {
    final $$LayoutRegionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.layoutRegions,
      getReferencedColumn: (t) => t.layoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutRegionsTableAnnotationComposer(
            $db: $db,
            $table: $db.layoutRegions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> appliedLayoutsRefs<T extends Object>(
    Expression<T> Function($$AppliedLayoutsTableAnnotationComposer a) f,
  ) {
    final $$AppliedLayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appliedLayouts,
      getReferencedColumn: (t) => t.layoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppliedLayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.appliedLayouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workspacesRefs<T extends Object>(
    Expression<T> Function($$WorkspacesTableAnnotationComposer a) f,
  ) {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.layoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> monitorProfilesRefs<T extends Object>(
    Expression<T> Function($$MonitorProfilesTableAnnotationComposer a) f,
  ) {
    final $$MonitorProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.monitorProfiles,
      getReferencedColumn: (t) => t.layoutId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonitorProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.monitorProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LayoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LayoutsTable,
          LayoutRow,
          $$LayoutsTableFilterComposer,
          $$LayoutsTableOrderingComposer,
          $$LayoutsTableAnnotationComposer,
          $$LayoutsTableCreateCompanionBuilder,
          $$LayoutsTableUpdateCompanionBuilder,
          (LayoutRow, $$LayoutsTableReferences),
          LayoutRow,
          PrefetchHooks Function({
            bool layoutRegionsRefs,
            bool appliedLayoutsRefs,
            bool workspacesRefs,
            bool monitorProfilesRefs,
          })
        > {
  $$LayoutsTableTableManager(_$AppDatabase db, $LayoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LayoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LayoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LayoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<String?> shortcut = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LayoutsCompanion(
                id: id,
                name: name,
                category: category,
                isFavorite: isFavorite,
                isPreset: isPreset,
                shortcut: shortcut,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> category = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<String?> shortcut = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => LayoutsCompanion.insert(
                id: id,
                name: name,
                category: category,
                isFavorite: isFavorite,
                isPreset: isPreset,
                shortcut: shortcut,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LayoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                layoutRegionsRefs = false,
                appliedLayoutsRefs = false,
                workspacesRefs = false,
                monitorProfilesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (layoutRegionsRefs) db.layoutRegions,
                    if (appliedLayoutsRefs) db.appliedLayouts,
                    if (workspacesRefs) db.workspaces,
                    if (monitorProfilesRefs) db.monitorProfiles,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (layoutRegionsRefs)
                        await $_getPrefetchedData<
                          LayoutRow,
                          $LayoutsTable,
                          LayoutRegionRow
                        >(
                          currentTable: table,
                          referencedTable: $$LayoutsTableReferences
                              ._layoutRegionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LayoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).layoutRegionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.layoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (appliedLayoutsRefs)
                        await $_getPrefetchedData<
                          LayoutRow,
                          $LayoutsTable,
                          AppliedLayoutRow
                        >(
                          currentTable: table,
                          referencedTable: $$LayoutsTableReferences
                              ._appliedLayoutsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LayoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).appliedLayoutsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.layoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workspacesRefs)
                        await $_getPrefetchedData<
                          LayoutRow,
                          $LayoutsTable,
                          WorkspaceRow
                        >(
                          currentTable: table,
                          referencedTable: $$LayoutsTableReferences
                              ._workspacesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LayoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).workspacesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.layoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (monitorProfilesRefs)
                        await $_getPrefetchedData<
                          LayoutRow,
                          $LayoutsTable,
                          MonitorProfileRow
                        >(
                          currentTable: table,
                          referencedTable: $$LayoutsTableReferences
                              ._monitorProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LayoutsTableReferences(
                                db,
                                table,
                                p0,
                              ).monitorProfilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.layoutId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LayoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LayoutsTable,
      LayoutRow,
      $$LayoutsTableFilterComposer,
      $$LayoutsTableOrderingComposer,
      $$LayoutsTableAnnotationComposer,
      $$LayoutsTableCreateCompanionBuilder,
      $$LayoutsTableUpdateCompanionBuilder,
      (LayoutRow, $$LayoutsTableReferences),
      LayoutRow,
      PrefetchHooks Function({
        bool layoutRegionsRefs,
        bool appliedLayoutsRefs,
        bool workspacesRefs,
        bool monitorProfilesRefs,
      })
    >;
typedef $$LayoutRegionsTableCreateCompanionBuilder =
    LayoutRegionsCompanion Function({
      Value<int> id,
      required int layoutId,
      required String name,
      required double x,
      required double y,
      required double width,
      required double height,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<String?> appBundleId,
      Value<String?> appName,
      Value<String?> appWindowTitle,
    });
typedef $$LayoutRegionsTableUpdateCompanionBuilder =
    LayoutRegionsCompanion Function({
      Value<int> id,
      Value<int> layoutId,
      Value<String> name,
      Value<double> x,
      Value<double> y,
      Value<double> width,
      Value<double> height,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<String?> appBundleId,
      Value<String?> appName,
      Value<String?> appWindowTitle,
    });

final class $$LayoutRegionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $LayoutRegionsTable, LayoutRegionRow> {
  $$LayoutRegionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LayoutsTable _layoutIdTable(_$AppDatabase db) =>
      db.layouts.createAlias('layout_regions__layout_id__layouts__id');

  $$LayoutsTableProcessedTableManager get layoutId {
    final $_column = $_itemColumn<int>('layout_id')!;

    final manager = $$LayoutsTableTableManager(
      $_db,
      $_db.layouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_layoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WorkspaceAppsTable, List<WorkspaceAppRow>>
  _workspaceAppsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workspaceApps,
    aliasName: 'layout_regions__id__workspace_apps__region_id',
  );

  $$WorkspaceAppsTableProcessedTableManager get workspaceAppsRefs {
    final manager = $$WorkspaceAppsTableTableManager(
      $_db,
      $_db.workspaceApps,
    ).filter((f) => f.regionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workspaceAppsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LayoutRegionsTableFilterComposer
    extends Composer<_$AppDatabase, $LayoutRegionsTable> {
  $$LayoutRegionsTableFilterComposer({
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

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appBundleId => $composableBuilder(
    column: $table.appBundleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appWindowTitle => $composableBuilder(
    column: $table.appWindowTitle,
    builder: (column) => ColumnFilters(column),
  );

  $$LayoutsTableFilterComposer get layoutId {
    final $$LayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableFilterComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workspaceAppsRefs(
    Expression<bool> Function($$WorkspaceAppsTableFilterComposer f) f,
  ) {
    final $$WorkspaceAppsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workspaceApps,
      getReferencedColumn: (t) => t.regionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceAppsTableFilterComposer(
            $db: $db,
            $table: $db.workspaceApps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LayoutRegionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LayoutRegionsTable> {
  $$LayoutRegionsTableOrderingComposer({
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

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appBundleId => $composableBuilder(
    column: $table.appBundleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appWindowTitle => $composableBuilder(
    column: $table.appWindowTitle,
    builder: (column) => ColumnOrderings(column),
  );

  $$LayoutsTableOrderingComposer get layoutId {
    final $$LayoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableOrderingComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LayoutRegionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LayoutRegionsTable> {
  $$LayoutRegionsTableAnnotationComposer({
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

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get appBundleId => $composableBuilder(
    column: $table.appBundleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get appWindowTitle => $composableBuilder(
    column: $table.appWindowTitle,
    builder: (column) => column,
  );

  $$LayoutsTableAnnotationComposer get layoutId {
    final $$LayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workspaceAppsRefs<T extends Object>(
    Expression<T> Function($$WorkspaceAppsTableAnnotationComposer a) f,
  ) {
    final $$WorkspaceAppsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workspaceApps,
      getReferencedColumn: (t) => t.regionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceAppsTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaceApps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LayoutRegionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LayoutRegionsTable,
          LayoutRegionRow,
          $$LayoutRegionsTableFilterComposer,
          $$LayoutRegionsTableOrderingComposer,
          $$LayoutRegionsTableAnnotationComposer,
          $$LayoutRegionsTableCreateCompanionBuilder,
          $$LayoutRegionsTableUpdateCompanionBuilder,
          (LayoutRegionRow, $$LayoutRegionsTableReferences),
          LayoutRegionRow,
          PrefetchHooks Function({bool layoutId, bool workspaceAppsRefs})
        > {
  $$LayoutRegionsTableTableManager(_$AppDatabase db, $LayoutRegionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LayoutRegionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LayoutRegionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LayoutRegionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> layoutId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> appBundleId = const Value.absent(),
                Value<String?> appName = const Value.absent(),
                Value<String?> appWindowTitle = const Value.absent(),
              }) => LayoutRegionsCompanion(
                id: id,
                layoutId: layoutId,
                name: name,
                x: x,
                y: y,
                width: width,
                height: height,
                colorHex: colorHex,
                sortOrder: sortOrder,
                appBundleId: appBundleId,
                appName: appName,
                appWindowTitle: appWindowTitle,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int layoutId,
                required String name,
                required double x,
                required double y,
                required double width,
                required double height,
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> appBundleId = const Value.absent(),
                Value<String?> appName = const Value.absent(),
                Value<String?> appWindowTitle = const Value.absent(),
              }) => LayoutRegionsCompanion.insert(
                id: id,
                layoutId: layoutId,
                name: name,
                x: x,
                y: y,
                width: width,
                height: height,
                colorHex: colorHex,
                sortOrder: sortOrder,
                appBundleId: appBundleId,
                appName: appName,
                appWindowTitle: appWindowTitle,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LayoutRegionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({layoutId = false, workspaceAppsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workspaceAppsRefs) db.workspaceApps,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (layoutId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.layoutId,
                                    referencedTable:
                                        $$LayoutRegionsTableReferences
                                            ._layoutIdTable(db),
                                    referencedColumn:
                                        $$LayoutRegionsTableReferences
                                            ._layoutIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workspaceAppsRefs)
                        await $_getPrefetchedData<
                          LayoutRegionRow,
                          $LayoutRegionsTable,
                          WorkspaceAppRow
                        >(
                          currentTable: table,
                          referencedTable: $$LayoutRegionsTableReferences
                              ._workspaceAppsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LayoutRegionsTableReferences(
                                db,
                                table,
                                p0,
                              ).workspaceAppsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.regionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LayoutRegionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LayoutRegionsTable,
      LayoutRegionRow,
      $$LayoutRegionsTableFilterComposer,
      $$LayoutRegionsTableOrderingComposer,
      $$LayoutRegionsTableAnnotationComposer,
      $$LayoutRegionsTableCreateCompanionBuilder,
      $$LayoutRegionsTableUpdateCompanionBuilder,
      (LayoutRegionRow, $$LayoutRegionsTableReferences),
      LayoutRegionRow,
      PrefetchHooks Function({bool layoutId, bool workspaceAppsRefs})
    >;
typedef $$AppliedLayoutsTableCreateCompanionBuilder =
    AppliedLayoutsCompanion Function({
      required String monitorKey,
      required int layoutId,
      Value<int> rowid,
    });
typedef $$AppliedLayoutsTableUpdateCompanionBuilder =
    AppliedLayoutsCompanion Function({
      Value<String> monitorKey,
      Value<int> layoutId,
      Value<int> rowid,
    });

final class $$AppliedLayoutsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AppliedLayoutsTable, AppliedLayoutRow> {
  $$AppliedLayoutsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LayoutsTable _layoutIdTable(_$AppDatabase db) =>
      db.layouts.createAlias('applied_layouts__layout_id__layouts__id');

  $$LayoutsTableProcessedTableManager get layoutId {
    final $_column = $_itemColumn<int>('layout_id')!;

    final manager = $$LayoutsTableTableManager(
      $_db,
      $_db.layouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_layoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppliedLayoutsTableFilterComposer
    extends Composer<_$AppDatabase, $AppliedLayoutsTable> {
  $$AppliedLayoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get monitorKey => $composableBuilder(
    column: $table.monitorKey,
    builder: (column) => ColumnFilters(column),
  );

  $$LayoutsTableFilterComposer get layoutId {
    final $$LayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableFilterComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppliedLayoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppliedLayoutsTable> {
  $$AppliedLayoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get monitorKey => $composableBuilder(
    column: $table.monitorKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$LayoutsTableOrderingComposer get layoutId {
    final $$LayoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableOrderingComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppliedLayoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppliedLayoutsTable> {
  $$AppliedLayoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get monitorKey => $composableBuilder(
    column: $table.monitorKey,
    builder: (column) => column,
  );

  $$LayoutsTableAnnotationComposer get layoutId {
    final $$LayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppliedLayoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppliedLayoutsTable,
          AppliedLayoutRow,
          $$AppliedLayoutsTableFilterComposer,
          $$AppliedLayoutsTableOrderingComposer,
          $$AppliedLayoutsTableAnnotationComposer,
          $$AppliedLayoutsTableCreateCompanionBuilder,
          $$AppliedLayoutsTableUpdateCompanionBuilder,
          (AppliedLayoutRow, $$AppliedLayoutsTableReferences),
          AppliedLayoutRow,
          PrefetchHooks Function({bool layoutId})
        > {
  $$AppliedLayoutsTableTableManager(
    _$AppDatabase db,
    $AppliedLayoutsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppliedLayoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppliedLayoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppliedLayoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> monitorKey = const Value.absent(),
                Value<int> layoutId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppliedLayoutsCompanion(
                monitorKey: monitorKey,
                layoutId: layoutId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String monitorKey,
                required int layoutId,
                Value<int> rowid = const Value.absent(),
              }) => AppliedLayoutsCompanion.insert(
                monitorKey: monitorKey,
                layoutId: layoutId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppliedLayoutsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({layoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (layoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.layoutId,
                                referencedTable: $$AppliedLayoutsTableReferences
                                    ._layoutIdTable(db),
                                referencedColumn:
                                    $$AppliedLayoutsTableReferences
                                        ._layoutIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AppliedLayoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppliedLayoutsTable,
      AppliedLayoutRow,
      $$AppliedLayoutsTableFilterComposer,
      $$AppliedLayoutsTableOrderingComposer,
      $$AppliedLayoutsTableAnnotationComposer,
      $$AppliedLayoutsTableCreateCompanionBuilder,
      $$AppliedLayoutsTableUpdateCompanionBuilder,
      (AppliedLayoutRow, $$AppliedLayoutsTableReferences),
      AppliedLayoutRow,
      PrefetchHooks Function({bool layoutId})
    >;
typedef $$WorkspacesTableCreateCompanionBuilder =
    WorkspacesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> emoji,
      Value<String> gradientStartHex,
      Value<String> gradientEndHex,
      Value<String?> shortcut,
      Value<int?> layoutId,
      Value<bool> isActive,
      Value<int> sortOrder,
    });
typedef $$WorkspacesTableUpdateCompanionBuilder =
    WorkspacesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> emoji,
      Value<String> gradientStartHex,
      Value<String> gradientEndHex,
      Value<String?> shortcut,
      Value<int?> layoutId,
      Value<bool> isActive,
      Value<int> sortOrder,
    });

final class $$WorkspacesTableReferences
    extends BaseReferences<_$AppDatabase, $WorkspacesTable, WorkspaceRow> {
  $$WorkspacesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LayoutsTable _layoutIdTable(_$AppDatabase db) =>
      db.layouts.createAlias('workspaces__layout_id__layouts__id');

  $$LayoutsTableProcessedTableManager? get layoutId {
    final $_column = $_itemColumn<int>('layout_id');
    if ($_column == null) return null;
    final manager = $$LayoutsTableTableManager(
      $_db,
      $_db.layouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_layoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WorkspaceAppsTable, List<WorkspaceAppRow>>
  _workspaceAppsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workspaceApps,
    aliasName: 'workspaces__id__workspace_apps__workspace_id',
  );

  $$WorkspaceAppsTableProcessedTableManager get workspaceAppsRefs {
    final manager = $$WorkspaceAppsTableTableManager(
      $_db,
      $_db.workspaceApps,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workspaceAppsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MonitorProfilesTable, List<MonitorProfileRow>>
  _monitorProfilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.monitorProfiles,
    aliasName: 'workspaces__id__monitor_profiles__workspace_id',
  );

  $$MonitorProfilesTableProcessedTableManager get monitorProfilesRefs {
    final manager = $$MonitorProfilesTableTableManager(
      $_db,
      $_db.monitorProfiles,
    ).filter((f) => f.workspaceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _monitorProfilesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkspacesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableFilterComposer({
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

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gradientStartHex => $composableBuilder(
    column: $table.gradientStartHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gradientEndHex => $composableBuilder(
    column: $table.gradientEndHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortcut => $composableBuilder(
    column: $table.shortcut,
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

  $$LayoutsTableFilterComposer get layoutId {
    final $$LayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableFilterComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workspaceAppsRefs(
    Expression<bool> Function($$WorkspaceAppsTableFilterComposer f) f,
  ) {
    final $$WorkspaceAppsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workspaceApps,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceAppsTableFilterComposer(
            $db: $db,
            $table: $db.workspaceApps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> monitorProfilesRefs(
    Expression<bool> Function($$MonitorProfilesTableFilterComposer f) f,
  ) {
    final $$MonitorProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.monitorProfiles,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonitorProfilesTableFilterComposer(
            $db: $db,
            $table: $db.monitorProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkspacesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableOrderingComposer({
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

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gradientStartHex => $composableBuilder(
    column: $table.gradientStartHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gradientEndHex => $composableBuilder(
    column: $table.gradientEndHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortcut => $composableBuilder(
    column: $table.shortcut,
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

  $$LayoutsTableOrderingComposer get layoutId {
    final $$LayoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableOrderingComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkspacesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspacesTable> {
  $$WorkspacesTableAnnotationComposer({
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

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<String> get gradientStartHex => $composableBuilder(
    column: $table.gradientStartHex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gradientEndHex => $composableBuilder(
    column: $table.gradientEndHex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shortcut =>
      $composableBuilder(column: $table.shortcut, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$LayoutsTableAnnotationComposer get layoutId {
    final $$LayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workspaceAppsRefs<T extends Object>(
    Expression<T> Function($$WorkspaceAppsTableAnnotationComposer a) f,
  ) {
    final $$WorkspaceAppsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workspaceApps,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceAppsTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaceApps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> monitorProfilesRefs<T extends Object>(
    Expression<T> Function($$MonitorProfilesTableAnnotationComposer a) f,
  ) {
    final $$MonitorProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.monitorProfiles,
      getReferencedColumn: (t) => t.workspaceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonitorProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.monitorProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkspacesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspacesTable,
          WorkspaceRow,
          $$WorkspacesTableFilterComposer,
          $$WorkspacesTableOrderingComposer,
          $$WorkspacesTableAnnotationComposer,
          $$WorkspacesTableCreateCompanionBuilder,
          $$WorkspacesTableUpdateCompanionBuilder,
          (WorkspaceRow, $$WorkspacesTableReferences),
          WorkspaceRow,
          PrefetchHooks Function({
            bool layoutId,
            bool workspaceAppsRefs,
            bool monitorProfilesRefs,
          })
        > {
  $$WorkspacesTableTableManager(_$AppDatabase db, $WorkspacesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> emoji = const Value.absent(),
                Value<String> gradientStartHex = const Value.absent(),
                Value<String> gradientEndHex = const Value.absent(),
                Value<String?> shortcut = const Value.absent(),
                Value<int?> layoutId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WorkspacesCompanion(
                id: id,
                name: name,
                emoji: emoji,
                gradientStartHex: gradientStartHex,
                gradientEndHex: gradientEndHex,
                shortcut: shortcut,
                layoutId: layoutId,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> emoji = const Value.absent(),
                Value<String> gradientStartHex = const Value.absent(),
                Value<String> gradientEndHex = const Value.absent(),
                Value<String?> shortcut = const Value.absent(),
                Value<int?> layoutId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WorkspacesCompanion.insert(
                id: id,
                name: name,
                emoji: emoji,
                gradientStartHex: gradientStartHex,
                gradientEndHex: gradientEndHex,
                shortcut: shortcut,
                layoutId: layoutId,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkspacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                layoutId = false,
                workspaceAppsRefs = false,
                monitorProfilesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workspaceAppsRefs) db.workspaceApps,
                    if (monitorProfilesRefs) db.monitorProfiles,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (layoutId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.layoutId,
                                    referencedTable: $$WorkspacesTableReferences
                                        ._layoutIdTable(db),
                                    referencedColumn:
                                        $$WorkspacesTableReferences
                                            ._layoutIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workspaceAppsRefs)
                        await $_getPrefetchedData<
                          WorkspaceRow,
                          $WorkspacesTable,
                          WorkspaceAppRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._workspaceAppsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).workspaceAppsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (monitorProfilesRefs)
                        await $_getPrefetchedData<
                          WorkspaceRow,
                          $WorkspacesTable,
                          MonitorProfileRow
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspacesTableReferences
                              ._monitorProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspacesTableReferences(
                                db,
                                table,
                                p0,
                              ).monitorProfilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspacesTable,
      WorkspaceRow,
      $$WorkspacesTableFilterComposer,
      $$WorkspacesTableOrderingComposer,
      $$WorkspacesTableAnnotationComposer,
      $$WorkspacesTableCreateCompanionBuilder,
      $$WorkspacesTableUpdateCompanionBuilder,
      (WorkspaceRow, $$WorkspacesTableReferences),
      WorkspaceRow,
      PrefetchHooks Function({
        bool layoutId,
        bool workspaceAppsRefs,
        bool monitorProfilesRefs,
      })
    >;
typedef $$WorkspaceAppsTableCreateCompanionBuilder =
    WorkspaceAppsCompanion Function({
      Value<int> id,
      required int workspaceId,
      required String bundleId,
      required String appName,
      Value<int?> regionId,
      Value<String?> monitorRef,
      Value<int> sortOrder,
    });
typedef $$WorkspaceAppsTableUpdateCompanionBuilder =
    WorkspaceAppsCompanion Function({
      Value<int> id,
      Value<int> workspaceId,
      Value<String> bundleId,
      Value<String> appName,
      Value<int?> regionId,
      Value<String?> monitorRef,
      Value<int> sortOrder,
    });

final class $$WorkspaceAppsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkspaceAppsTable, WorkspaceAppRow> {
  $$WorkspaceAppsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) =>
      db.workspaces.createAlias('workspace_apps__workspace_id__workspaces__id');

  $$WorkspacesTableProcessedTableManager get workspaceId {
    final $_column = $_itemColumn<int>('workspace_id')!;

    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LayoutRegionsTable _regionIdTable(_$AppDatabase db) => db
      .layoutRegions
      .createAlias('workspace_apps__region_id__layout_regions__id');

  $$LayoutRegionsTableProcessedTableManager? get regionId {
    final $_column = $_itemColumn<int>('region_id');
    if ($_column == null) return null;
    final manager = $$LayoutRegionsTableTableManager(
      $_db,
      $_db.layoutRegions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_regionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkspaceAppsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspaceAppsTable> {
  $$WorkspaceAppsTableFilterComposer({
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

  ColumnFilters<String> get bundleId => $composableBuilder(
    column: $table.bundleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monitorRef => $composableBuilder(
    column: $table.monitorRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LayoutRegionsTableFilterComposer get regionId {
    final $$LayoutRegionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.regionId,
      referencedTable: $db.layoutRegions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutRegionsTableFilterComposer(
            $db: $db,
            $table: $db.layoutRegions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkspaceAppsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspaceAppsTable> {
  $$WorkspaceAppsTableOrderingComposer({
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

  ColumnOrderings<String> get bundleId => $composableBuilder(
    column: $table.bundleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monitorRef => $composableBuilder(
    column: $table.monitorRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LayoutRegionsTableOrderingComposer get regionId {
    final $$LayoutRegionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.regionId,
      referencedTable: $db.layoutRegions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutRegionsTableOrderingComposer(
            $db: $db,
            $table: $db.layoutRegions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkspaceAppsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspaceAppsTable> {
  $$WorkspaceAppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bundleId =>
      $composableBuilder(column: $table.bundleId, builder: (column) => column);

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get monitorRef => $composableBuilder(
    column: $table.monitorRef,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LayoutRegionsTableAnnotationComposer get regionId {
    final $$LayoutRegionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.regionId,
      referencedTable: $db.layoutRegions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutRegionsTableAnnotationComposer(
            $db: $db,
            $table: $db.layoutRegions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkspaceAppsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspaceAppsTable,
          WorkspaceAppRow,
          $$WorkspaceAppsTableFilterComposer,
          $$WorkspaceAppsTableOrderingComposer,
          $$WorkspaceAppsTableAnnotationComposer,
          $$WorkspaceAppsTableCreateCompanionBuilder,
          $$WorkspaceAppsTableUpdateCompanionBuilder,
          (WorkspaceAppRow, $$WorkspaceAppsTableReferences),
          WorkspaceAppRow,
          PrefetchHooks Function({bool workspaceId, bool regionId})
        > {
  $$WorkspaceAppsTableTableManager(_$AppDatabase db, $WorkspaceAppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspaceAppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspaceAppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspaceAppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> workspaceId = const Value.absent(),
                Value<String> bundleId = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<int?> regionId = const Value.absent(),
                Value<String?> monitorRef = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WorkspaceAppsCompanion(
                id: id,
                workspaceId: workspaceId,
                bundleId: bundleId,
                appName: appName,
                regionId: regionId,
                monitorRef: monitorRef,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int workspaceId,
                required String bundleId,
                required String appName,
                Value<int?> regionId = const Value.absent(),
                Value<String?> monitorRef = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WorkspaceAppsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                bundleId: bundleId,
                appName: appName,
                regionId: regionId,
                monitorRef: monitorRef,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkspaceAppsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workspaceId = false, regionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workspaceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workspaceId,
                                referencedTable: $$WorkspaceAppsTableReferences
                                    ._workspaceIdTable(db),
                                referencedColumn: $$WorkspaceAppsTableReferences
                                    ._workspaceIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (regionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.regionId,
                                referencedTable: $$WorkspaceAppsTableReferences
                                    ._regionIdTable(db),
                                referencedColumn: $$WorkspaceAppsTableReferences
                                    ._regionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkspaceAppsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspaceAppsTable,
      WorkspaceAppRow,
      $$WorkspaceAppsTableFilterComposer,
      $$WorkspaceAppsTableOrderingComposer,
      $$WorkspaceAppsTableAnnotationComposer,
      $$WorkspaceAppsTableCreateCompanionBuilder,
      $$WorkspaceAppsTableUpdateCompanionBuilder,
      (WorkspaceAppRow, $$WorkspaceAppsTableReferences),
      WorkspaceAppRow,
      PrefetchHooks Function({bool workspaceId, bool regionId})
    >;
typedef $$MonitorProfilesTableCreateCompanionBuilder =
    MonitorProfilesCompanion Function({
      Value<int> id,
      required String name,
      required String fingerprint,
      Value<int?> workspaceId,
      Value<int?> layoutId,
      Value<bool> autoApply,
    });
typedef $$MonitorProfilesTableUpdateCompanionBuilder =
    MonitorProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> fingerprint,
      Value<int?> workspaceId,
      Value<int?> layoutId,
      Value<bool> autoApply,
    });

final class $$MonitorProfilesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MonitorProfilesTable,
          MonitorProfileRow
        > {
  $$MonitorProfilesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspacesTable _workspaceIdTable(_$AppDatabase db) => db.workspaces
      .createAlias('monitor_profiles__workspace_id__workspaces__id');

  $$WorkspacesTableProcessedTableManager? get workspaceId {
    final $_column = $_itemColumn<int>('workspace_id');
    if ($_column == null) return null;
    final manager = $$WorkspacesTableTableManager(
      $_db,
      $_db.workspaces,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LayoutsTable _layoutIdTable(_$AppDatabase db) =>
      db.layouts.createAlias('monitor_profiles__layout_id__layouts__id');

  $$LayoutsTableProcessedTableManager? get layoutId {
    final $_column = $_itemColumn<int>('layout_id');
    if ($_column == null) return null;
    final manager = $$LayoutsTableTableManager(
      $_db,
      $_db.layouts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_layoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MonitorProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $MonitorProfilesTable> {
  $$MonitorProfilesTableFilterComposer({
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

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoApply => $composableBuilder(
    column: $table.autoApply,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspacesTableFilterComposer get workspaceId {
    final $$WorkspacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableFilterComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LayoutsTableFilterComposer get layoutId {
    final $$LayoutsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableFilterComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MonitorProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitorProfilesTable> {
  $$MonitorProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoApply => $composableBuilder(
    column: $table.autoApply,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspacesTableOrderingComposer get workspaceId {
    final $$WorkspacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableOrderingComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LayoutsTableOrderingComposer get layoutId {
    final $$LayoutsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableOrderingComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MonitorProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitorProfilesTable> {
  $$MonitorProfilesTableAnnotationComposer({
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

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoApply =>
      $composableBuilder(column: $table.autoApply, builder: (column) => column);

  $$WorkspacesTableAnnotationComposer get workspaceId {
    final $$WorkspacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceId,
      referencedTable: $db.workspaces,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspacesTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LayoutsTableAnnotationComposer get layoutId {
    final $$LayoutsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.layoutId,
      referencedTable: $db.layouts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LayoutsTableAnnotationComposer(
            $db: $db,
            $table: $db.layouts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MonitorProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonitorProfilesTable,
          MonitorProfileRow,
          $$MonitorProfilesTableFilterComposer,
          $$MonitorProfilesTableOrderingComposer,
          $$MonitorProfilesTableAnnotationComposer,
          $$MonitorProfilesTableCreateCompanionBuilder,
          $$MonitorProfilesTableUpdateCompanionBuilder,
          (MonitorProfileRow, $$MonitorProfilesTableReferences),
          MonitorProfileRow,
          PrefetchHooks Function({bool workspaceId, bool layoutId})
        > {
  $$MonitorProfilesTableTableManager(
    _$AppDatabase db,
    $MonitorProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitorProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonitorProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonitorProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<int?> workspaceId = const Value.absent(),
                Value<int?> layoutId = const Value.absent(),
                Value<bool> autoApply = const Value.absent(),
              }) => MonitorProfilesCompanion(
                id: id,
                name: name,
                fingerprint: fingerprint,
                workspaceId: workspaceId,
                layoutId: layoutId,
                autoApply: autoApply,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String fingerprint,
                Value<int?> workspaceId = const Value.absent(),
                Value<int?> layoutId = const Value.absent(),
                Value<bool> autoApply = const Value.absent(),
              }) => MonitorProfilesCompanion.insert(
                id: id,
                name: name,
                fingerprint: fingerprint,
                workspaceId: workspaceId,
                layoutId: layoutId,
                autoApply: autoApply,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MonitorProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workspaceId = false, layoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workspaceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.workspaceId,
                                referencedTable:
                                    $$MonitorProfilesTableReferences
                                        ._workspaceIdTable(db),
                                referencedColumn:
                                    $$MonitorProfilesTableReferences
                                        ._workspaceIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (layoutId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.layoutId,
                                referencedTable:
                                    $$MonitorProfilesTableReferences
                                        ._layoutIdTable(db),
                                referencedColumn:
                                    $$MonitorProfilesTableReferences
                                        ._layoutIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MonitorProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonitorProfilesTable,
      MonitorProfileRow,
      $$MonitorProfilesTableFilterComposer,
      $$MonitorProfilesTableOrderingComposer,
      $$MonitorProfilesTableAnnotationComposer,
      $$MonitorProfilesTableCreateCompanionBuilder,
      $$MonitorProfilesTableUpdateCompanionBuilder,
      (MonitorProfileRow, $$MonitorProfilesTableReferences),
      MonitorProfileRow,
      PrefetchHooks Function({bool workspaceId, bool layoutId})
    >;
typedef $$RulesTableCreateCompanionBuilder =
    RulesCompanion Function({
      Value<int> id,
      required String bundleId,
      required String appName,
      required String actionType,
      required String targetValue,
      Value<bool> isActive,
    });
typedef $$RulesTableUpdateCompanionBuilder =
    RulesCompanion Function({
      Value<int> id,
      Value<String> bundleId,
      Value<String> appName,
      Value<String> actionType,
      Value<String> targetValue,
      Value<bool> isActive,
    });

class $$RulesTableFilterComposer extends Composer<_$AppDatabase, $RulesTable> {
  $$RulesTableFilterComposer({
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

  ColumnFilters<String> get bundleId => $composableBuilder(
    column: $table.bundleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RulesTable> {
  $$RulesTableOrderingComposer({
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

  ColumnOrderings<String> get bundleId => $composableBuilder(
    column: $table.bundleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RulesTable> {
  $$RulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bundleId =>
      $composableBuilder(column: $table.bundleId, builder: (column) => column);

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$RulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RulesTable,
          RuleRow,
          $$RulesTableFilterComposer,
          $$RulesTableOrderingComposer,
          $$RulesTableAnnotationComposer,
          $$RulesTableCreateCompanionBuilder,
          $$RulesTableUpdateCompanionBuilder,
          (RuleRow, BaseReferences<_$AppDatabase, $RulesTable, RuleRow>),
          RuleRow,
          PrefetchHooks Function()
        > {
  $$RulesTableTableManager(_$AppDatabase db, $RulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bundleId = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> targetValue = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => RulesCompanion(
                id: id,
                bundleId: bundleId,
                appName: appName,
                actionType: actionType,
                targetValue: targetValue,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bundleId,
                required String appName,
                required String actionType,
                required String targetValue,
                Value<bool> isActive = const Value.absent(),
              }) => RulesCompanion.insert(
                id: id,
                bundleId: bundleId,
                appName: appName,
                actionType: actionType,
                targetValue: targetValue,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RulesTable,
      RuleRow,
      $$RulesTableFilterComposer,
      $$RulesTableOrderingComposer,
      $$RulesTableAnnotationComposer,
      $$RulesTableCreateCompanionBuilder,
      $$RulesTableUpdateCompanionBuilder,
      (RuleRow, BaseReferences<_$AppDatabase, $RulesTable, RuleRow>),
      RuleRow,
      PrefetchHooks Function()
    >;
typedef $$ShortcutsTableCreateCompanionBuilder =
    ShortcutsCompanion Function({
      Value<int> id,
      required String action,
      required String combo,
    });
typedef $$ShortcutsTableUpdateCompanionBuilder =
    ShortcutsCompanion Function({
      Value<int> id,
      Value<String> action,
      Value<String> combo,
    });

class $$ShortcutsTableFilterComposer
    extends Composer<_$AppDatabase, $ShortcutsTable> {
  $$ShortcutsTableFilterComposer({
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

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get combo => $composableBuilder(
    column: $table.combo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShortcutsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShortcutsTable> {
  $$ShortcutsTableOrderingComposer({
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

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get combo => $composableBuilder(
    column: $table.combo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShortcutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShortcutsTable> {
  $$ShortcutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get combo =>
      $composableBuilder(column: $table.combo, builder: (column) => column);
}

class $$ShortcutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShortcutsTable,
          ShortcutRow,
          $$ShortcutsTableFilterComposer,
          $$ShortcutsTableOrderingComposer,
          $$ShortcutsTableAnnotationComposer,
          $$ShortcutsTableCreateCompanionBuilder,
          $$ShortcutsTableUpdateCompanionBuilder,
          (
            ShortcutRow,
            BaseReferences<_$AppDatabase, $ShortcutsTable, ShortcutRow>,
          ),
          ShortcutRow,
          PrefetchHooks Function()
        > {
  $$ShortcutsTableTableManager(_$AppDatabase db, $ShortcutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShortcutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShortcutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShortcutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> combo = const Value.absent(),
              }) => ShortcutsCompanion(id: id, action: action, combo: combo),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String action,
                required String combo,
              }) => ShortcutsCompanion.insert(
                id: id,
                action: action,
                combo: combo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShortcutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShortcutsTable,
      ShortcutRow,
      $$ShortcutsTableFilterComposer,
      $$ShortcutsTableOrderingComposer,
      $$ShortcutsTableAnnotationComposer,
      $$ShortcutsTableCreateCompanionBuilder,
      $$ShortcutsTableUpdateCompanionBuilder,
      (
        ShortcutRow,
        BaseReferences<_$AppDatabase, $ShortcutsTable, ShortcutRow>,
      ),
      ShortcutRow,
      PrefetchHooks Function()
    >;
typedef $$HistoryEntriesTableCreateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      required String type,
      required String title,
      Value<String?> subtitle,
      Value<DateTime> createdAt,
    });
typedef $$HistoryEntriesTableUpdateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> title,
      Value<String?> subtitle,
      Value<DateTime> createdAt,
    });

class $$HistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryEntriesTable,
          HistoryEntryRow,
          $$HistoryEntriesTableFilterComposer,
          $$HistoryEntriesTableOrderingComposer,
          $$HistoryEntriesTableAnnotationComposer,
          $$HistoryEntriesTableCreateCompanionBuilder,
          $$HistoryEntriesTableUpdateCompanionBuilder,
          (
            HistoryEntryRow,
            BaseReferences<
              _$AppDatabase,
              $HistoryEntriesTable,
              HistoryEntryRow
            >,
          ),
          HistoryEntryRow,
          PrefetchHooks Function()
        > {
  $$HistoryEntriesTableTableManager(
    _$AppDatabase db,
    $HistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HistoryEntriesCompanion(
                id: id,
                type: type,
                title: title,
                subtitle: subtitle,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String title,
                Value<String?> subtitle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HistoryEntriesCompanion.insert(
                id: id,
                type: type,
                title: title,
                subtitle: subtitle,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryEntriesTable,
      HistoryEntryRow,
      $$HistoryEntriesTableFilterComposer,
      $$HistoryEntriesTableOrderingComposer,
      $$HistoryEntriesTableAnnotationComposer,
      $$HistoryEntriesTableCreateCompanionBuilder,
      $$HistoryEntriesTableUpdateCompanionBuilder,
      (
        HistoryEntryRow,
        BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntryRow>,
      ),
      HistoryEntryRow,
      PrefetchHooks Function()
    >;
typedef $$WindowPositionsTableCreateCompanionBuilder =
    WindowPositionsCompanion Function({
      Value<int> id,
      required String bundleId,
      required String monitorFingerprint,
      required double x,
      required double y,
      required double width,
      required double height,
      Value<DateTime> updatedAt,
    });
typedef $$WindowPositionsTableUpdateCompanionBuilder =
    WindowPositionsCompanion Function({
      Value<int> id,
      Value<String> bundleId,
      Value<String> monitorFingerprint,
      Value<double> x,
      Value<double> y,
      Value<double> width,
      Value<double> height,
      Value<DateTime> updatedAt,
    });

class $$WindowPositionsTableFilterComposer
    extends Composer<_$AppDatabase, $WindowPositionsTable> {
  $$WindowPositionsTableFilterComposer({
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

  ColumnFilters<String> get bundleId => $composableBuilder(
    column: $table.bundleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monitorFingerprint => $composableBuilder(
    column: $table.monitorFingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WindowPositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WindowPositionsTable> {
  $$WindowPositionsTableOrderingComposer({
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

  ColumnOrderings<String> get bundleId => $composableBuilder(
    column: $table.bundleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monitorFingerprint => $composableBuilder(
    column: $table.monitorFingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WindowPositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WindowPositionsTable> {
  $$WindowPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bundleId =>
      $composableBuilder(column: $table.bundleId, builder: (column) => column);

  GeneratedColumn<String> get monitorFingerprint => $composableBuilder(
    column: $table.monitorFingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<double> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<double> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<double> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WindowPositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WindowPositionsTable,
          WindowPositionRow,
          $$WindowPositionsTableFilterComposer,
          $$WindowPositionsTableOrderingComposer,
          $$WindowPositionsTableAnnotationComposer,
          $$WindowPositionsTableCreateCompanionBuilder,
          $$WindowPositionsTableUpdateCompanionBuilder,
          (
            WindowPositionRow,
            BaseReferences<
              _$AppDatabase,
              $WindowPositionsTable,
              WindowPositionRow
            >,
          ),
          WindowPositionRow,
          PrefetchHooks Function()
        > {
  $$WindowPositionsTableTableManager(
    _$AppDatabase db,
    $WindowPositionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WindowPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WindowPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WindowPositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bundleId = const Value.absent(),
                Value<String> monitorFingerprint = const Value.absent(),
                Value<double> x = const Value.absent(),
                Value<double> y = const Value.absent(),
                Value<double> width = const Value.absent(),
                Value<double> height = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WindowPositionsCompanion(
                id: id,
                bundleId: bundleId,
                monitorFingerprint: monitorFingerprint,
                x: x,
                y: y,
                width: width,
                height: height,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bundleId,
                required String monitorFingerprint,
                required double x,
                required double y,
                required double width,
                required double height,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WindowPositionsCompanion.insert(
                id: id,
                bundleId: bundleId,
                monitorFingerprint: monitorFingerprint,
                x: x,
                y: y,
                width: width,
                height: height,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WindowPositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WindowPositionsTable,
      WindowPositionRow,
      $$WindowPositionsTableFilterComposer,
      $$WindowPositionsTableOrderingComposer,
      $$WindowPositionsTableAnnotationComposer,
      $$WindowPositionsTableCreateCompanionBuilder,
      $$WindowPositionsTableUpdateCompanionBuilder,
      (
        WindowPositionRow,
        BaseReferences<_$AppDatabase, $WindowPositionsTable, WindowPositionRow>,
      ),
      WindowPositionRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      Value<String> themePreference,
      Value<String> language,
      Value<bool> launchAtLogin,
      Value<bool> showMenuBarIcon,
      Value<bool> showInDock,
      Value<bool> magneticSnap,
      Value<bool> animateTransitions,
      Value<int> animationDurationMs,
      Value<double> windowGap,
      Value<double> screenMargin,
      Value<bool> barTransparency,
      Value<bool> onboardingDone,
      Value<String> userName,
      Value<bool> snapToLayoutRegions,
      Value<int?> lastAppliedLayoutId,
      Value<int?> lastAppliedMonitorId,
      Value<String> snapExcludedApps,
      Value<int?> preferredMonitorId,
      Value<bool> featureTourDone,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<int> id,
      Value<String> themePreference,
      Value<String> language,
      Value<bool> launchAtLogin,
      Value<bool> showMenuBarIcon,
      Value<bool> showInDock,
      Value<bool> magneticSnap,
      Value<bool> animateTransitions,
      Value<int> animationDurationMs,
      Value<double> windowGap,
      Value<double> screenMargin,
      Value<bool> barTransparency,
      Value<bool> onboardingDone,
      Value<String> userName,
      Value<bool> snapToLayoutRegions,
      Value<int?> lastAppliedLayoutId,
      Value<int?> lastAppliedMonitorId,
      Value<String> snapExcludedApps,
      Value<int?> preferredMonitorId,
      Value<bool> featureTourDone,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
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

  ColumnFilters<String> get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showMenuBarIcon => $composableBuilder(
    column: $table.showMenuBarIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showInDock => $composableBuilder(
    column: $table.showInDock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get magneticSnap => $composableBuilder(
    column: $table.magneticSnap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get animateTransitions => $composableBuilder(
    column: $table.animateTransitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get animationDurationMs => $composableBuilder(
    column: $table.animationDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get windowGap => $composableBuilder(
    column: $table.windowGap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get screenMargin => $composableBuilder(
    column: $table.screenMargin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get barTransparency => $composableBuilder(
    column: $table.barTransparency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get snapToLayoutRegions => $composableBuilder(
    column: $table.snapToLayoutRegions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAppliedLayoutId => $composableBuilder(
    column: $table.lastAppliedLayoutId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAppliedMonitorId => $composableBuilder(
    column: $table.lastAppliedMonitorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snapExcludedApps => $composableBuilder(
    column: $table.snapExcludedApps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preferredMonitorId => $composableBuilder(
    column: $table.preferredMonitorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get featureTourDone => $composableBuilder(
    column: $table.featureTourDone,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
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

  ColumnOrderings<String> get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showMenuBarIcon => $composableBuilder(
    column: $table.showMenuBarIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showInDock => $composableBuilder(
    column: $table.showInDock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get magneticSnap => $composableBuilder(
    column: $table.magneticSnap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get animateTransitions => $composableBuilder(
    column: $table.animateTransitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get animationDurationMs => $composableBuilder(
    column: $table.animationDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get windowGap => $composableBuilder(
    column: $table.windowGap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get screenMargin => $composableBuilder(
    column: $table.screenMargin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get barTransparency => $composableBuilder(
    column: $table.barTransparency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get snapToLayoutRegions => $composableBuilder(
    column: $table.snapToLayoutRegions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAppliedLayoutId => $composableBuilder(
    column: $table.lastAppliedLayoutId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAppliedMonitorId => $composableBuilder(
    column: $table.lastAppliedMonitorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapExcludedApps => $composableBuilder(
    column: $table.snapExcludedApps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preferredMonitorId => $composableBuilder(
    column: $table.preferredMonitorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get featureTourDone => $composableBuilder(
    column: $table.featureTourDone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themePreference => $composableBuilder(
    column: $table.themePreference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showMenuBarIcon => $composableBuilder(
    column: $table.showMenuBarIcon,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showInDock => $composableBuilder(
    column: $table.showInDock,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get magneticSnap => $composableBuilder(
    column: $table.magneticSnap,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get animateTransitions => $composableBuilder(
    column: $table.animateTransitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get animationDurationMs => $composableBuilder(
    column: $table.animationDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get windowGap =>
      $composableBuilder(column: $table.windowGap, builder: (column) => column);

  GeneratedColumn<double> get screenMargin => $composableBuilder(
    column: $table.screenMargin,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get barTransparency => $composableBuilder(
    column: $table.barTransparency,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingDone => $composableBuilder(
    column: $table.onboardingDone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<bool> get snapToLayoutRegions => $composableBuilder(
    column: $table.snapToLayoutRegions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAppliedLayoutId => $composableBuilder(
    column: $table.lastAppliedLayoutId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAppliedMonitorId => $composableBuilder(
    column: $table.lastAppliedMonitorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snapExcludedApps => $composableBuilder(
    column: $table.snapExcludedApps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preferredMonitorId => $composableBuilder(
    column: $table.preferredMonitorId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get featureTourDone => $composableBuilder(
    column: $table.featureTourDone,
    builder: (column) => column,
  );
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsRow,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingsRow,
            BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsRow>,
          ),
          SettingsRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themePreference = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<bool> launchAtLogin = const Value.absent(),
                Value<bool> showMenuBarIcon = const Value.absent(),
                Value<bool> showInDock = const Value.absent(),
                Value<bool> magneticSnap = const Value.absent(),
                Value<bool> animateTransitions = const Value.absent(),
                Value<int> animationDurationMs = const Value.absent(),
                Value<double> windowGap = const Value.absent(),
                Value<double> screenMargin = const Value.absent(),
                Value<bool> barTransparency = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                Value<String> userName = const Value.absent(),
                Value<bool> snapToLayoutRegions = const Value.absent(),
                Value<int?> lastAppliedLayoutId = const Value.absent(),
                Value<int?> lastAppliedMonitorId = const Value.absent(),
                Value<String> snapExcludedApps = const Value.absent(),
                Value<int?> preferredMonitorId = const Value.absent(),
                Value<bool> featureTourDone = const Value.absent(),
              }) => SettingsTableCompanion(
                id: id,
                themePreference: themePreference,
                language: language,
                launchAtLogin: launchAtLogin,
                showMenuBarIcon: showMenuBarIcon,
                showInDock: showInDock,
                magneticSnap: magneticSnap,
                animateTransitions: animateTransitions,
                animationDurationMs: animationDurationMs,
                windowGap: windowGap,
                screenMargin: screenMargin,
                barTransparency: barTransparency,
                onboardingDone: onboardingDone,
                userName: userName,
                snapToLayoutRegions: snapToLayoutRegions,
                lastAppliedLayoutId: lastAppliedLayoutId,
                lastAppliedMonitorId: lastAppliedMonitorId,
                snapExcludedApps: snapExcludedApps,
                preferredMonitorId: preferredMonitorId,
                featureTourDone: featureTourDone,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> themePreference = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<bool> launchAtLogin = const Value.absent(),
                Value<bool> showMenuBarIcon = const Value.absent(),
                Value<bool> showInDock = const Value.absent(),
                Value<bool> magneticSnap = const Value.absent(),
                Value<bool> animateTransitions = const Value.absent(),
                Value<int> animationDurationMs = const Value.absent(),
                Value<double> windowGap = const Value.absent(),
                Value<double> screenMargin = const Value.absent(),
                Value<bool> barTransparency = const Value.absent(),
                Value<bool> onboardingDone = const Value.absent(),
                Value<String> userName = const Value.absent(),
                Value<bool> snapToLayoutRegions = const Value.absent(),
                Value<int?> lastAppliedLayoutId = const Value.absent(),
                Value<int?> lastAppliedMonitorId = const Value.absent(),
                Value<String> snapExcludedApps = const Value.absent(),
                Value<int?> preferredMonitorId = const Value.absent(),
                Value<bool> featureTourDone = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                id: id,
                themePreference: themePreference,
                language: language,
                launchAtLogin: launchAtLogin,
                showMenuBarIcon: showMenuBarIcon,
                showInDock: showInDock,
                magneticSnap: magneticSnap,
                animateTransitions: animateTransitions,
                animationDurationMs: animationDurationMs,
                windowGap: windowGap,
                screenMargin: screenMargin,
                barTransparency: barTransparency,
                onboardingDone: onboardingDone,
                userName: userName,
                snapToLayoutRegions: snapToLayoutRegions,
                lastAppliedLayoutId: lastAppliedLayoutId,
                lastAppliedMonitorId: lastAppliedMonitorId,
                snapExcludedApps: snapExcludedApps,
                preferredMonitorId: preferredMonitorId,
                featureTourDone: featureTourDone,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsRow,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingsRow,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsRow>,
      ),
      SettingsRow,
      PrefetchHooks Function()
    >;
typedef $$LicenseTableTableCreateCompanionBuilder =
    LicenseTableCompanion Function({
      Value<int> id,
      required String deviceId,
      Value<String> licenseKey,
      Value<String> entitlementPayload,
      Value<String> entitlementSignature,
      Value<DateTime?> lastValidatedAt,
    });
typedef $$LicenseTableTableUpdateCompanionBuilder =
    LicenseTableCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<String> licenseKey,
      Value<String> entitlementPayload,
      Value<String> entitlementSignature,
      Value<DateTime?> lastValidatedAt,
    });

class $$LicenseTableTableFilterComposer
    extends Composer<_$AppDatabase, $LicenseTableTable> {
  $$LicenseTableTableFilterComposer({
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

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licenseKey => $composableBuilder(
    column: $table.licenseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entitlementPayload => $composableBuilder(
    column: $table.entitlementPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entitlementSignature => $composableBuilder(
    column: $table.entitlementSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastValidatedAt => $composableBuilder(
    column: $table.lastValidatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LicenseTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LicenseTableTable> {
  $$LicenseTableTableOrderingComposer({
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

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licenseKey => $composableBuilder(
    column: $table.licenseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entitlementPayload => $composableBuilder(
    column: $table.entitlementPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entitlementSignature => $composableBuilder(
    column: $table.entitlementSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastValidatedAt => $composableBuilder(
    column: $table.lastValidatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LicenseTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LicenseTableTable> {
  $$LicenseTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get licenseKey => $composableBuilder(
    column: $table.licenseKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entitlementPayload => $composableBuilder(
    column: $table.entitlementPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entitlementSignature => $composableBuilder(
    column: $table.entitlementSignature,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastValidatedAt => $composableBuilder(
    column: $table.lastValidatedAt,
    builder: (column) => column,
  );
}

class $$LicenseTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LicenseTableTable,
          LicenseRow,
          $$LicenseTableTableFilterComposer,
          $$LicenseTableTableOrderingComposer,
          $$LicenseTableTableAnnotationComposer,
          $$LicenseTableTableCreateCompanionBuilder,
          $$LicenseTableTableUpdateCompanionBuilder,
          (
            LicenseRow,
            BaseReferences<_$AppDatabase, $LicenseTableTable, LicenseRow>,
          ),
          LicenseRow,
          PrefetchHooks Function()
        > {
  $$LicenseTableTableTableManager(_$AppDatabase db, $LicenseTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LicenseTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LicenseTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LicenseTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> licenseKey = const Value.absent(),
                Value<String> entitlementPayload = const Value.absent(),
                Value<String> entitlementSignature = const Value.absent(),
                Value<DateTime?> lastValidatedAt = const Value.absent(),
              }) => LicenseTableCompanion(
                id: id,
                deviceId: deviceId,
                licenseKey: licenseKey,
                entitlementPayload: entitlementPayload,
                entitlementSignature: entitlementSignature,
                lastValidatedAt: lastValidatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                Value<String> licenseKey = const Value.absent(),
                Value<String> entitlementPayload = const Value.absent(),
                Value<String> entitlementSignature = const Value.absent(),
                Value<DateTime?> lastValidatedAt = const Value.absent(),
              }) => LicenseTableCompanion.insert(
                id: id,
                deviceId: deviceId,
                licenseKey: licenseKey,
                entitlementPayload: entitlementPayload,
                entitlementSignature: entitlementSignature,
                lastValidatedAt: lastValidatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LicenseTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LicenseTableTable,
      LicenseRow,
      $$LicenseTableTableFilterComposer,
      $$LicenseTableTableOrderingComposer,
      $$LicenseTableTableAnnotationComposer,
      $$LicenseTableTableCreateCompanionBuilder,
      $$LicenseTableTableUpdateCompanionBuilder,
      (
        LicenseRow,
        BaseReferences<_$AppDatabase, $LicenseTableTable, LicenseRow>,
      ),
      LicenseRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LayoutsTableTableManager get layouts =>
      $$LayoutsTableTableManager(_db, _db.layouts);
  $$LayoutRegionsTableTableManager get layoutRegions =>
      $$LayoutRegionsTableTableManager(_db, _db.layoutRegions);
  $$AppliedLayoutsTableTableManager get appliedLayouts =>
      $$AppliedLayoutsTableTableManager(_db, _db.appliedLayouts);
  $$WorkspacesTableTableManager get workspaces =>
      $$WorkspacesTableTableManager(_db, _db.workspaces);
  $$WorkspaceAppsTableTableManager get workspaceApps =>
      $$WorkspaceAppsTableTableManager(_db, _db.workspaceApps);
  $$MonitorProfilesTableTableManager get monitorProfiles =>
      $$MonitorProfilesTableTableManager(_db, _db.monitorProfiles);
  $$RulesTableTableManager get rules =>
      $$RulesTableTableManager(_db, _db.rules);
  $$ShortcutsTableTableManager get shortcuts =>
      $$ShortcutsTableTableManager(_db, _db.shortcuts);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
  $$WindowPositionsTableTableManager get windowPositions =>
      $$WindowPositionsTableTableManager(_db, _db.windowPositions);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$LicenseTableTableTableManager get licenseTable =>
      $$LicenseTableTableTableManager(_db, _db.licenseTable);
}
