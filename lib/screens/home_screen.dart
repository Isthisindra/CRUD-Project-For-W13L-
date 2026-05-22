// lib/screens/home_screen.dart
// Halaman utama Stock+ — daftar item dengan search bar dan summary cards.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../providers/team_provider.dart';
import '../models/item_model.dart';
import '../utils/app_theme.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final team = context.read<TeamProvider>().activeTeam;
      if (team != null) {
        context.read<ItemProvider>().loadItems(team.id);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  /// Tampilkan dialog konfirmasi hapus item.
  void _confirmDelete(
      BuildContext context, String id, String name, String teamId) {
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

  List<Item> _getFilteredItems(List<Item> items) {
    if (_searchQuery.isEmpty) return items;
    return items
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  String _formatTotalValue(double value) {
    if (value >= 1e9) {
      double val = value / 1e9;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}B';
    } else if (value >= 1e6) {
      double val = value / 1e6;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}M';
    } else if (value >= 1e3) {
      double val = value / 1e3;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final activeTeam = context.watch<TeamProvider>().activeTeam;

    if (activeTeam == null) {
      return CupertinoPageScaffold(
        backgroundColor: AppTheme.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tidak ada tim aktif',
                  style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: AppTheme.spacingLG),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(builder: (_) => const TeamScreen()),
                  );
                },
                child: const Text('Pilih Tim'),
              ),
            ],
          ),
        ),
      );
    }

    final filteredItems = _getFilteredItems(provider.items);

    final totalItems = provider.items.length;
    final lowStockCount = provider.items.where((item) => item.stock <= 20).length;
    final totalValue = provider.items.fold<double>(0.0, (sum, item) => sum + (item.sellPrice * item.stock));

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blue header
              Container(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingXXL,
                  AppTheme.spacingLG,
                  AppTheme.spacingXXL,
                  AppTheme.spacingXXL,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(AppTheme.radiusXL),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: name + actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stock+',
                          style: TextStyle(
                            fontSize: AppTheme.fontXL,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.white.withValues(alpha: 0.95),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Row(
                          children: [
                            _buildHeaderIcon(
                              CupertinoIcons.group,
                              () {
                                Navigator.of(context).pushReplacement(
                                  CupertinoPageRoute(
                                      builder: (_) => const TeamScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: AppTheme.spacingSM),
                            _buildHeaderIcon(
                              CupertinoIcons.chat_bubble_2,
                              () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                      builder: (_) => const DMListScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingLG),

                    // Search bar
                    CupertinoTextField(
                      controller: _searchController,
                      placeholder: 'Search products...',
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(
                          CupertinoIcons.search,
                          color: AppTheme.textTertiary,
                          size: 18,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      placeholderStyle: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: AppTheme.fontSM,
                      ),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSM,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMD),
                      ),
                    ),
                  ],
                ),
              ),

              // Summary cards
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXXL),
                child: Row(
                  children: [
                    _buildStatCard(
                      'Total\nItems',
                      '$totalItems',
                      AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    _buildStatCard(
                      'Low\nStock',
                      '$lowStockCount',
                      AppTheme.danger,
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    _buildStatCard(
                      'Total\nValue',
                      'Rp ${_formatTotalValue(totalValue)}',
                      AppTheme.success,
                    ),
                  ],
                ),
              ),

              // Items list
              Expanded(
                child: _buildBody(context, provider, activeTeam.id,
                    filteredItems),
              ),
            ],
          ),
        ),
      ),
      // FAB
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
        ),
        child: Icon(
          icon,
          color: AppTheme.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontXS,
                color: AppTheme.textTertiary,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Row(
              children: [
                Container(
                  width: 3,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSM),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: AppTheme.fontXL,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ItemProvider provider, String teamId,
      List<Item> filteredItems) {
    if (provider.isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 48,
              color: AppTheme.danger,
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Text(
              provider.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            CupertinoButton(
              onPressed: () => provider.loadItems(teamId),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (provider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              ),
              child: const Icon(
                CupertinoIcons.cube_box,
                size: 32,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLG),
            const Text(
              'Belum ada item di tim ini.',
              style: TextStyle(
                fontSize: AppTheme.fontMD,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            const Text(
              'Ketuk + untuk menambahkan.',
              style: TextStyle(
                fontSize: AppTheme.fontSM,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingXXL,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final Item item = filteredItems[index];
            return ItemCard(
              item: item,
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => DetailScreen(item: item),
                  ),
                );
              },
              onDelete: () =>
                  _confirmDelete(context, item.id, item.name, teamId),
            );
          },
        ),

        // FAB
        Positioned(
          right: AppTheme.spacingXXL,
          bottom: AppTheme.spacingXXL,
          child: GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const AddScreen()),
              );
              if (context.mounted) {
                final team = context.read<TeamProvider>().activeTeam;
                if (team != null) {
                  context.read<ItemProvider>().loadItems(team.id);
                }
              }
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.add,
                color: AppTheme.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
