// lib/services/team_service.dart
// Menangani operasi CRUD untuk tim dan keanggotaan tim di Supabase.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class TeamService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Buat tim baru dan otomatis tambahkan creator sebagai member pertama.
  Future<TeamModel> createTeam({
    required String name,
    required String teamCode,
    required String teamPass,
  }) async {
    final userId = _client.auth.currentUser!.id;

    // Insert tim baru
    final data = await _client
        .from(teamsTable)
        .insert({
          'name': name,
          'team_code': teamCode,
          'team_pass': teamPass,
          'created_by': userId,
        })
        .select()
        .single();

    final team = TeamModel.fromMap(data);

    // Tambahkan creator sebagai member
    await _client.from(teamMembersTable).insert({
      'team_id': team.id,
      'user_id': userId,
    });

    return team;
  }

  /// Gabung ke tim menggunakan team_code dan team_pass.
  /// Lempar exception jika kode/pass salah atau sudah jadi member.
  Future<TeamModel> joinTeam({
    required String teamCode,
    required String teamPass,
  }) async {
    final userId = _client.auth.currentUser!.id;

    // Cari tim berdasarkan team_code
    final data = await _client
        .from(teamsTable)
        .select()
        .eq('team_code', teamCode)
        .maybeSingle();

    if (data == null) {
      throw Exception('Kode tim tidak ditemukan.');
    }

    final team = TeamModel.fromMap(data);

    // Validasi password tim
    if (team.teamPass != teamPass) {
      throw Exception('Password tim salah.');
    }

    // Cek apakah sudah jadi member
    final existingMember = await _client
        .from(teamMembersTable)
        .select()
        .eq('team_id', team.id)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingMember != null) {
      throw Exception('Kamu sudah bergabung dengan tim ini.');
    }

    // Tambahkan sebagai member
    await _client.from(teamMembersTable).insert({
      'team_id': team.id,
      'user_id': userId,
    });

    return team;
  }

  /// Ambil semua tim yang diikuti oleh user yang sedang login.
  Future<List<TeamModel>> getUserTeams() async {
    final userId = _client.auth.currentUser!.id;

    // Query melalui tabel relasi team_members
    final data = await _client
        .from(teamMembersTable)
        .select('team_id, teams(*)')
        .eq('user_id', userId);

    return (data as List<dynamic>)
        .map((e) => TeamModel.fromMap(e['teams'] as Map<String, dynamic>))
        .toList();
  }

  /// Ambil semua member dari sebuah tim berdasarkan teamId.
  Future<List<UserModel>> getTeamMembers(String teamId) async {
    final data = await _client
        .from(teamMembersTable)
        .select('user_id, profiles(*)')
        .eq('team_id', teamId);

    return (data as List<dynamic>)
        .map((e) => UserModel.fromMap(e['profiles'] as Map<String, dynamic>))
        .toList();
  }
}
