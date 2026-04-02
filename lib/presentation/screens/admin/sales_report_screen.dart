import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/sales_report_repository.dart';
import '../../providers/database_provider.dart';

final salesReportRepositoryProvider =
    Provider<SalesReportRepository>((ref) {
  return SalesReportRepository(ref.watch(databaseProvider));
});

enum ReportPeriod { today, week, month }

final selectedPeriodProvider =
    StateProvider<ReportPeriod>((ref) => ReportPeriod.today);

final salesReportProvider = FutureProvider<SalesReport>((ref) async {
  final repo = ref.watch(salesReportRepositoryProvider);
  final period = ref.watch(selectedPeriodProvider);
  final now = DateTime.now();

  switch (period) {
    case ReportPeriod.today:
      return repo.getDailyReport(now);
    case ReportPeriod.week:
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      return repo.getWeeklyReport(weekStart);
    case ReportPeriod.month:
      return repo.getMonthlyReport(now.year, now.month);
  }
});

class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  static String formatPrice(int cents) {
    final formatter = NumberFormat('#,###', 'es_CL');
    return '\$${formatter.format(cents ~/ 100)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);
    final reportAsync = ref.watch(salesReportProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Reporte de ventas',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary, fontSize: 24)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Period selector
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingS),
            child: Row(
              children: [
                _PeriodChip(
                  label: 'Hoy',
                  selected: period == ReportPeriod.today,
                  onTap: () => ref.read(selectedPeriodProvider.notifier).state =
                      ReportPeriod.today,
                ),
                const SizedBox(width: 8),
                _PeriodChip(
                  label: 'Semana',
                  selected: period == ReportPeriod.week,
                  onTap: () => ref.read(selectedPeriodProvider.notifier).state =
                      ReportPeriod.week,
                ),
                const SizedBox(width: 8),
                _PeriodChip(
                  label: 'Mes',
                  selected: period == ReportPeriod.month,
                  onTap: () => ref.read(selectedPeriodProvider.notifier).state =
                      ReportPeriod.month,
                ),
              ],
            ),
          ),

          // Report content
          Expanded(
            child: reportAsync.when(
              data: (report) => ListView(
                padding: const EdgeInsets.all(AppSpacing.paddingS),
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.receipt,
                          label: 'Ventas',
                          value: '${report.totalSales}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.attach_money,
                          label: 'Ingresos',
                          value: formatPrice(report.totalRevenueCents),
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.trending_up,
                          label: 'Ticket promedio',
                          value: formatPrice(report.averageTicketCents),
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.gapM),

                  // Payment methods
                  if (report.salesByPaymentMethod.isNotEmpty) ...[
                    Text('Metodos de pago',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...report.salesByPaymentMethod.entries.map((e) {
                      final label = switch (e.key) {
                        'cash' => 'Efectivo',
                        'card' => 'Tarjeta',
                        'transfer' => 'Transferencia',
                        _ => e.key,
                      };
                      final pct = report.totalSales > 0
                          ? (e.value * 100 / report.totalSales)
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(label)),
                            Expanded(
                              flex: 5,
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                backgroundColor: AppColors.backgroundGrey,
                                color: AppColors.primary,
                                minHeight: 12,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 60,
                              child: Text('${e.value} (${pct.toStringAsFixed(0)}%)',
                                  style: AppTypography.bodyMedium
                                      .copyWith(fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.gapM),
                  ],

                  // Top products
                  if (report.topProducts.isNotEmpty) ...[
                    Text('Productos mas vendidos',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...report.topProducts.asMap().entries.map((e) {
                      final idx = e.key;
                      final p = e.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: idx < 3
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              child: Text('${idx + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(p.productName)),
                            Text('${p.totalQuantity} uds',
                                style: AppTypography.bodyMedium
                                    .copyWith(fontSize: 12)),
                            const SizedBox(width: 12),
                            Text(formatPrice(p.totalRevenueCents),
                                style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.gapM),
                  ],

                  // Sales by hour
                  if (report.salesByHour.isNotEmpty) ...[
                    Text('Ventas por hora',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: report.salesByHour.entries.map((e) {
                          final maxVal = report.salesByHour.values
                              .reduce((a, b) => a > b ? a : b);
                          final height =
                              maxVal > 0 ? (e.value / maxVal) * 90 : 0.0;
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('${e.value}',
                                    style: const TextStyle(fontSize: 10)),
                                Container(
                                  height: height,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(e.key.substring(0, 2),
                                    style: const TextStyle(fontSize: 9)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // Empty state
                  if (report.totalSales == 0)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('Sin ventas en este periodo'),
                      ),
                    ),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (_, _) =>
                  const Center(child: Text('Error al cargar reporte')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value,
              style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700, fontSize: 16)),
          Text(label,
              style: AppTypography.bodyMedium
                  .copyWith(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
