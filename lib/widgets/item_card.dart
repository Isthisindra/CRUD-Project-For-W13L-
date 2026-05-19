// lib/widgets/item_card.dart
// Widget card reusable untuk menampilkan satu item di list HomeScreen.

import 'package:flutter/cupertino.dart';
import '../models/item_model.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ikon item
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.doc_text,
                  color: CupertinoColors.systemBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Konten teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description.isEmpty
                          ? 'Tidak ada deskripsi'
                          : item.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.secondaryLabel,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Tombol hapus
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onDelete,
                child: const Icon(
                  CupertinoIcons.trash,
                  color: CupertinoColors.destructiveRed,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
