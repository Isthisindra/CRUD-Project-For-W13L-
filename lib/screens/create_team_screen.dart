// lib/screens/create_team_screen.dart
// Halaman "Create Team" dengan desain Stock+.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_text_field.dart';
import '../widgets/stock_button.dart';
import 'home_screen.dart';
import 'join_team_screen.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Gagal Buat Tim'),
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

  Future<void> _createTeam() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final pass = _passController.text;

    if (name.isEmpty || code.isEmpty || pass.isEmpty) {
      _showError('Semua field wajib diisi.');
      return;
    }

    if (code.contains(' ')) {
      _showError('Kode Tim tidak boleh mengandung spasi.');
      return;
    }

    if (pass.length < 4) {
      _showError('Password Tim minimal 4 karakter.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<TeamProvider>();
      final success = await provider.createTeam(
        name: name,
        teamCode: code,
        teamPass: pass,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          _showError(provider.errorMessage ?? 'Gagal membuat tim.');
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
                'Create Team',
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
                controller: _nameController,
                placeholder: 'Team Name',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppTheme.spacingLG),
              StockTextField(
                controller: _codeController,
                placeholder: 'Team Code (no spaces)',
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
                label: 'Create Team',
                onPressed: _isLoading ? null : _createTeam,
                isLoading: _isLoading,
              ),
              const SizedBox(height: AppTheme.spacingMD),
              StockButton(
                label: 'Join Team',
                style: StockButtonStyle.outlined,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(builder: (_) => const JoinTeamScreen()),
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
