import 'package:drift/drift.dart';
import '../datasources/app_database.dart';

class SalesReport {
  final int totalSales;
  final int totalRevenueCents;
  final int averageTicketCents;
  final List<ProductSalesSummary> topProducts;
  final Map<String, int> salesByPaymentMethod;
  final Map<String, int> salesByHour;

  const SalesReport({
    required this.totalSales,
    required this.totalRevenueCents,
    required this.averageTicketCents,
    required this.topProducts,
    required this.salesByPaymentMethod,
    required this.salesByHour,
  });
}

class ProductSalesSummary {
  final String productId;
  final String productName;
  final int totalQuantity;
  final int totalRevenueCents;

  const ProductSalesSummary({
    required this.productId,
    required this.productName,
    required this.totalQuantity,
    required this.totalRevenueCents,
  });
}

class SalesReportRepository {
  final AppDatabase _db;

  SalesReportRepository(this._db);

  Future<SalesReport> getDailyReport(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _buildReport(start, end);
  }

  Future<SalesReport> getWeeklyReport(DateTime weekStart) async {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    return _buildReport(start, end);
  }

  Future<SalesReport> getMonthlyReport(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return _buildReport(start, end);
  }

  Future<SalesReport> _buildReport(DateTime start, DateTime end) async {
    final startEpoch = start.millisecondsSinceEpoch ~/ 1000;
    final endEpoch = end.millisecondsSinceEpoch ~/ 1000;

    // Total sales and revenue
    final totals = await _db.customSelect(
      'SELECT COUNT(*) AS total_sales, '
      'COALESCE(SUM(total_in_cents), 0) AS total_revenue '
      'FROM orders WHERE created_at >= ? AND created_at < ?',
      variables: [Variable.withInt(startEpoch), Variable.withInt(endEpoch)],
    ).getSingle();

    final totalSales = totals.read<int>('total_sales');
    final totalRevenue = totals.read<int>('total_revenue');
    final avgTicket = totalSales > 0 ? totalRevenue ~/ totalSales : 0;

    // Top products
    final topRows = await _db.customSelect(
      'SELECT oi.product_id, p.name AS product_name, '
      'SUM(oi.quantity) AS total_qty, '
      'SUM(oi.price_in_cents * oi.quantity) AS total_rev '
      'FROM order_items oi '
      'JOIN orders o ON o.id = oi.order_id '
      'LEFT JOIN products p ON p.id = oi.product_id '
      'WHERE o.created_at >= ? AND o.created_at < ? '
      'GROUP BY oi.product_id '
      'ORDER BY total_qty DESC '
      'LIMIT 10',
      variables: [Variable.withInt(startEpoch), Variable.withInt(endEpoch)],
    ).get();

    final topProducts = topRows
        .map((r) => ProductSalesSummary(
              productId: r.read<String>('product_id'),
              productName: r.read<String?>('product_name') ?? 'Eliminado',
              totalQuantity: r.read<int>('total_qty'),
              totalRevenueCents: r.read<int>('total_rev'),
            ))
        .toList();

    // Sales by payment method
    final paymentRows = await _db.customSelect(
      'SELECT payment_method, COUNT(*) AS cnt '
      'FROM orders WHERE created_at >= ? AND created_at < ? '
      'GROUP BY payment_method',
      variables: [Variable.withInt(startEpoch), Variable.withInt(endEpoch)],
    ).get();

    final salesByPayment = <String, int>{};
    for (final r in paymentRows) {
      salesByPayment[r.read<String>('payment_method')] = r.read<int>('cnt');
    }

    // Sales by hour
    final hourRows = await _db.customSelect(
      'SELECT (created_at % 86400) / 3600 AS hour, COUNT(*) AS cnt '
      'FROM orders WHERE created_at >= ? AND created_at < ? '
      'GROUP BY hour ORDER BY hour',
      variables: [Variable.withInt(startEpoch), Variable.withInt(endEpoch)],
    ).get();

    final salesByHour = <String, int>{};
    for (final r in hourRows) {
      final hour = r.read<int>('hour');
      salesByHour['${hour.toString().padLeft(2, '0')}:00'] =
          r.read<int>('cnt');
    }

    return SalesReport(
      totalSales: totalSales,
      totalRevenueCents: totalRevenue,
      averageTicketCents: avgTicket,
      topProducts: topProducts,
      salesByPaymentMethod: salesByPayment,
      salesByHour: salesByHour,
    );
  }
}
