import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/order.dart';
import '../providers/database_provider.dart';

final displayOrdersProvider = FutureProvider<List<Order>>((ref) async {
  try {
    final repo = ref.watch(orderRepositoryProvider);
    return await repo.getAllOrders();
  } catch (_) {
    return <Order>[];
  }
});

/// Public-facing display screen that shows order queue numbers
/// and their current status. Designed to be shown on a TV or
/// secondary display visible to customers.
class OrderDisplayScreen extends ConsumerStatefulWidget {
  const OrderDisplayScreen({super.key});

  @override
  ConsumerState<OrderDisplayScreen> createState() =>
      _OrderDisplayScreenState();
}

class _OrderDisplayScreenState extends ConsumerState<OrderDisplayScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      ref.invalidate(displayOrdersProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(displayOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.paddingXL,
              vertical: AppSpacing.paddingM,
            ),
            color: AppColors.primary,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Kiosko POS',
                    style: AppTypography.headline2
                        .copyWith(color: AppColors.textOnPrimary)),
                Text('Estado de pedidos',
                    style: AppTypography.bodyLarge
                        .copyWith(color: AppColors.textOnPrimary)),
              ],
            ),
          ),

          // Orders grid
          Expanded(
            child: ordersAsync.when(
              data: (allOrders) {
                final preparing = allOrders
                    .where((o) => o.status == OrderStatus.preparing)
                    .toList();
                final ready = allOrders
                    .where((o) => o.status == OrderStatus.ready)
                    .toList();

                if (preparing.isEmpty && ready.isEmpty) {
                  return Center(
                    child: Text(
                      'Sin pedidos en preparacion',
                      style: AppTypography.headline2
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }

                return Row(
                  children: [
                    // Preparing section
                    Expanded(
                      child: _DisplaySection(
                        title: 'Preparando',
                        icon: Icons.restaurant,
                        color: AppColors.primary,
                        orders: preparing,
                      ),
                    ),
                    // Divider
                    Container(width: 2, color: AppColors.textSecondary),
                    // Ready section
                    Expanded(
                      child: _DisplaySection(
                        title: 'Listos para retirar',
                        icon: Icons.check_circle,
                        color: AppColors.success,
                        orders: ready,
                        highlight: true,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Sin pedidos en preparacion',
                        style: AppTypography.headline2
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisplaySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Order> orders;
  final bool highlight;

  const _DisplaySection({
    required this.title,
    required this.icon,
    required this.color,
    required this.orders,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.paddingM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTypography.headline2.copyWith(
                  color: color,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.textSecondary, height: 1),
        // Queue numbers grid
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Text(
                    '---',
                    style: AppTypography.headline2
                        .copyWith(color: AppColors.textSecondary),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.paddingM),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: orders.map((order) {
                      return _QueueNumberBadge(
                        number: order.queueNumber,
                        color: color,
                        highlight: highlight,
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

class _QueueNumberBadge extends StatefulWidget {
  final int number;
  final Color color;
  final bool highlight;

  const _QueueNumberBadge({
    required this.number,
    required this.color,
    this.highlight = false,
  });

  @override
  State<_QueueNumberBadge> createState() => _QueueNumberBadgeState();
}

class _QueueNumberBadgeState extends State<_QueueNumberBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.highlight) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = widget.highlight
            ? 1.0 + (_controller.value * 0.05)
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              boxShadow: widget.highlight
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '#${widget.number}',
                style: AppTypography.headline1.copyWith(fontSize: 42),
              ),
            ),
          ),
        );
      },
    );
  }
}
