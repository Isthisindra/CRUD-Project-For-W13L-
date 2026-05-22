// lib/screens/detail_screen.dart
// Halaman detail item dengan desain Stock+.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/item_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_button.dart';
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

  String _formatPrice(double price) {
    final value = price.toInt();
    final str = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join();
  }

  /// Tampilkan dialog konfirmasi hapus.
  void _confirmDelete(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Hapus Item'),
        content: Text(
            'Yakin ingin menghapus "${item.name}"?\nTindakan ini tidak bisa dibatalkan.'),
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
              await context
                  .read<ItemProvider>()
                  .deleteItem(item.id, item.teamId);
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
      backgroundColor: AppTheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.white,
        border: const Border(),
        middle: const Text(
          'Detail Item',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingXXL),
          children: [
            const SizedBox(height: AppTheme.spacingLG),

            // Product image card - white wireframe icon in light blue container
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                ),
                child: const Icon(
                  CupertinoIcons.cube_box,
                  size: 80,
                  color: AppTheme.white,
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingXXL),

            // Product name
            Center(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: AppTheme.fontXXL,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppTheme.spacing3XL),

            // Info cards with grid metadata details
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Deskripsi',
                    item.description.isEmpty
                        ? 'Tidak ada deskripsi'
                        : item.description,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    'Stock Quantity',
                    '${item.stock} units',
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    'Buy Price',
                    'Rp ${_formatPrice(item.buyPrice)}',
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    'Sell Price',
                    'Rp ${_formatPrice(item.sellPrice)}',
                  ),
                  _buildDivider(),
                  _buildInfoRowWithBadge(
                    'Category',
                    item.category.isEmpty ? 'General' : item.category,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    'Dibuat Pada',
                    _formatDate(item.createdAt),
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    'Team ID',
                    item.teamId,
                    isSmall: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing3XL),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: StockButton(
                    label: 'Edit',
                    icon: CupertinoIcons.pencil,
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => EditScreen(item: item),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: StockButton(
                    label: 'Delete',
                    icon: CupertinoIcons.trash,
                    style: StockButtonStyle.danger,
                    onPressed: () => _confirmDelete(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSM,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmall ? AppTheme.fontXS : AppTheme.fontMD,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontFamily: isSmall ? 'Courier' : null,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithBadge(String label, String badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSM,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMD,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: AppTheme.fontSM,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      color: AppTheme.divider,
      height: 1,
    );
  }
}
