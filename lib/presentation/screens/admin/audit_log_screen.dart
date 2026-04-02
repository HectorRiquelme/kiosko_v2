import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/audit_log_entry.dart';
import '../../providers/database_provider.dart';

final auditLogsProvider = FutureProvider<List<AuditLogEntry>>((ref) async {
  final repo = ref.watch(auditLogRepositoryProvider);
  return repo.getAll(limit: 200);
});

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Registro de actividad',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary, fontSize: 24)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(auditLogsProvider),
          ),
        ],
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('Sin registros'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.paddingS),
            itemCount: logs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Action icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _actionColor(log.action),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _actionIcon(log.action),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${log.actionLabel} ${log.entityTypeLabel}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            log.entityName,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          if (log.details.isNotEmpty)
                            Text(
                              log.details,
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // User + time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          log.userName,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM HH:mm').format(log.createdAt),
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) =>
            const Center(child: Text('Error al cargar registros')),
      ),
    );
  }

  Color _actionColor(AuditAction action) {
    switch (action) {
      case AuditAction.create:
        return AppColors.success;
      case AuditAction.update:
        return AppColors.primary;
      case AuditAction.delete:
        return AppColors.error;
      case AuditAction.sale:
        return const Color(0xFF2196F3);
      case AuditAction.login:
        return AppColors.textSecondary;
      case AuditAction.logout:
        return AppColors.textSecondary;
    }
  }

  IconData _actionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.create:
        return Icons.add;
      case AuditAction.update:
        return Icons.edit;
      case AuditAction.delete:
        return Icons.delete;
      case AuditAction.sale:
        return Icons.point_of_sale;
      case AuditAction.login:
        return Icons.login;
      case AuditAction.logout:
        return Icons.logout;
    }
  }
}
