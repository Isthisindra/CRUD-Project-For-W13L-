// lib/screens/detail_screen.dart
// Halaman detail untuk menampilkan informasi lengkap satu item.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import 'edit_screen.dart';

class DetailScreen extends StatelessWidget {
  final Item item;

  const DetailScreen({super.key, required this.item});

  /// Format DateTime ke string yang mudah dibaca.
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Tampilkan dialog konfirmasi hapus.
  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Hapus Item'),
        content: Text('Yakin ingin menghapus "${item.name}"?\nTindakan ini tidak bisa dibatalkan.'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop(); // Tutup dialog
              await context.read<ItemProvider>().deleteItem(item.id, item.teamId);
              if (context.mounted) {
                Navigator.of(context).pop(); // Kembali ke HomeScreen
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Detail Item'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => EditScreen(item: item),
              ),
            );
          },
          child: const Text('Edit'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),

            // Header ikon + nama
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      CupertinoIcons.doc_text_fill,
                      size: 36,
                      color: CupertinoColors.systemBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section: Deskripsi
            _buildSectionLabel('Deskripsi'),
            const SizedBox(height: 8),
            _buildInfoCard(
              child: Text(
                item.description.isEmpty ? 'Tidak ada deskripsi.' : item.description,
                style: TextStyle(
                  fontSize: 15,
                  color: item.description.isEmpty
                      ? CupertinoColors.tertiaryLabel
                      : CupertinoColors.label,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Section: Dibuat pada
            _buildSectionLabel('Dibuat Pada'),
            const SizedBox(height: 8),
            _buildInfoCard(
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.clock,
                    size: 16,
                    color: CupertinoColors.secondaryLabel,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(item.createdAt),
                    style: const TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.label,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section: ID
            _buildSectionLabel('ID'),
            const SizedBox(height: 8),
            _buildInfoCard(
              child: Text(
                item.id,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                  fontFamily: 'Courier',
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Tombol Edit
            CupertinoButton.filled(
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => EditScreen(item: item),
                  ),
                );
              },
              child: const Text('Edit Item'),
            ),

            const SizedBox(height: 12),

            // Tombol Hapus (destruktif)
            CupertinoButton(
              color: CupertinoColors.destructiveRed,
              onPressed: () => _confirmDelete(context),
              child: const Text(
                'Hapus Item',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Widget label section.
  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.secondaryLabel,
        letterSpacing: 0.5,
      ),
    );
  }

  /// Widget container info dengan rounded corner.
  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CupertinoColors.systemGrey5),
      ),
      child: child,
    );
  }
}
