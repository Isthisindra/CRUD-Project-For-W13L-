// lib/screens/team_screen.dart
// Halaman "Your Teams" dengan desain Stock+.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_button.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'join_team_screen.dart';
import 'create_team_screen.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen>
    with SingleTickerProviderStateMixin {
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
      context.read<TeamProvider>().loadUserTeams();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamProvider>();

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.white,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingXXL,
                  AppTheme.spacingXL,
                  AppTheme.spacingXXL,
                  AppTheme.spacingLG,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Teams',
                      style: TextStyle(
                        fontSize: AppTheme.fontXXL,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      child: const Icon(
                        CupertinoIcons.square_arrow_right,
                        color: AppTheme.textSecondary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Teams list
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : provider.teams.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightBlue,
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusLG),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.group,
                                    size: 32,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingLG),
                                const Text(
                                  'Belum ada tim.',
                                  style: TextStyle(
                                    fontSize: AppTheme.fontMD,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingXS),
                                const Text(
                                  'Buat atau gabung tim untuk mulai!',
                                  style: TextStyle(
                                    fontSize: AppTheme.fontSM,
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingXXL,
                            ),
                            itemCount: provider.teams.length,
                            itemBuilder: (context, index) {
                              final team = provider.teams[index];
                              return _buildTeamCard(team, provider);
                            },
                          ),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingXXL),
                child: Column(
                  children: [
                    StockButton(
                      label: 'Create Team',
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const CreateTeamScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    StockButton(
                      label: 'Join Team',
                      style: StockButtonStyle.outlined,
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => const JoinTeamScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(team, TeamProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.setActiveTeam(team);
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
              child: const Icon(
                CupertinoIcons.cube_box,
                color: AppTheme.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: Text(
                team.name,
                style: const TextStyle(
                  fontSize: AppTheme.fontMD,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.square_arrow_right,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
