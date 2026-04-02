import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'kitchen/kitchen_screen.dart';
import 'order_display_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _pin = '';
  bool _error = false;
  bool _loading = false;

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _error = false;
    });
    if (_pin.length == 4) {
      _authenticate();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = false;
    });
  }

  void _onClear() {
    setState(() {
      _pin = '';
      _error = false;
    });
  }

  Future<void> _authenticate() async {
    setState(() => _loading = true);
    final success = await ref.read(authProvider.notifier).login(_pin);
    setState(() => _loading = false);

    if (!success) {
      setState(() {
        _error = true;
        _pin = '';
      });
      return;
    }

    if (!mounted) return;
    final user = ref.read(authProvider);
    if (user == null) return;

    final Widget destination;
    switch (user.role) {
      case UserRole.admin:
        destination = const AdminPanelScreen();
      case UserRole.worker:
        destination = const KitchenScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  void _enterAsKiosk() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Title
              const Icon(Icons.storefront, size: 80, color: AppColors.primary),
              const SizedBox(height: AppSpacing.gapM),
              Text('Kiosko POS', style: AppTypography.headline2),
              const SizedBox(height: AppSpacing.gapS),
              Text('Ingresa tu PIN', style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.gapXL),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < _pin.length
                            ? (_error ? AppColors.error : AppColors.primary)
                            : Colors.transparent,
                        border: Border.all(
                          color: _error ? AppColors.error : AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              if (_error) ...[
                const SizedBox(height: AppSpacing.gapS),
                Text(
                  'PIN incorrecto',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.error, fontSize: 18),
                ),
              ],

              const SizedBox(height: AppSpacing.gapXL),

              // Numpad
              if (_loading)
                const CircularProgressIndicator(color: AppColors.primary)
              else
                _buildNumpad(),

              const SizedBox(height: AppSpacing.gapXL),

              // Kiosk mode button
              TextButton(
                onPressed: _enterAsKiosk,
                child: Text(
                  'Entrar como Kiosko',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.gapS),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const OrderDisplayScreen(),
                    ),
                  );
                },
                child: Text(
                  'Pantalla de pedidos',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['C', '0', '⌫'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((key) {
                  return _NumpadButton(
                    label: key,
                    onTap: () {
                      if (key == '⌫') {
                        _onBackspace();
                      } else if (key == 'C') {
                        _onClear();
                      } else {
                        _onDigit(key);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumpadButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSpecial = label == 'C' || label == '⌫';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isSpecial
              ? AppColors.backgroundWhite
              : AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          border: isSpecial
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: isSpecial ? AppColors.primary : AppColors.textOnPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
