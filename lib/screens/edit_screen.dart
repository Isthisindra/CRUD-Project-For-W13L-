// lib/screens/edit_screen.dart
// Halaman form untuk mengedit item yang sudah ada.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../providers/team_provider.dart';

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
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill field dengan data item yang ada
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController =
        TextEditingController(text: widget.item.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validasi dan kirim perubahan ke Supabase.
  Future<void> _updateItem() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    // Validasi: nama tidak boleh kosong
    if (name.isEmpty) {
      _showError('Nama item tidak boleh kosong.');
      return;
    }

    setState(() => _isUpdating = true);

    // Buat objek Item dengan data yang sudah diupdate
    final updatedItem = widget.item.copyWith(
      name: name,
      description: description,
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Edit Item'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isUpdating ? null : _updateItem,
          child: _isUpdating
              ? const CupertinoActivityIndicator()
              : const Text(
                  'Simpan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            // Label nama
            const Text(
              'Nama Item',
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _nameController,
              placeholder: 'Masukkan nama item',
              padding: const EdgeInsets.all(14),
              clearButtonMode: OverlayVisibilityMode.editing,
              textCapitalization: TextCapitalization.sentences,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Label deskripsi
            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.secondaryLabel,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _descriptionController,
              placeholder: 'Masukkan deskripsi (opsional)',
              padding: const EdgeInsets.all(14),
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: CupertinoColors.systemGrey4,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol update utama
            CupertinoButton.filled(
              onPressed: _isUpdating ? null : _updateItem,
              child: _isUpdating
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
