import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  List<BackupInfo> _backups = [];
  bool _loading = false;
  int _dbSize = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final backups = await BackupService.listBackups();
    final size = await BackupService.getDatabaseSize();
    setState(() {
      _backups = backups;
      _dbSize = size;
      _loading = false;
    });
  }

  Future<void> _createBackup() async {
    setState(() => _loading = true);
    final path = await BackupService.createBackup();
    setState(() => _loading = false);

    if (!mounted) return;
    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup creado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
      _refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear backup'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _restoreBackup(BackupInfo backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restaurar backup'),
        content: Text(
          'Restaurar desde "${backup.name}"?\n\n'
          'La base de datos actual sera reemplazada. '
          'Se creara un backup de seguridad automaticamente.\n\n'
          'La app se debe reiniciar despues de restaurar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await BackupService.restoreBackup(backup.path);
    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Backup restaurado'),
          content: const Text(
            'La base de datos fue restaurada exitosamente.\n\n'
            'Por favor cierra y vuelve a abrir la aplicacion para ver los cambios.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al restaurar backup'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteBackup(BackupInfo backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar backup'),
        content: Text('Eliminar "${backup.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BackupService.deleteBackup(backup.path);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Backup / Restaurar',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary, fontSize: 20)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.paddingM),
        children: [
          // DB info
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingS),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            ),
            child: Row(
              children: [
                const Icon(Icons.storage, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Base de datos actual',
                          style: AppTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        _dbSize > 0
                            ? '${(_dbSize / 1024).toStringAsFixed(1)} KB'
                            : 'No disponible',
                        style: AppTypography.bodyMedium.copyWith(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.gapM),

          // Create backup button
          ElevatedButton.icon(
            onPressed: _loading ? null : _createBackup,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.backup),
            label: const Text('Crear backup ahora'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.gapM),

          // Backups list
          Text('Backups disponibles',
              style: AppTypography.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),

          if (_backups.isEmpty && !_loading)
            Container(
              padding: const EdgeInsets.all(AppSpacing.paddingXL),
              child: Column(
                children: [
                  Icon(Icons.cloud_off,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text('No hay backups',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),

          ..._backups.map((backup) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.file_present, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dateFormat.format(backup.createdAt),
                              style: AppTypography.bodyMedium
                                  .copyWith(fontWeight: FontWeight.w600)),
                          Text(backup.sizeLabel,
                              style: AppTypography.bodyMedium.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.restore, color: AppColors.primary),
                      tooltip: 'Restaurar',
                      onPressed: () => _restoreBackup(backup),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      tooltip: 'Eliminar',
                      onPressed: () => _deleteBackup(backup),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
