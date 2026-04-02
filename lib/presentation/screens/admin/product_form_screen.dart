import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/product.dart' as domain;
import '../../providers/database_provider.dart';
import '../../providers/categories_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final domain.Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  String? _selectedCategoryId;
  String? _imagePath;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product != null
          ? (widget.product!.priceInCents ~/ 100).toString()
          : '',
    );
    _descController =
        TextEditingController(text: widget.product?.description ?? '');
    _selectedCategoryId = widget.product?.categoryId;
    _imagePath = widget.product?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (picked == null) return;

    // Copy to app documents directory
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(dir.path, 'product_images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}${p.extension(picked.path)}';
    final destPath = p.join(imagesDir.path, fileName);
    await File(picked.path).copy(destPath);

    setState(() {
      _imagePath = destPath;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoria')),
      );
      return;
    }

    setState(() => _saving = true);

    final priceInCents = (int.tryParse(_priceController.text) ?? 0) * 100;
    final product = domain.Product(
      id: _isEditing
          ? widget.product!.id
          : 'p_${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      imageUrl: _imagePath ?? '',
      priceInCents: priceInCents,
      categoryId: _selectedCategoryId!,
      description:
          _descController.text.trim().isEmpty ? null : _descController.text.trim(),
    );

    final repo = ref.read(productRepositoryProvider);
    if (_isEditing) {
      await repo.updateProduct(product);
    } else {
      await repo.insertProduct(product);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        title: Text(
          _isEditing ? 'Editar producto' : 'Nuevo producto',
          style: AppTypography.headline2
              .copyWith(color: AppColors.textOnPrimary, fontSize: 24),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.paddingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _imagePath != null && _imagePath!.startsWith('/')
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusM),
                          child: Image.file(File(_imagePath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, _, _) =>
                                  _buildImagePlaceholder()),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(height: AppSpacing.gapM),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: AppSpacing.gapM),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio (CLP)',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requerido';
                  if ((int.tryParse(v) ?? 0) <= 0) return 'Precio invalido';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.gapM),

              // Category dropdown
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(
                          value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Error cargando categorias'),
              ),
              const SizedBox(height: AppSpacing.gapM),

              // Description
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Descripcion (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.gapXL),

              // Save button
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  ),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isEditing ? 'Guardar cambios' : 'Crear producto',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate,
            size: 50, color: AppColors.textSecondary),
        const SizedBox(height: 8),
        Text('Agregar imagen',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary, fontSize: 16)),
      ],
    );
  }
}
