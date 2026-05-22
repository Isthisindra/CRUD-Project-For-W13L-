// lib/screens/register_screen.dart
// Halaman daftar akun baru dengan desain Stock+.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/stock_text_field.dart';
import '../widgets/stock_button.dart';
import 'login_screen.dart';
import 'team_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
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
      backgroundColor: AppTheme.white,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXXL),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                      ),
                      child: const Icon(
                        CupertinoIcons.cube_box,
                        size: 40,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLG),

                    // App Name
                    const Text(
                      'Stock+',
                      style: TextStyle(
                        fontSize: AppTheme.font3XL,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing3XL),

                    // Username field
                    StockTextField(
                      controller: _usernameController,
                      placeholder: 'Username',
                    ),
                    const SizedBox(height: AppTheme.spacingLG),

                    // Name field
                    StockTextField(
                      controller: _nameController,
                      placeholder: 'Name',
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: AppTheme.spacingLG),

                    // Password field
                    StockTextField(
                      controller: _passwordController,
                      placeholder: 'Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: AppTheme.spacing3XL),

                    // Register button
                    StockButton(
                      label: 'Login',
                      onPressed: isLoading ? null : _register,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: AppTheme.spacingLG),

                    // Login link
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          CupertinoPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Sudah punya akun? Login di sini',
                        style: TextStyle(
                          fontSize: AppTheme.fontSM,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing3XL),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
