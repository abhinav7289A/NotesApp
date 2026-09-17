// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_cache.dart';

// ignore_for_file: type=lint
class $CachedChaptersTable extends CachedChapters
    with TableInfo<$CachedChaptersTable, CachedChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterJsonMeta = const VerificationMeta(
    'chapterJson',
  );
  @override
  late final GeneratedColumn<String> chapterJson = GeneratedColumn<String>(
    'chapter_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pdfPathMeta = const VerificationMeta(
    'pdfPath',
  );
  @override
  late final GeneratedColumn<String> pdfPath = GeneratedColumn<String>(
    'pdf_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    documentId,
    chapterJson,
    cachedAt,
    pdfPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedChapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('chapter_json')) {
      context.handle(
        _chapterJsonMeta,
        chapterJson.isAcceptableOrUnknown(
          data['chapter_json']!,
          _chapterJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    if (data.containsKey('pdf_path')) {
      context.handle(
        _pdfPathMeta,
        pdfPath.isAcceptableOrUnknown(data['pdf_path']!, _pdfPathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {documentId};
  @override
  CachedChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedChapter(
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      chapterJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
      pdfPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_path'],
      ),
    );
  }

  @override
  $CachedChaptersTable createAlias(String alias) {
    return $CachedChaptersTable(attachedDatabase, alias);
  }
}

class CachedChapter extends DataClass implements Insertable<CachedChapter> {
  final String documentId;
  final String chapterJson;
  final DateTime cachedAt;

  /// Path to the locally cached copy of the original PDF, relative to the
  /// app's documents directory.
  final String? pdfPath;
  const CachedChapter({
    required this.documentId,
    required this.chapterJson,
    required this.cachedAt,
    this.pdfPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['document_id'] = Variable<String>(documentId);
    map['chapter_json'] = Variable<String>(chapterJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    if (!nullToAbsent || pdfPath != null) {
      map['pdf_path'] = Variable<String>(pdfPath);
    }
    return map;
  }

  CachedChaptersCompanion toCompanion(bool nullToAbsent) {
    return CachedChaptersCompanion(
      documentId: Value(documentId),
      chapterJson: Value(chapterJson),
      cachedAt: Value(cachedAt),
      pdfPath: pdfPath == null && nullToAbsent
          ? const Value.absent()
          : Value(pdfPath),
    );
  }

  factory CachedChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedChapter(
      documentId: serializer.fromJson<String>(json['documentId']),
      chapterJson: serializer.fromJson<String>(json['chapterJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      pdfPath: serializer.fromJson<String?>(json['pdfPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'documentId': serializer.toJson<String>(documentId),
      'chapterJson': serializer.toJson<String>(chapterJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'pdfPath': serializer.toJson<String?>(pdfPath),
    };
  }

  CachedChapter copyWith({
    String? documentId,
    String? chapterJson,
    DateTime? cachedAt,
    Value<String?> pdfPath = const Value.absent(),
  }) => CachedChapter(
    documentId: documentId ?? this.documentId,
    chapterJson: chapterJson ?? this.chapterJson,
    cachedAt: cachedAt ?? this.cachedAt,
    pdfPath: pdfPath.present ? pdfPath.value : this.pdfPath,
  );
  CachedChapter copyWithCompanion(CachedChaptersCompanion data) {
    return CachedChapter(
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      chapterJson: data.chapterJson.present
          ? data.chapterJson.value
          : this.chapterJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      pdfPath: data.pdfPath.present ? data.pdfPath.value : this.pdfPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedChapter(')
          ..write('documentId: $documentId, ')
          ..write('chapterJson: $chapterJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('pdfPath: $pdfPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(documentId, chapterJson, cachedAt, pdfPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedChapter &&
          other.documentId == this.documentId &&
          other.chapterJson == this.chapterJson &&
          other.cachedAt == this.cachedAt &&
          other.pdfPath == this.pdfPath);
}

class CachedChaptersCompanion extends UpdateCompanion<CachedChapter> {
  final Value<String> documentId;
  final Value<String> chapterJson;
  final Value<DateTime> cachedAt;
  final Value<String?> pdfPath;
  final Value<int> rowid;
  const CachedChaptersCompanion({
    this.documentId = const Value.absent(),
    this.chapterJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedChaptersCompanion.insert({
    required String documentId,
    required String chapterJson,
    required DateTime cachedAt,
    this.pdfPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : documentId = Value(documentId),
       chapterJson = Value(chapterJson),
       cachedAt = Value(cachedAt);
  static Insertable<CachedChapter> custom({
    Expression<String>? documentId,
    Expression<String>? chapterJson,
    Expression<DateTime>? cachedAt,
    Expression<String>? pdfPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (documentId != null) 'document_id': documentId,
      if (chapterJson != null) 'chapter_json': chapterJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (pdfPath != null) 'pdf_path': pdfPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedChaptersCompanion copyWith({
    Value<String>? documentId,
    Value<String>? chapterJson,
    Value<DateTime>? cachedAt,
    Value<String?>? pdfPath,
    Value<int>? rowid,
  }) {
    return CachedChaptersCompanion(
      documentId: documentId ?? this.documentId,
      chapterJson: chapterJson ?? this.chapterJson,
      cachedAt: cachedAt ?? this.cachedAt,
      pdfPath: pdfPath ?? this.pdfPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (chapterJson.present) {
      map['chapter_json'] = Variable<String>(chapterJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (pdfPath.present) {
      map['pdf_path'] = Variable<String>(pdfPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedChaptersCompanion(')
          ..write('documentId: $documentId, ')
          ..write('chapterJson: $chapterJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalCache extends GeneratedDatabase {
  _$LocalCache(QueryExecutor e) : super(e);
  $LocalCacheManager get managers => $LocalCacheManager(this);
  late final $CachedChaptersTable cachedChapters = $CachedChaptersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cachedChapters];
}

typedef $$CachedChaptersTableCreateCompanionBuilder =
    CachedChaptersCompanion Function({
      required String documentId,
      required String chapterJson,
      required DateTime cachedAt,
      Value<String?> pdfPath,
      Value<int> rowid,
    });
typedef $$CachedChaptersTableUpdateCompanionBuilder =
    CachedChaptersCompanion Function({
      Value<String> documentId,
      Value<String> chapterJson,
      Value<DateTime> cachedAt,
      Value<String?> pdfPath,
      Value<int> rowid,
    });

class $$CachedChaptersTableFilterComposer
    extends Composer<_$LocalCache, $CachedChaptersTable> {
  $$CachedChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterJson => $composableBuilder(
    column: $table.chapterJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfPath => $composableBuilder(
    column: $table.pdfPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedChaptersTableOrderingComposer
    extends Composer<_$LocalCache, $CachedChaptersTable> {
  $$CachedChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterJson => $composableBuilder(
    column: $table.chapterJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfPath => $composableBuilder(
    column: $table.pdfPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedChaptersTableAnnotationComposer
    extends Composer<_$LocalCache, $CachedChaptersTable> {
  $$CachedChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get chapterJson => $composableBuilder(
    column: $table.chapterJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<String> get pdfPath =>
      $composableBuilder(column: $table.pdfPath, builder: (column) => column);
}

class $$CachedChaptersTableTableManager
    extends
        RootTableManager<
          _$LocalCache,
          $CachedChaptersTable,
          CachedChapter,
          $$CachedChaptersTableFilterComposer,
          $$CachedChaptersTableOrderingComposer,
          $$CachedChaptersTableAnnotationComposer,
          $$CachedChaptersTableCreateCompanionBuilder,
          $$CachedChaptersTableUpdateCompanionBuilder,
          (
            CachedChapter,
            BaseReferences<_$LocalCache, $CachedChaptersTable, CachedChapter>,
          ),
          CachedChapter,
          PrefetchHooks Function()
        > {
  $$CachedChaptersTableTableManager(_$LocalCache db, $CachedChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> documentId = const Value.absent(),
                Value<String> chapterJson = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<String?> pdfPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedChaptersCompanion(
                documentId: documentId,
                chapterJson: chapterJson,
                cachedAt: cachedAt,
                pdfPath: pdfPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String documentId,
                required String chapterJson,
                required DateTime cachedAt,
                Value<String?> pdfPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedChaptersCompanion.insert(
                documentId: documentId,
                chapterJson: chapterJson,
                cachedAt: cachedAt,
                pdfPath: pdfPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedChaptersTable, CachedChapter>(table),
                  BaseReferences<
                    _$LocalCache,
                    $CachedChaptersTable,
                    CachedChapter
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalCache,
      $CachedChaptersTable,
      CachedChapter,
      $$CachedChaptersTableFilterComposer,
      $$CachedChaptersTableOrderingComposer,
      $$CachedChaptersTableAnnotationComposer,
      $$CachedChaptersTableCreateCompanionBuilder,
      $$CachedChaptersTableUpdateCompanionBuilder,
      (
        CachedChapter,
        BaseReferences<_$LocalCache, $CachedChaptersTable, CachedChapter>,
      ),
      CachedChapter,
      PrefetchHooks Function()
    >;

class $LocalCacheManager {
  final _$LocalCache _db;
  $LocalCacheManager(this._db);
  $$CachedChaptersTableTableManager get cachedChapters =>
      $$CachedChaptersTableTableManager(_db, _db.cachedChapters);
}
