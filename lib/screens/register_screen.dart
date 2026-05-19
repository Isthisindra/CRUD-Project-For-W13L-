// lib/screens/register_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'team_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Gagal Mendaftar'),
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

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      _showError('Semua field wajib diisi.');
      return;
    }

    if (username.contains(' ')) {
      _showError('Username tidak boleh ada spasi.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: name,
      username: username,
      password: password,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (_) => const TeamScreen()),
        );
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
        middle: Text('Daftar'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                const Icon(CupertinoIcons.person_add_solid,
                    size: 80, color: CupertinoColors.systemBlue),
                const SizedBox(height: 32),
                CupertinoTextField(
                  controller: _nameController,
                  placeholder: 'Nama Lengkap',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(CupertinoIcons.person),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                const SizedBox(height: 16),
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
                    onPressed: isLoading ? null : _register,
                    child: isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white)
                        : const Text('Daftar'),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Sudah punya akun? Login di sini'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
