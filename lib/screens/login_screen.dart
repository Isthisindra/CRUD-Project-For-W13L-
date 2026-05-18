// lib/screens/login_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/team_provider.dart';
import 'register_screen.dart';
import 'team_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Gagal Login'),
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

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('Username dan Password tidak boleh kosong.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      username: username,
      password: password,
    );

    if (mounted) {
      if (success) {
        // Cek tim
        final teamProvider = context.read<TeamProvider>();
        await teamProvider.loadUserTeams();
        if (mounted) {
          if (teamProvider.teams.isNotEmpty) {
            teamProvider.setActiveTeam(teamProvider.teams.first);
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(builder: (_) => const HomeScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(builder: (_) => const TeamScreen()),
            );
          }
        }
      } else if (authProvider.errorMessage != null) {
        _showError(authProvider.errorMessage!);
        authProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.person_circle, size: 80, color: CupertinoColors.systemBlue),
              const SizedBox(height: 32),
              CupertinoTextField(
                controller: _usernameController,
                placeholder: 'Username',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(CupertinoIcons.at),
                ),
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Password',
                obscureText: true,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(CupertinoIcons.lock),
                ),
                padding: const EdgeInsets.all(12),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Belum punya akun? Daftar di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
