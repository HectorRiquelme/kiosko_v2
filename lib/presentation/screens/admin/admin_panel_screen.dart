import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../login_screen.dart';
import 'product_list_screen.dart';
import 'category_management_screen.dart';
import 'promo_management_screen.dart';
import 'user_management_screen.dart';
import 'audit_log_screen.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  static String formatPrice(int cents) {
    final formatter = NumberFormat('#,###', 'es_CL');
    return '\$${formatter.format(cents ~/ 100)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Panel de administracion',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary, fontSize: 24)),
        elevation: 0,
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(user.name,
                    style: const TextStyle(fontSize: 14)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.paddingM),
        children: [
            _AdminTile(
              icon: Icons.inventory_2_outlined,
              title: 'Gestion de productos',
              subtitle: 'Agregar, editar o eliminar productos',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const ProductListScreen(),
                ));
              },
            ),
            const SizedBox(height: AppSpacing.gapM),
            _AdminTile(
              icon: Icons.category_outlined,
              title: 'Gestion de categorias',
              subtitle: 'Crear, reordenar o eliminar categorias',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const CategoryManagementScreen(),
                ));
              },
            ),
            const SizedBox(height: AppSpacing.gapM),
            _AdminTile(
              icon: Icons.local_offer_outlined,
              title: 'Gestion de ofertas',
              subtitle: 'Crear y administrar promociones',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const PromoManagementScreen(),
                ));
              },
            ),
            const SizedBox(height: AppSpacing.gapM),
            _AdminTile(
              icon: Icons.receipt_long_outlined,
              title: 'Historial de pedidos',
              subtitle: 'Ver todos los pedidos realizados',
              onTap: () async {
                final orderRepo = ref.read(orderRepositoryProvider);
                final orders = await orderRepo.getAllOrders();
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Pedidos'),
                      content: SizedBox(
                        width: 400,
                        height: 300,
                        child: orders.isEmpty
                            ? const Center(child: Text('Sin pedidos'))
                            : ListView.builder(
                                itemCount: orders.length,
                                itemBuilder: (_, i) {
                                  final order = orders[i];
                                  return ListTile(
                                    leading: Text('#${order.queueNumber}',
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                                fontWeight: FontWeight.w700)),
                                    title:
                                        Text(formatPrice(order.totalInCents)),
                                    subtitle: Text(order.status.name),
                                    trailing: Text(DateFormat('HH:mm')
                                        .format(order.createdAt)),
                                  );
                                },
                              ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: AppSpacing.gapM),
            _AdminTile(
              icon: Icons.people_outlined,
              title: 'Gestion de usuarios',
              subtitle: 'Administrar trabajadores y PINs',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const UserManagementScreen(),
                ));
              },
            ),
            const SizedBox(height: AppSpacing.gapM),
            _AdminTile(
              icon: Icons.history_outlined,
              title: 'Registro de actividad',
              subtitle: 'Ver log de acciones y ventas',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const AuditLogScreen(),
                ));
              },
            ),
          ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingM),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(width: AppSpacing.gapM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTypography.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary, fontSize: 18)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
