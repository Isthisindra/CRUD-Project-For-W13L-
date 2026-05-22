// lib/screens/add_screen.dart
// Halaman form untuk menambah item baru.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../providers/team_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_text_field.dart';
import '../widgets/stock_button.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isSaving = false;

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

  /// Validasi dan simpan item baru.
  Future<void> _saveItem() async {
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

    setState(() => _isSaving = true);

    final teamId = context.read<TeamProvider>().activeTeam!.id;

    // Parse values
    final stock = int.tryParse(stockStr) ?? 0;
    final buyPrice = double.tryParse(buyPriceStr) ?? 0.0;
    final sellPrice = double.tryParse(sellPriceStr) ?? 0.0;

    // Buat objek Item sementara (id dan createdAt akan di-generate DB)
    final newItem = Item(
      id: '',
      teamId: teamId,
      name: name,
      description: description,
      createdAt: DateTime.now(),
      stock: stock,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      category: category,
    );

    try {
      await context.read<ItemProvider>().addItem(newItem, teamId);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) _showError('Gagal menyimpan: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          'Tambah Item',
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

            // Simpan Button
            StockButton(
              label: 'Simpan Item',
              onPressed: _isSaving ? null : _saveItem,
              isLoading: _isSaving,
            ),
            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }
}
