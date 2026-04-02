import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/services/thermal_printer_service.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  List<PrinterDevice> _printers = [];
  String? _selectedAddress;
  bool _scanning = false;
  bool _autoPrint = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedAddress = prefs.getString('printer_address');
      _autoPrint = prefs.getBool('auto_print') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (_selectedAddress != null) {
      await prefs.setString('printer_address', _selectedAddress!);
    } else {
      await prefs.remove('printer_address');
    }
    await prefs.setBool('auto_print', _autoPrint);
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    final printers = await ThermalPrinterService.discoverPrinters();
    setState(() {
      _printers = printers;
      _scanning = false;
    });

    if (printers.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontraron impresoras')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Configurar impresora',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary, fontSize: 20)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.paddingM),
        children: [
          // Auto print toggle
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingS),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            ),
            child: Row(
              children: [
                const Icon(Icons.print, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Imprimir automaticamente',
                          style: AppTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600)),
                      Text('Imprimir recibo al confirmar pedido',
                          style: AppTypography.bodyMedium.copyWith(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Switch(
                  value: _autoPrint,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() => _autoPrint = v);
                    _saveSettings();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.gapM),

          // Selected printer
          if (_selectedAddress != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.paddingS),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                border: Border.all(color: AppColors.success),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Conectada: $_selectedAddress',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedAddress = null);
                      _saveSettings();
                    },
                    child: const Text('Desconectar',
                        style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.gapM),

          // Scan button
          ElevatedButton.icon(
            onPressed: _scanning ? null : _scan,
            icon: _scanning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.bluetooth_searching),
            label: Text(_scanning ? 'Buscando...' : 'Buscar impresoras'),
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

          // Discovered printers
          if (_printers.isNotEmpty) ...[
            Text('Impresoras encontradas',
                style: AppTypography.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ..._printers.map((printer) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    tileColor: AppColors.backgroundWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    ),
                    leading: Icon(
                      printer.type == PrinterConnectionType.bluetooth
                          ? Icons.bluetooth
                          : Icons.usb,
                      color: AppColors.primary,
                    ),
                    title: Text(printer.name),
                    subtitle: Text(printer.address,
                        style: const TextStyle(fontSize: 12)),
                    trailing: _selectedAddress == printer.address
                        ? const Icon(Icons.check_circle,
                            color: AppColors.success)
                        : null,
                    onTap: () {
                      setState(() => _selectedAddress = printer.address);
                      _saveSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Impresora seleccionada: ${printer.name}')),
                      );
                    },
                  ),
                )),
          ],

          if (_printers.isEmpty && !_scanning)
            Container(
              padding: const EdgeInsets.all(AppSpacing.paddingXL),
              child: Column(
                children: [
                  Icon(Icons.print_disabled,
                      size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text('Presiona "Buscar impresoras" para encontrar dispositivos',
                      style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
