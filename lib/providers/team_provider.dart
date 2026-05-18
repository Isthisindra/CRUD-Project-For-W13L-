// lib/providers/team_provider.dart
// Mengelola state tim yang diikuti user dan tim yang sedang aktif.

import 'package:flutter/foundation.dart';
import '../models/team_model.dart';
import '../services/team_service.dart';

class TeamProvider extends ChangeNotifier {
  final TeamService _service = TeamService();

  List<TeamModel> _teams = [];
  TeamModel? _activeTeam;
  bool _isLoading = false;
  String? _errorMessage;

  List<TeamModel> get teams => _teams;
  TeamModel? get activeTeam => _activeTeam;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasActiveTeam => _activeTeam != null;

  /// Muat semua tim yang diikuti user yang sedang login.
  Future<void> loadUserTeams() async {
    _setLoading(true);
    try {
      _teams = await _service.getUserTeams();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat tim: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Buat tim baru, tambahkan ke list, lalu set sebagai aktif.
  Future<bool> createTeam({
    required String name,
    required String teamCode,
    required String teamPass,
  }) async {
    _setLoading(true);
    try {
      final team = await _service.createTeam(
        name: name,
        teamCode: teamCode,
        teamPass: teamPass,
      );
      _teams.add(team);
      _activeTeam = team;
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Gabung ke tim yang sudah ada menggunakan kode dan password.
  Future<bool> joinTeam({
    required String teamCode,
    required String teamPass,
  }) async {
    _setLoading(true);
    try {
      final team = await _service.joinTeam(
        teamCode: teamCode,
        teamPass: teamPass,
      );
      if (!_teams.any((t) => t.id == team.id)) {
        _teams.add(team);
      }
      _activeTeam = team;
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _parseError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Tetapkan tim yang sedang aktif.
  void setActiveTeam(TeamModel team) {
    _activeTeam = team;
    notifyListeners();
  }

  /// Reset tim aktif (misal saat logout).
  void clearActiveTeam() {
    _activeTeam = null;
    _teams = [];
    notifyListeners();
  }

  /// Bersihkan pesan error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _parseError(String raw) {
    if (raw.contains('Kode tim tidak ditemukan')) return 'Kode tim tidak ditemukan.';
    if (raw.contains('Password tim salah')) return 'Password tim salah.';
    if (raw.contains('sudah bergabung')) return 'Kamu sudah bergabung dengan tim ini.';
    if (raw.contains('duplicate') || raw.contains('unique')) {
      return 'Kode tim sudah dipakai. Gunakan kode lain.';
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
