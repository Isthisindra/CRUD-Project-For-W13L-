// lib/screens/dm_list_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/team_provider.dart';
import '../services/team_service.dart';
import '../utils/app_theme.dart';
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
  int _selectedSegment = 0; // 0: Direct, 1: Groups

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
      backgroundColor: AppTheme.background,
      child: Column(
        children: [
          // Blue header matching home screen design system
          Container(
            padding: EdgeInsets.fromLTRB(
              AppTheme.spacingXXL,
              MediaQuery.of(context).padding.top + AppTheme.spacingLG,
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.spacingXS),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        ),
                        child: const Icon(
                          CupertinoIcons.back,
                          color: AppTheme.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingLG),
                    const Text(
                      'Team Chat',
                      style: TextStyle(
                        fontSize: AppTheme.fontXL,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sliding Segment Control for Direct / Groups
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingXXL,
              AppTheme.spacingLG,
              AppTheme.spacingXXL,
              AppTheme.spacingMD,
            ),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedSegment,
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
                    child: Text(
                      'Direct',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppTheme.fontSM,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacingSM),
                    child: Text(
                      'Groups',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppTheme.fontSM,
                      ),
                    ),
                  ),
                },
                onValueChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSegment = value;
                    });
                  }
                },
              ),
            ),
          ),

          // Chat body list
          Expanded(
            child: _buildChatList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXXL),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    if (_selectedSegment == 0) {
      // Direct message members list
      if (_members.isEmpty) {
        return const Center(
          child: Text(
            'Tidak ada member lain di tim ini.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXXL),
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return _buildDirectItem(member);
        },
      );
    } else {
      // Group chats mock list
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXXL),
        children: [
          _buildGroupItem('General Tim', 'Discussion room for everyone', '3'),
          _buildGroupItem('Inventory Updates', 'Logs of buying & selling activities', '0'),
          _buildGroupItem('Announcement board', 'Admin postings only', '1'),
        ],
      );
    }
  }

  Widget _buildDirectItem(UserModel member) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => DMChatScreen(otherUser: member),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Solid blue avatar with white user icon
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.person_fill,
                color: AppTheme.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingLG),

            // Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: AppTheme.fontMD,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Active now',
                    style: TextStyle(
                      fontSize: AppTheme.fontSM,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingMD),

            // Blue unread notification badge
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontXS,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupItem(String groupName, String subtitle, String unreadCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Solid blue avatar with white group icon
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.group_solid,
              color: AppTheme.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingLG),

          // Text section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: AppTheme.fontMD,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSM,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),

          // Blue unread notification badge if count > 0
          if (unreadCount != '0')
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  unreadCount,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontXS,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
