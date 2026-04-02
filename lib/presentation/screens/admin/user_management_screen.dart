import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_provider.dart';

final usersListProvider = FutureProvider<List<AppUser>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getAllUsers();
});

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Gestion de usuarios',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary, fontSize: 24)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await _showUserDialog(context, ref);
              ref.invalidate(usersListProvider);
            },
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.paddingS),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: user.role == UserRole.admin
                          ? AppColors.primary
                          : AppColors.success,
                      child: Icon(
                        user.role == UserRole.admin
                            ? Icons.admin_panel_settings
                            : Icons.restaurant,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name,
                              style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600, fontSize: 18)),
                          Text(
                            user.role == UserRole.admin
                                ? 'Administrador'
                                : 'Trabajador',
                            style: AppTypography.bodyMedium.copyWith(
                                fontSize: 14,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text('PIN: ${user.pin}',
                        style: AppTypography.bodyMedium.copyWith(
                            fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () async {
                        await _showUserDialog(context, ref, user: user);
                        ref.invalidate(usersListProvider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Eliminar usuario'),
                            content:
                                Text('Eliminar "${user.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Eliminar',
                                    style:
                                        TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(authRepositoryProvider)
                              .deleteUser(user.id);
                          ref.invalidate(usersListProvider);
                        }
                      },
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
            const Center(child: Text('Error al cargar usuarios')),
      ),
    );
  }

  Future<void> _showUserDialog(BuildContext context, WidgetRef ref,
      {AppUser? user}) async {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final pinCtrl = TextEditingController(text: user?.pin ?? '');
    UserRole selectedRole = user?.role ?? UserRole.worker;
    String? pinError;
    final isEdit = user != null;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Editar usuario' : 'Nuevo usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinCtrl,
                decoration: InputDecoration(
                  labelText: 'PIN (4 digitos)',
                  border: const OutlineInputBorder(),
                  errorText: pinError,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Administrador'),
                    selected: selectedRole == UserRole.admin,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => setDialogState(
                        () => selectedRole = UserRole.admin),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Trabajador'),
                    selected: selectedRole == UserRole.worker,
                    selectedColor: AppColors.success,
                    onSelected: (_) => setDialogState(
                        () => selectedRole = UserRole.worker),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final pin = pinCtrl.text.trim();

                if (name.isEmpty || pin.length != 4) {
                  setDialogState(() {
                    pinError = pin.length != 4
                        ? 'El PIN debe tener 4 digitos'
                        : null;
                  });
                  return;
                }

                // Check PIN uniqueness
                final repo = ref.read(authRepositoryProvider);
                final available = await repo.isPinAvailable(
                  pin,
                  excludeUserId: user?.id,
                );
                if (!available) {
                  setDialogState(() {
                    pinError = 'Este PIN ya esta en uso';
                  });
                  return;
                }

                final newUser = AppUser(
                  id: isEdit
                      ? user.id
                      : 'user_${DateTime.now().microsecondsSinceEpoch}',
                  name: name,
                  pin: pin,
                  role: selectedRole,
                );

                if (isEdit) {
                  await repo.updateUser(newUser);
                } else {
                  await repo.createUser(newUser);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(isEdit ? 'Guardar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }
}
