// lib/screens/dm_list_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/team_provider.dart';
import '../services/team_service.dart';
import 'dm_chat_screen.dart';

class DMListScreen extends StatefulWidget {
  const DMListScreen({super.key});

  @override
  State<DMListScreen> createState() => _DMListScreenState();
}

class _DMListScreenState extends State<DMListScreen> {
  List<UserModel> _members = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final team = context.read<TeamProvider>().activeTeam;
      if (team == null) return;

      final currentUser = context.read<AuthProvider>().currentUser;

      final service = TeamService();
      final allMembers = await service.getTeamMembers(team.id);
      
      // Hilangkan diri sendiri dari daftar
      if (currentUser != null) {
        allMembers.removeWhere((m) => m.id == currentUser.id);
      }

      if (mounted) {
        setState(() {
          _members = allMembers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Pesan DM'),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _members.isEmpty
                    ? const Center(child: Text('Tidak ada member lain di tim ini.'))
                    : ListView.builder(
                        itemCount: _members.length,
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          return CupertinoListTile(
                            leading: const Icon(CupertinoIcons.person_crop_circle),
                            title: Text(member.name),
                            subtitle: Text('@${member.username}'),
                            trailing: const CupertinoListTileChevron(),
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (_) => DMChatScreen(otherUser: member),
                                ),
                              );
                            },
                          );
                        },
                      ),
      ),
    );
  }
}
