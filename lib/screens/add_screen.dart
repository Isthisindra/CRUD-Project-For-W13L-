// lib/screens/add_screen.dart
// Halaman form untuk menambah item baru.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../providers/team_provider.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validasi dan simpan item baru.
  Future<void> _saveItem() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    // Validasi: nama tidak boleh kosong
    if (name.isEmpty) {
      _showError('Nama item tidak boleh kosong.');
      return;
    }

    setState(() => _isSaving = true);

    final teamId = context.read<TeamProvider>().activeTeam!.id;

    // Buat objek Item sementara (id dan createdAt akan di-generate DB)
    final newItem = Item(
      id: '',
      teamId: teamId,
      name: name,
      description: description,
      createdAt: DateTime.now(),
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
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Tambah Item'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isSaving ? null : _saveItem,
          child: _isSaving
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

            // Tombol simpan utama
            CupertinoButton.filled(
              onPressed: _isSaving ? null : _saveItem,
              child: _isSaving
                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                  : const Text('Simpan Item'),
            ),
          ],
        ),
      ),
    );
  }
}
