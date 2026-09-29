import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';

class SyncQueueRepository {
  final AppDatabase database;

  SyncQueueRepository(this.database);

  // ---------------------------------------------------------------------------
  // ENQUEUE
  // ---------------------------------------------------------------------------

  Future<void> enqueue({
    required String userId,
    required String entityTable,
    required String recordId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now();

    final existing = await getByEntityAndRecord(
      userId: userId,
      entityTable: entityTable,
      recordId: recordId,
    );

    // No existing operation → create a new queue item.
    if (existing == null) {
      await database.into(database.syncQueue).insert(
        SyncQueueCompanion.insert(
          userId: userId,
          entityTable: entityTable,
          recordId: recordId,
          operation: operation,
          payload: jsonEncode(payload),
          createdAt: now,
          updatedAt: now,
        ),
      );

      return;
    }

    final existingOperation = existing.operation;

    // -------------------------------------------------------------------------
    // INSERT → DELETE
    //
    // The record was created locally but never synced.
    // There is no reason to send either operation to Supabase.
    // -------------------------------------------------------------------------

    if (existingOperation == 'insert' && operation == 'delete') {
      await remove(existing.id);
      return;
    }

    // -------------------------------------------------------------------------
    // INSERT → UPDATE
    //
    // Keep the operation as INSERT but replace the payload with
    // the latest version of the record.
    // -------------------------------------------------------------------------

    if (existingOperation == 'insert' && operation == 'update') {
      await (database.update(database.syncQueue)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        SyncQueueCompanion(
          operation: const Value('insert'),
          payload: Value(jsonEncode(payload)),
          updatedAt: Value(now),
          retryCount: const Value(0),
          lastError: const Value(null),
        ),
      );

      return;
    }

    // -------------------------------------------------------------------------
    // UPDATE → UPDATE
    //
    // Keep only the latest update.
    // -------------------------------------------------------------------------

    if (existingOperation == 'update' && operation == 'update') {
      await (database.update(database.syncQueue)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        SyncQueueCompanion(
          operation: const Value('update'),
          payload: Value(jsonEncode(payload)),
          updatedAt: Value(now),
          retryCount: const Value(0),
          lastError: const Value(null),
        ),
      );

      return;
    }

    // -------------------------------------------------------------------------
    // UPDATE → DELETE
    //
    // The latest action is DELETE, so replace the pending update.
    // -------------------------------------------------------------------------

    if (operation == 'delete') {
      await (database.update(database.syncQueue)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        SyncQueueCompanion(
          operation: const Value('delete'),
          payload: Value(jsonEncode(payload)),
          updatedAt: Value(now),
          retryCount: const Value(0),
          lastError: const Value(null),
        ),
      );

      return;
    }

    // -------------------------------------------------------------------------
    // Fallback
    // -------------------------------------------------------------------------

    await (database.update(database.syncQueue)
          ..where((tbl) => tbl.id.equals(existing.id)))
        .write(
      SyncQueueCompanion(
        operation: Value(operation),
        payload: Value(jsonEncode(payload)),
        updatedAt: Value(now),
        retryCount: const Value(0),
        lastError: const Value(null),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GET PENDING OPERATIONS
  // ---------------------------------------------------------------------------

  Future<List<SyncQueueData>> getPendingOperations(
    String userId,
  ) {
    return (database.select(database.syncQueue)
          ..where(
            (tbl) => tbl.userId.equals(userId),
          )
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  // ---------------------------------------------------------------------------
  // GET BY ID
  // ---------------------------------------------------------------------------

  Future<SyncQueueData?> getById(
    int id,
  ) {
    return (database.select(database.syncQueue)
          ..where(
            (tbl) => tbl.id.equals(id),
          ))
        .getSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // GET BY USER + ENTITY + RECORD
  // ---------------------------------------------------------------------------

  Future<SyncQueueData?> getByEntityAndRecord({
    required String userId,
    required String entityTable,
    required String recordId,
  }) {
    return (database.select(database.syncQueue)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.entityTable.equals(entityTable) &
                tbl.recordId.equals(recordId),
          ))
        .getSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // REMOVE
  // ---------------------------------------------------------------------------

  Future<int> remove(
    int id,
  ) {
    return (database.delete(database.syncQueue)
          ..where(
            (tbl) => tbl.id.equals(id),
          ))
        .go();
  }

  // ---------------------------------------------------------------------------
  // UPDATE RETRY INFORMATION
  // ---------------------------------------------------------------------------

  Future<int> updateRetryInfo({
    required int id,
    required int retryCount,
    String? lastError,
  }) {
    return (database.update(database.syncQueue)
          ..where(
            (tbl) => tbl.id.equals(id),
          ))
        .write(
      SyncQueueCompanion(
        retryCount: Value(retryCount),
        lastError: Value(lastError),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CLEAR USER QUEUE
  // ---------------------------------------------------------------------------

  Future<int> clearUserQueue(
    String userId,
  ) {
    return (database.delete(database.syncQueue)
          ..where(
            (tbl) => tbl.userId.equals(userId),
          ))
        .go();
  }

  // ---------------------------------------------------------------------------
  // PENDING COUNT
  // ---------------------------------------------------------------------------

  Future<int> pendingCount(
    String userId,
  ) async {
    final query = database.selectOnly(database.syncQueue)
      ..addColumns([
        database.syncQueue.id.count(),
      ])
      ..where(
        database.syncQueue.userId.equals(userId),
      );

    final result = await query.getSingle();

    return result.read(
          database.syncQueue.id.count(),
        ) ??
        0;
  }

  // ---------------------------------------------------------------------------
  // DECODE PAYLOAD
  // ---------------------------------------------------------------------------

  Map<String, dynamic> decodePayload(
    String payload,
  ) {
    final decoded = jsonDecode(payload);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return Map<String, dynamic>.from(
      decoded as Map,
    );
  }
}