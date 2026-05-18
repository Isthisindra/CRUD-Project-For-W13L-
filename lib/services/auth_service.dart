// lib/services/auth_service.dart
// Menangani semua operasi autentikasi menggunakan Supabase Auth.
// Email internal dibentuk dari username: "$username@app.local"

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Konversi username ke format email internal.
  String _toEmail(String username) => '$username@app.local';

  /// Daftar akun baru. Simpan name & username ke user metadata
  /// agar bisa dibaca oleh trigger Supabase untuk insert ke tabel profiles.
  Future<void> register({
    required String name,
    required String username,
    required String password,
  }) async {
    await _client.auth.signUp(
      email: _toEmail(username),
      password: password,
      data: {
        'name': name,
        'username': username,
      },
    );
  }

  /// Login dengan username dan password.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: _toEmail(username),
      password: password,
    );
  }

  /// Logout dari sesi aktif.
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Ambil objek User Supabase dari sesi aktif (null jika belum login).
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Ambil profil user dari tabel 'profiles' berdasarkan ID sesi aktif.
  /// Mengembalikan null jika tidak ada sesi atau profil belum ada.
  Future<UserModel?> getCurrentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from(profilesTable)
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;
    return UserModel.fromMap(data);
  }
}
