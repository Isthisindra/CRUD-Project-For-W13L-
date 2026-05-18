// lib/screens/home_screen.dart
// Halaman utama yang menampilkan daftar semua item per tim.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../providers/team_provider.dart';
import '../models/item_model.dart';
import '../widgets/item_card.dart';
import 'add_screen.dart';
import 'detail_screen.dart';
import 'team_screen.dart';
import 'dm_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Muat data saat pertama kali halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final team = context.read<TeamProvider>().activeTeam;
      if (team != null) {
        context.read<ItemProvider>().loadItems(team.id);
      }
    });
  }

  /// Tampilkan dialog konfirmasi hapus item.
  void _confirmDelete(BuildContext context, String id, String name, String teamId) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Hapus Item'),
        content: Text('Yakin ingin menghapus "$name"?'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<ItemProvider>().deleteItem(id, teamId);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final activeTeam = context.watch<TeamProvider>().activeTeam;

    if (activeTeam == null) {
      return const CupertinoPageScaffold(
        child: Center(child: Text('Tidak ada tim aktif')),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(builder: (_) => const TeamScreen()),
            );
          },
          child: const Icon(CupertinoIcons.group),
        ),
        middle: Text(activeTeam.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => const DMListScreen()),
                );
              },
              child: const Icon(CupertinoIcons.chat_bubble_2),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => const AddScreen()),
                );
                // Refresh setelah kembali dari AddScreen
                if (context.mounted) {
                  context.read<ItemProvider>().loadItems(activeTeam.id);
                }
              },
              child: const Icon(CupertinoIcons.add),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: _buildBody(context, provider, activeTeam.id),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ItemProvider provider, String teamId) {
    // Tampilkan loading indicator
    if (provider.isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    // Tampilkan pesan error jika ada
    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 48,
              color: CupertinoColors.destructiveRed,
            ),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: CupertinoColors.secondaryLabel),
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: () => provider.loadItems(teamId),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Tampilkan pesan jika list kosong
    if (provider.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.tray,
              size: 64,
              color: CupertinoColors.systemGrey3,
            ),
            SizedBox(height: 12),
            Text(
              'Belum ada item di tim ini.',
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Ketuk + untuk menambahkan.',
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.tertiaryLabel,
              ),
            ),
          ],
        ),
      );
    }

    // Tampilkan list item
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final Item item = provider.items[index];
        return ItemCard(
          item: item,
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => DetailScreen(item: item),
              ),
            );
          },
          onDelete: () => _confirmDelete(context, item.id, item.name, teamId),
        );
      },
    );
  }
}
