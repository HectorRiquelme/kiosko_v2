import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/audit_log_entry.dart';
import '../../domain/entities/user.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/database_provider.dart';

/// Convenience class to log audit events from anywhere with a Ref
class AuditLogger {
  static Future<void> log(
    Ref ref, {
    required AuditAction action,
    required AuditEntityType entityType,
    required String entityId,
    required String entityName,
    String details = '',
  }) async {
    final user = ref.read(authProvider);
    final repo = ref.read(auditLogRepositoryProvider);
    await repo.log(
      userId: user?.id ?? 'system',
      userName: user?.name ?? 'Sistema',
      action: action,
      entityType: entityType,
      entityId: entityId,
      entityName: entityName,
      details: details,
    );
  }

  static Future<void> logWithUser(
    Ref ref, {
    required AppUser user,
    required AuditAction action,
    required AuditEntityType entityType,
    required String entityId,
    required String entityName,
    String details = '',
  }) async {
    final repo = ref.read(auditLogRepositoryProvider);
    await repo.log(
      userId: user.id,
      userName: user.name,
      action: action,
      entityType: entityType,
      entityId: entityId,
      entityName: entityName,
      details: details,
    );
  }
}
