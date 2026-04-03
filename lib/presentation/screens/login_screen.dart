import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/audit_log_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/database_provider.dart';
import 'home_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'kitchen/kitchen_screen.dart';
import 'menu_board_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    final restored = await ref.read(authProvider.notifier).restoreSession();
    if (!restored || !mounted) return;
    final user = ref.read(authProvider);
    if (user == null) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => user.role == UserRole.admin
            ? const AdminPanelScreen()
            : const KitchenScreen(),
      ),
    );
  }

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _error = false;
    });
    if (_pin.length == 4) _authenticate();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = false;
    });
  }

  Future<void> _authenticate() async {
    setState(() => _loading = true);
    final success = await ref.read(authProvider.notifier).login(_pin);
    setState(() => _loading = false);

    if (!success) {
      ref.read(auditLogRepositoryProvider).log(
            userId: 'unknown',
            userName: 'Desconocido',
            action: AuditAction.login,
            entityType: AuditEntityType.user,
            entityId: 'unknown',
            entityName: 'Intento fallido',
            details: 'PIN incorrecto',
          );
      setState(() {
        _error = true;
        _pin = '';
      });
      return;
    }

    if (!mounted) return;
    final user = ref.read(authProvider);
    if (user == null) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => user.role == UserRole.admin
            ? const AdminPanelScreen()
            : const KitchenScreen(),
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: isLandscape ? _buildLandscape() : _buildPortrait(),
      ),
    );
  }

  Widget _buildLandscape() {
    return Row(
      children: [
        // Left: Branding hero
        Expanded(
          flex: 5,
          child: _buildHeroSection(),
        ),
        // Right: PIN + actions
        Expanded(
          flex: 4,
          child: _buildPinSection(),
        ),
      ],
    );
  }

  Widget _buildPortrait() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: _buildHeroSection(),
          ),
          _buildPinSection(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9B17), Color(0xFFFF6B00)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.paddingXL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.coffee_rounded,
                        size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'KIOSKO',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                  Text(
                    'POINT OF SALE',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quick mode buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ModeButton(
                        icon: Icons.touch_app,
                        label: 'Ordenar',
                        onTap: () => _navigateTo(const HomeScreen()),
                      ),
                      const SizedBox(width: 12),
                      _ModeButton(
                        icon: Icons.tv,
                        label: 'Pedidos',
                        onTap: () => _navigateTo(const OrderDisplayScreen()),
                      ),
                      const SizedBox(width: 12),
                      _ModeButton(
                        icon: Icons.restaurant_menu,
                        label: 'Menu',
                        onTap: () => _navigateTo(const MenuBoardScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinSection() {
    return Container(
      color: AppColors.backgroundWarm,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Acceso personal',
                  style: AppTypography.headline2.copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text('Ingresa tu PIN de 4 digitos',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 20),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: filled ? 18 : 14,
                    height: filled ? 18 : 14,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled
                          ? (_error ? AppColors.error : AppColors.primary)
                          : Colors.transparent,
                      border: Border.all(
                        color: _error
                            ? AppColors.error
                            : (filled ? AppColors.primary : AppColors.border),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              if (_error) ...[
                const SizedBox(height: 8),
                Text('PIN incorrecto',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.error, fontSize: 13)),
              ],

              const SizedBox(height: 20),

              // Numpad
              if (_loading)
                const CircularProgressIndicator(color: AppColors.primary)
              else
                _buildNumpad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return SizedBox(
      width: 240,
      child: Column(
        children: [
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            ['', '0', '⌫'],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((key) {
                  if (key.isEmpty) return const SizedBox(width: 56, height: 56);
                  return _PinKey(
                    label: key,
                    onTap: () {
                      if (key == '⌫') {
                        _onBackspace();
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

class _PinKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PinKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBackspace = label == '⌫';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isBackspace
              ? Colors.transparent
              : AppColors.backgroundWhite,
          shape: BoxShape.circle,
          boxShadow: isBackspace
              ? null
              : [
                  BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: isBackspace
              ? Icon(Icons.backspace_outlined,
                  color: AppColors.textSecondary, size: 22)
              : Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}
