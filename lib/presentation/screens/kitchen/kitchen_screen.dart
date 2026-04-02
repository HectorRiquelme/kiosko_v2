import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../login_screen.dart';

final kitchenOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getAllOrders();
});

class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  Timer? _refreshTimer;
  int _lastPendingCount = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.invalidate(kitchenOrdersProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _checkForNewOrders(List<Order> allOrders) {
    final pendingCount =
        allOrders.where((o) => o.status == OrderStatus.pending).length;
    if (pendingCount > _lastPendingCount && _lastPendingCount >= 0) {
      _notifyNewOrder();
    }
    _lastPendingCount = pendingCount;
  }

  Future<void> _notifyNewOrder() async {
    // Haptic feedback
    HapticFeedback.heavyImpact();
    // System notification sound
    await _audioPlayer.play(AssetSource('sounds/new_order.mp3')).catchError((_) {
      // If asset not found, use a system sound via short vibration pattern
      HapticFeedback.vibrate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(kitchenOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Cocina',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(kitchenOrdersProvider),
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
      body: ordersAsync.when(
        data: (allOrders) {
          // Check for new orders and notify
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkForNewOrders(allOrders);
          });

          final pendingOrders = allOrders
              .where((o) => o.status == OrderStatus.pending)
              .toList();
          final preparingOrders = allOrders
              .where((o) => o.status == OrderStatus.preparing)
              .toList();
          final readyOrders = allOrders
              .where((o) => o.status == OrderStatus.ready)
              .toList();

          if (pendingOrders.isEmpty &&
              preparingOrders.isEmpty &&
              readyOrders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 80, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Sin pedidos pendientes',
                      style: TextStyle(
                          fontSize: 20, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return Row(
            children: [
              Expanded(
                child: _OrderColumn(
                  title: 'Pendientes',
                  color: AppColors.warning,
                  orders: pendingOrders,
                  actionLabel: 'Preparar',
                  nextStatus: OrderStatus.preparing,
                  onStatusChange: _updateStatus,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _OrderColumn(
                  title: 'Preparando',
                  color: AppColors.primary,
                  orders: preparingOrders,
                  actionLabel: 'Listo',
                  nextStatus: OrderStatus.ready,
                  onStatusChange: _updateStatus,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _OrderColumn(
                  title: 'Listos',
                  color: AppColors.success,
                  orders: readyOrders,
                  actionLabel: 'Entregado',
                  nextStatus: OrderStatus.delivered,
                  onStatusChange: _updateStatus,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) =>
            const Center(child: Text('Error al cargar pedidos')),
      ),
    );
  }

  Future<void> _updateStatus(String orderId, OrderStatus newStatus) async {
    final repo = ref.read(orderRepositoryProvider);
    await repo.updateOrderStatus(orderId, newStatus);
    ref.invalidate(kitchenOrdersProvider);
  }
}

class _OrderColumn extends StatelessWidget {
  final String title;
  final Color color;
  final List<Order> orders;
  final String actionLabel;
  final OrderStatus nextStatus;
  final Future<void> Function(String orderId, OrderStatus status) onStatusChange;

  const _OrderColumn({
    required this.title,
    required this.color,
    required this.orders,
    required this.actionLabel,
    required this.nextStatus,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.paddingS),
          color: color,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${orders.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Text('Sin pedidos',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _KitchenOrderCard(
                      order: order,
                      actionLabel: actionLabel,
                      actionColor: color,
                      onAction: () => onStatusChange(order.id, nextStatus),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _KitchenOrderCard extends StatelessWidget {
  final Order order;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback onAction;

  const _KitchenOrderCard({
    required this.order,
    required this.actionLabel,
    required this.actionColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.queueNumber}',
                  style: AppTypography.headline2.copyWith(fontSize: 28),
                ),
                Text(
                  timeFormat.format(order.createdAt),
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary, fontSize: 16),
                ),
              ],
            ),
            const Divider(),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${item.quantity}x ${item.product.name}',
                    style: AppTypography.bodyMedium.copyWith(fontSize: 16),
                  ),
                )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
