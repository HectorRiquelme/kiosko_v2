import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/order.dart';

enum PrinterConnectionType { bluetooth, usb }

class PrinterDevice {
  final String name;
  final String address;
  final PrinterConnectionType type;

  const PrinterDevice({
    required this.name,
    required this.address,
    required this.type,
  });
}

class ThermalPrinterService {
  static const _channel = MethodChannel('com.kiosko.printer');

  /// Discover available Bluetooth printers
  static Future<List<PrinterDevice>> discoverPrinters() async {
    try {
      final result = await _channel.invokeMethod<List>('discoverPrinters');
      if (result == null) return [];
      return result.map((d) => PrinterDevice(
        name: d['name'] ?? 'Unknown',
        address: d['address'] ?? '',
        type: d['type'] == 'usb'
            ? PrinterConnectionType.usb
            : PrinterConnectionType.bluetooth,
      )).toList();
    } on MissingPluginException {
      return [];
    }
  }

  /// Print raw ESC/POS bytes to a connected printer
  static Future<bool> printRaw(String address, List<int> bytes) async {
    try {
      final result = await _channel.invokeMethod<bool>('printRaw', {
        'address': address,
        'bytes': Uint8List.fromList(bytes),
      });
      return result ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Generate ESC/POS bytes for an order receipt
  static List<int> generateReceiptBytes(Order order) {
    final formatter = NumberFormat('#,###', 'es_CL');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final bytes = <int>[];

    // ESC/POS commands
    const esc = 0x1B;
    const gs = 0x1D;

    // Initialize printer
    bytes.addAll([esc, 0x40]); // ESC @ - init
    // Center align
    bytes.addAll([esc, 0x61, 0x01]); // ESC a 1 - center

    // Bold on
    bytes.addAll([esc, 0x45, 0x01]);
    // Double height+width for header
    bytes.addAll([gs, 0x21, 0x11]);
    bytes.addAll(_text('KIOSKO POS'));
    bytes.addAll([gs, 0x21, 0x00]); // Normal size
    bytes.addAll([esc, 0x45, 0x00]); // Bold off
    bytes.add(0x0A); // LF

    bytes.addAll(_text('================================'));

    // Queue number - large
    bytes.addAll([esc, 0x45, 0x01]); // Bold
    bytes.addAll([gs, 0x21, 0x11]); // Double size
    bytes.addAll(_text('TURNO #${order.queueNumber}'));
    bytes.addAll([gs, 0x21, 0x00]);
    bytes.addAll([esc, 0x45, 0x00]);
    bytes.add(0x0A);

    // Left align for details
    bytes.addAll([esc, 0x61, 0x00]); // ESC a 0 - left

    bytes.addAll(_text('Fecha: ${dateFormat.format(order.createdAt)}'));
    bytes.addAll(_text('Pago: ${_paymentLabel(order.paymentMethod)}'));
    bytes.addAll(_text('--------------------------------'));

    // Items
    for (final item in order.items) {
      final price = formatter.format(item.totalInCents ~/ 100);
      bytes.addAll(_text('${item.quantity}x ${item.product.name}'));

      // Show modifiers if any
      if (item.modifiers.isNotEmpty) {
        final modLabel = item.modifiers.map((m) => m.name).join(', ');
        bytes.addAll(_text('  > $modLabel'));
      }

      // Right-align price
      bytes.addAll(_text('   \$$price'));
    }

    bytes.addAll(_text('--------------------------------'));

    // Total - bold
    bytes.addAll([esc, 0x45, 0x01]);
    final total = formatter.format(order.totalInCents ~/ 100);
    bytes.addAll(_text('TOTAL: \$$total'));
    bytes.addAll([esc, 0x45, 0x00]);

    // Center footer
    bytes.addAll([esc, 0x61, 0x01]);
    bytes.addAll(_text('================================'));
    bytes.addAll(_text('Gracias por su compra!'));
    bytes.add(0x0A);
    bytes.add(0x0A);
    bytes.add(0x0A);

    // Cut paper
    bytes.addAll([gs, 0x56, 0x00]); // GS V 0 - full cut

    return bytes;
  }

  /// Print an order receipt
  static Future<bool> printReceipt(String address, Order order) async {
    final bytes = generateReceiptBytes(order);
    return printRaw(address, bytes);
  }

  static List<int> _text(String text) {
    final bytes = <int>[];
    // Convert to Latin-1 (most thermal printers use this)
    for (final char in text.codeUnits) {
      bytes.add(char < 256 ? char : 0x3F); // ? for unsupported chars
    }
    bytes.add(0x0A); // LF
    return bytes;
  }

  static String _paymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.transfer:
        return 'Transferencia';
    }
  }
}
