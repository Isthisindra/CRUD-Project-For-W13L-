// lib/screens/team_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().loadUserTeams();
    });
  }

  void _showCreateTeamModal() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final passController = TextEditingController();

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        color: CupertinoColors.systemBackground,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SafeArea(
          child: Column(
            children: [
              const Text('Buat Tim Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CupertinoTextField(controller: nameController, placeholder: 'Nama Tim', padding: const EdgeInsets.all(12)),
              const SizedBox(height: 12),
              CupertinoTextField(controller: codeController, placeholder: 'Kode Tim (tanpa spasi)', padding: const EdgeInsets.all(12)),
              const SizedBox(height: 12),
              CupertinoTextField(controller: passController, placeholder: 'Password Tim', obscureText: true, padding: const EdgeInsets.all(12)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  child: const Text('Buat Tim'),
                  onPressed: () async {
                    if (codeController.text.contains(' ') || passController.text.length < 4) {
                      // show error
                      return;
                    }
                    final provider = context.read<TeamProvider>();
                    final success = await provider.createTeam(
                      name: nameController.text,
                      teamCode: codeController.text,
                      teamPass: passController.text,
                    );
                    if (success && mounted) {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(builder: (_) => const HomeScreen()),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinTeamModal() {
    final codeController = TextEditingController();
    final passController = TextEditingController();

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        color: CupertinoColors.systemBackground,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SafeArea(
          child: Column(
            children: [
              const Text('Gabung Tim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              CupertinoTextField(controller: codeController, placeholder: 'Kode Tim', padding: const EdgeInsets.all(12)),
              const SizedBox(height: 12),
              CupertinoTextField(controller: passController, placeholder: 'Password Tim', obscureText: true, padding: const EdgeInsets.all(12)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  child: const Text('Gabung Tim'),
                  onPressed: () async {
                    final provider = context.read<TeamProvider>();
                    final success = await provider.joinTeam(
                      teamCode: codeController.text,
                      teamPass: passController.text,
                    );
                    if (success && mounted) {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(builder: (_) => const HomeScreen()),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeamProvider>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Pilih Tim'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.square_arrow_right),
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if (mounted) {
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : provider.teams.isEmpty
                      ? const Center(child: Text('Belum ada tim. Buat atau gabung!'))
                      : ListView.builder(
                          itemCount: provider.teams.length,
                          itemBuilder: (context, index) {
                            final team = provider.teams[index];
                            return CupertinoListTile(
                              title: Text(team.name),
                              subtitle: Text('Kode: ${team.teamCode}'),
                              trailing: const CupertinoListTileChevron(),
                              onTap: () {
                                provider.setActiveTeam(team);
                                Navigator.of(context).pushReplacement(
                                  CupertinoPageRoute(builder: (_) => const HomeScreen()),
                                );
                              },
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: _showCreateTeamModal,
                      child: const Text('Buat Tim Baru'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.activeGreen,
                      onPressed: _showJoinTeamModal,
                      child: const Text('Gabung Tim'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
