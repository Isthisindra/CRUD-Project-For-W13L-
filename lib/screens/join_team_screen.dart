// lib/screens/join_team_screen.dart
// Halaman "Join Team" dengan desain Stock+.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_text_field.dart';
import '../widgets/stock_button.dart';
import 'home_screen.dart';
import 'create_team_screen.dart';

class JoinTeamScreen extends StatefulWidget {
  const JoinTeamScreen({super.key});

  @override
  State<JoinTeamScreen> createState() => _JoinTeamScreenState();
}

class _JoinTeamScreenState extends State<JoinTeamScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Gagal Join Tim'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinTeam() async {
    final code = _codeController.text.trim();
    final pass = _passController.text;

    if (code.isEmpty || pass.isEmpty) {
      _showError('Semua field wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<TeamProvider>();
      final success = await provider.joinTeam(
        teamCode: code,
        teamPass: pass,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          _showError(provider.errorMessage ?? 'Gagal bergabung dengan tim.');
          provider.clearError();
        }
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.white,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppTheme.white,
        border: null,
        previousPageTitle: 'Teams',
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXXL),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Title
              const Text(
                'Join Team',
                style: TextStyle(
                  fontSize: AppTheme.fontXXL,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.spacing4XL),

              // Text Fields
              StockTextField(
                controller: _codeController,
                placeholder: 'Team Code',
              ),
              const SizedBox(height: AppTheme.spacingLG),
              StockTextField(
                controller: _passController,
                placeholder: 'Team Password',
                obscureText: true,
              ),

              const Spacer(flex: 2),

              // Bottom Buttons
              StockButton(
                label: 'Join Team',
                onPressed: _isLoading ? null : _joinTeam,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppTheme.spacingMD),
              StockButton(
                label: 'Create Team',
                style: StockButtonStyle.outlined,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(builder: (_) => const CreateTeamScreen()),
                  );
                },
              ),
              const SizedBox(height: AppTheme.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}
