import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/services/lan_sync_service.dart';

class LanSyncScreen extends StatefulWidget {
  const LanSyncScreen({super.key});

  @override
  State<LanSyncScreen> createState() => _LanSyncScreenState();
}

class _LanSyncScreenState extends State<LanSyncScreen> {
  final LanSyncService _sync = LanSyncService();
  String _status = 'Desconectado';
  String? _localIp;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadIp();
  }

  Future<void> _loadIp() async {
    final ip = await _sync.getLocalIp();
    setState(() => _localIp = ip);
  }

  Future<void> _startAsServer() async {
    setState(() => _loading = true);
    final success = await _sync.startServer();
    setState(() {
      _loading = false;
      _status = success
          ? 'Servidor activo en $_localIp:8090'
          : 'Error al iniciar servidor';
    });
  }

  Future<void> _discoverAndConnect() async {
    setState(() {
      _loading = true;
      _status = 'Buscando servidor en la red...';
    });

    final masterIp = await _sync.discoverMaster();
    setState(() {
      _loading = false;
      _status = masterIp != null
          ? 'Conectado a servidor: $masterIp'
          : 'No se encontro servidor en la red';
    });
  }

  Future<void> _connectManual(String ip) async {
    setState(() => _loading = true);
    final success = await _sync.connectToMaster(ip);
    setState(() {
      _loading = false;
      _status = success ? 'Conectado a $ip' : 'No se pudo conectar a $ip';
    });
  }

  @override
  void dispose() {
    _sync.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Sincronizacion LAN',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary, fontSize: 20)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.paddingM),
        children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingM),
            decoration: BoxDecoration(
              color: _sync.isConnected
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              border: _sync.isConnected
                  ? Border.all(color: AppColors.success)
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  _sync.isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 40,
                  color: _sync.isConnected
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(_status,
                    style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center),
                if (_localIp != null)
                  Text('IP local: $_localIp',
                      style: AppTypography.bodyMedium.copyWith(
                          fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.gapM),

          // Explanation
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingS),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            ),
            child: Text(
              'La sincronizacion LAN permite que multiples tablets compartan '
              'pedidos en la misma red WiFi.\n\n'
              'Servidor: La tablet de cocina (recibe pedidos de todos los kioscos)\n'
              'Cliente: Las tablets de kiosko (envian pedidos al servidor)',
              style: AppTypography.bodyMedium
                  .copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(height: AppSpacing.gapM),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else ...[
            // Start as server
            ElevatedButton.icon(
              onPressed: _startAsServer,
              icon: const Icon(Icons.dns),
              label: const Text('Iniciar como servidor (Cocina)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Auto-discover
            OutlinedButton.icon(
              onPressed: _discoverAndConnect,
              icon: const Icon(Icons.search),
              label: const Text('Buscar servidor automaticamente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                ),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),

            // Manual connect
            OutlinedButton.icon(
              onPressed: () {
                final controller = TextEditingController();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Conectar manualmente'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'IP del servidor',
                        hintText: '192.168.1.100',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _connectManual(controller.text.trim());
                        },
                        child: const Text('Conectar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.input),
              label: const Text('Conectar con IP manual'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
