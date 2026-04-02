import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/promo.dart';
import '../../providers/database_provider.dart';

final adminPromosProvider = FutureProvider<List<Promo>>((ref) async {
  final repo = ref.watch(promoRepositoryProvider);
  return repo.getAllPromos();
});

class PromoManagementScreen extends ConsumerWidget {
  const PromoManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promosAsync = ref.watch(adminPromosProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text('Gestion de ofertas',
            style: AppTypography.headline2
                .copyWith(color: AppColors.textOnPrimary, fontSize: 24)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await _showPromoForm(context, ref);
              ref.invalidate(adminPromosProvider);
            },
          ),
        ],
      ),
      body: promosAsync.when(
        data: (promos) {
          if (promos.isEmpty) {
            return const Center(child: Text('No hay ofertas'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.paddingS),
            itemCount: promos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                  border: promo.isCurrentlyActive
                      ? Border.all(color: AppColors.success, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    // Color preview
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _parseColor(promo.backgroundColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_offer,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(promo.title,
                              style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600, fontSize: 18)),
                          Text(
                            promo.isPercentDiscount
                                ? '${promo.discountPercent}% descuento'
                                : promo.isAmountDiscount
                                    ? '\$${promo.discountAmountCents ~/ 100} descuento'
                                    : 'Sin descuento',
                            style: AppTypography.bodyMedium.copyWith(
                                fontSize: 14,
                                color: AppColors.textSecondary),
                          ),
                          if (promo.endDate != null)
                            Text(
                              'Hasta ${DateFormat('dd/MM/yyyy').format(promo.endDate!)}',
                              style: AppTypography.bodyMedium.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    Switch(
                      value: promo.active,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) async {
                        await ref
                            .read(promoRepositoryProvider)
                            .togglePromoActive(promo.id, val);
                        ref.invalidate(adminPromosProvider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () async {
                        await _showPromoForm(context, ref, promo: promo);
                        ref.invalidate(adminPromosProvider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Eliminar oferta'),
                            content:
                                Text('Eliminar "${promo.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Eliminar',
                                    style:
                                        TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(promoRepositoryProvider)
                              .deletePromo(promo.id);
                          ref.invalidate(adminPromosProvider);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, _) =>
            const Center(child: Text('Error al cargar ofertas')),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.promoRed;
    }
  }

  Future<void> _showPromoForm(BuildContext context, WidgetRef ref,
      {Promo? promo}) async {
    final titleCtrl = TextEditingController(text: promo?.title ?? '');
    final subtitleCtrl = TextEditingController(text: promo?.subtitle ?? '');
    final discountCtrl = TextEditingController(
        text: promo != null ? '${promo.discountPercent}' : '');
    bool isPercent = promo?.isPercentDiscount ?? true;
    final isEdit = promo != null;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Editar oferta' : 'Nueva oferta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titulo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subtitleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subtitulo (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('% Descuento'),
                      selected: isPercent,
                      selectedColor: AppColors.primary,
                      onSelected: (_) =>
                          setDialogState(() => isPercent = true),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('\$ Monto fijo'),
                      selected: !isPercent,
                      selectedColor: AppColors.primary,
                      onSelected: (_) =>
                          setDialogState(() => isPercent = false),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: discountCtrl,
                  decoration: InputDecoration(
                    labelText: isPercent
                        ? 'Porcentaje de descuento'
                        : 'Monto de descuento (CLP)',
                    border: const OutlineInputBorder(),
                    suffixText: isPercent ? '%' : 'CLP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;

                final discountVal = int.tryParse(discountCtrl.text) ?? 0;
                final newPromo = Promo(
                  id: isEdit
                      ? promo.id
                      : 'promo_${DateTime.now().microsecondsSinceEpoch}',
                  title: title,
                  subtitle: subtitleCtrl.text.trim().isEmpty
                      ? null
                      : subtitleCtrl.text.trim(),
                  discountPercent: isPercent ? discountVal : 0,
                  discountAmountCents: !isPercent ? discountVal * 100 : 0,
                  active: promo?.active ?? true,
                );

                final repo = ref.read(promoRepositoryProvider);
                if (isEdit) {
                  await repo.updatePromo(newPromo);
                } else {
                  await repo.insertPromo(newPromo);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text(isEdit ? 'Guardar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }
}
