import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/modifier.dart';

class ModifierDialog extends StatefulWidget {
  final String productName;
  final int basePriceCents;
  final List<ModifierGroup> groups;

  const ModifierDialog({
    super.key,
    required this.productName,
    required this.basePriceCents,
    required this.groups,
  });

  @override
  State<ModifierDialog> createState() => _ModifierDialogState();
}

class _ModifierDialogState extends State<ModifierDialog> {
  final Map<String, ProductModifierOption> _selections = {};

  @override
  void initState() {
    super.initState();
    // Set defaults
    for (final group in widget.groups) {
      final defaultOpt = group.options.where((o) => o.isDefault);
      if (defaultOpt.isNotEmpty) {
        _selections[group.name] = defaultOpt.first;
      }
    }
  }

  int get _totalAdjust {
    return _selections.values
        .fold(0, (sum, opt) => sum + opt.priceAdjustCents);
  }

  int get _finalPrice => widget.basePriceCents + _totalAdjust;

  static String _formatPrice(int cents) {
    final formatter = NumberFormat('#,###', 'es_CL');
    return '\$${formatter.format(cents ~/ 100)}';
  }

  List<SelectedModifier> get _selectedModifiers {
    return _selections.entries
        .map((e) => SelectedModifier(
              group: e.key,
              name: e.value.name,
              priceAdjustCents: e.value.priceAdjustCents,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.paddingM),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusM),
                ),
              ),
              child: Text(
                widget.productName,
                style: AppTypography.headline2
                    .copyWith(color: AppColors.textOnPrimary, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),

            // Modifier groups
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(AppSpacing.paddingS),
                children: widget.groups.map((group) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name,
                          style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: group.options.map((opt) {
                          final selected = _selections[group.name] == opt;
                          final label = opt.hasPriceAdjust
                              ? '${opt.name} (+${_formatPrice(opt.priceAdjustCents)})'
                              : opt.name;
                          return ChoiceChip(
                            label: Text(label, style: TextStyle(fontSize: 12)),
                            selected: selected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.textOnPrimary
                                  : AppColors.textPrimary,
                              fontSize: 12,
                            ),
                            onSelected: (_) {
                              setState(() => _selections[group.name] = opt);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.gapS),
                    ],
                  );
                }).toList(),
              ),
            ),

            // Footer with price and button
            Container(
              padding: const EdgeInsets.all(AppSpacing.paddingS),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: AppColors.border.withValues(alpha: 0.3))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total',
                          style: AppTypography.bodyMedium
                              .copyWith(fontSize: 12, color: AppColors.textSecondary)),
                      Text(_formatPrice(_finalPrice),
                          style: AppTypography.headline2.copyWith(fontSize: 20)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, (
                        modifiers: _selectedModifiers,
                        priceAdjust: _totalAdjust,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusXL),
                      ),
                    ),
                    child: const Text('Agregar',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
