// lib/screens/edit_screen.dart
// Halaman form untuk mengedit item yang sudah ada.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../providers/team_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_text_field.dart';
import '../widgets/stock_button.dart';

class EditScreen extends StatefulWidget {
  /// Item yang akan diedit (diterima dari halaman sebelumnya).
  final Item item;

  const EditScreen({super.key, required this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _stockController;
  late TextEditingController _buyPriceController;
  late TextEditingController _sellPriceController;
  late TextEditingController _categoryController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill field dengan data item yang ada
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(text: widget.item.description);
    _stockController = TextEditingController(text: widget.item.stock.toString());
    _buyPriceController = TextEditingController(text: widget.item.buyPrice.toString());
    _sellPriceController = TextEditingController(text: widget.item.sellPrice.toString());
    _categoryController = TextEditingController(text: widget.item.category);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  /// Validasi dan kirim perubahan ke Supabase.
  Future<void> _updateItem() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final stockStr = _stockController.text.trim();
    final buyPriceStr = _buyPriceController.text.trim();
    final sellPriceStr = _sellPriceController.text.trim();
    final category = _categoryController.text.trim();

    // Validasi: nama tidak boleh kosong
    if (name.isEmpty) {
      _showError('Nama item tidak boleh kosong.');
      return;
    }

    setState(() => _isUpdating = true);

    // Parse values
    final stock = int.tryParse(stockStr) ?? 0;
    final buyPrice = double.tryParse(buyPriceStr) ?? 0.0;
    final sellPrice = double.tryParse(sellPriceStr) ?? 0.0;

    // Buat objek Item dengan data yang sudah diupdate
    final updatedItem = widget.item.copyWith(
      name: name,
      description: description,
      stock: stock,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      category: category,
    );

    final teamId = context.read<TeamProvider>().activeTeam!.id;

    try {
      await context.read<ItemProvider>().updateItem(widget.item.id, updatedItem, teamId);
      if (mounted) {
        // Kembali dua halaman (ke HomeScreen), lewati DetailScreen
        Navigator.of(context)
          ..pop() // Tutup EditScreen
          ..pop(); // Tutup DetailScreen
      }
    } catch (e) {
      if (mounted) _showError('Gagal mengupdate: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  /// Tampilkan dialog error.
  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Kesalahan'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.white,
        border: const Border(),
        middle: const Text(
          'Edit Item',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingXXL),
          children: [
            // Nama Item
            const Text(
              'Nama Item',
              style: TextStyle(
                fontSize: AppTheme.fontSM,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            StockTextField(
              controller: _nameController,
              placeholder: 'Masukkan nama item',
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Deskripsi
            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: AppTheme.fontSM,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            StockTextField(
              controller: _descriptionController,
              placeholder: 'Masukkan deskripsi (opsional)',
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Stock Quantity
            const Text(
              'Stock Quantity',
              style: TextStyle(
                fontSize: AppTheme.fontSM,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            StockTextField(
              controller: _stockController,
              placeholder: 'Masukkan jumlah stok (e.g. 150)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Buy Price
            const Text(
              'Buy Price (Harga Beli)',
              style: TextStyle(
                fontSize: AppTheme.fontSM,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            StockTextField(
              controller: _buyPriceController,
              placeholder: 'Masukkan harga beli (e.g. 2000)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Sell Price
            const Text(
              'Sell Price (Harga Jual)',
              style: TextStyle(
                fontSize: AppTheme.fontSM,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            StockTextField(
              controller: _sellPriceController,
              placeholder: 'Masukkan harga jual (e.g. 2500)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppTheme.spacingXL),

            // Category
            const Text(
              'Kategori',
              style: TextStyle(
                fontSize: AppTheme.fontSM,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            StockTextField(
              controller: _categoryController,
              placeholder: 'Masukkan kategori (e.g. Food, Drink, Gadget)',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppTheme.spacing3XL),

            // Simpan Perubahan Button
            StockButton(
              label: 'Simpan Perubahan',
              onPressed: _isUpdating ? null : _updateItem,
              isLoading: _isUpdating,
            ),
            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }
}
