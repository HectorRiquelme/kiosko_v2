import 'package:drift/drift.dart';
import '../../domain/entities/audit_log_entry.dart';
import '../datasources/app_database.dart';

class AuditLogRepository {
  final AppDatabase _db;

  AuditLogRepository(this._db);

  Future<void> log({
    required String userId,
    required String userName,
    required AuditAction action,
    required AuditEntityType entityType,
    required String entityId,
    required String entityName,
    String details = '',
  }) async {
    await _db.into(_db.auditLogs).insert(AuditLogsCompanion(
          userId: Value(userId),
          userName: Value(userName),
          action: Value(action.name),
          targetType: Value(entityType.name),
          targetId: Value(entityId),
          targetName: Value(entityName),
          details: Value(details),
          createdAt: Value(DateTime.now()),
        ));
  }

  Future<List<AuditLogEntry>> getAll({int limit = 100}) async {
    final rows = await (_db.select(_db.auditLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_toEntry).toList();
  }

  Future<List<AuditLogEntry>> getByEntityType(
      AuditEntityType type, {int limit = 50}) async {
    final rows = await (_db.select(_db.auditLogs)
          ..where((t) => t.targetType.equals(type.name))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_toEntry).toList();
  }

  Future<List<AuditLogEntry>> getByUser(String userId, {int limit = 50}) async {
    final rows = await (_db.select(_db.auditLogs)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_toEntry).toList();
  }

  Future<List<AuditLogEntry>> getSales({int limit = 100}) async {
    final rows = await (_db.select(_db.auditLogs)
          ..where((t) => t.action.equals(AuditAction.sale.name))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_toEntry).toList();
  }

  Future<List<AuditLogEntry>> getByDateRange(
      DateTime start, DateTime end, {int limit = 200}) async {
    final rows = await (_db.select(_db.auditLogs)
          ..where((t) =>
              t.createdAt.isBiggerOrEqualValue(start) &
              t.createdAt.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
    return rows.map(_toEntry).toList();
  }

  AuditLogEntry _toEntry(AuditLog row) {
    return AuditLogEntry(
      id: row.id,
      userId: row.userId,
      userName: row.userName,
      action: AuditAction.values.firstWhere(
        (e) => e.name == row.action,
        orElse: () => AuditAction.create,
      ),
      entityType: AuditEntityType.values.firstWhere(
        (e) => e.name == row.targetType,
        orElse: () => AuditEntityType.product,
      ),
      entityId: row.targetId,
      entityName: row.targetName,
      details: row.details,
      createdAt: row.createdAt,
    );
  }
}
