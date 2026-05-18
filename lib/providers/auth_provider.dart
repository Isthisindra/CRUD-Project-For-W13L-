// lib/providers/auth_provider.dart
// Mengelola state autentikasi user di seluruh aplikasi.

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  /// Muat profil user dari Supabase berdasarkan sesi aktif.
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    try {
      _currentUser = await _service.getCurrentProfile();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Daftar akun baru dan langsung muat profil.
  Future<bool> register({
    required String name,
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _service.register(name: name, username: username, password: password);
      // Tunggu sebentar agar trigger Supabase sempat membuat profil
      await Future.delayed(const Duration(milliseconds: 800));
      await loadCurrentUser();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Login dan muat profil user.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _service.login(username: username, password: password);
      await loadCurrentUser();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Logout dan bersihkan state.
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _service.logout();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Bersihkan pesan error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Parse pesan error Supabase menjadi lebih ramah pengguna.
  String _parseError(String raw) {
    if (raw.contains('Invalid login credentials')) {
      return 'Username atau password salah.';
    }
    if (raw.contains('User already registered')) {
      return 'Username sudah terdaftar.';
    }
    if (raw.contains('Password should be')) {
      return 'Password minimal 6 karakter.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
