// lib/models/team_model.dart
// Model data untuk entitas Tim yang disimpan di tabel 'teams'.

class TeamModel {
  final String id;
  final String name;
  final String teamCode;
  final String teamPass;
  final String createdBy;
  final DateTime createdAt;

  const TeamModel({
    required this.id,
    required this.name,
    required this.teamCode,
    required this.teamPass,
    required this.createdBy,
    required this.createdAt,
  });

  /// Buat objek TeamModel dari Map (respons Supabase).
  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] as String,
      name: map['name'] as String,
      teamCode: map['team_code'] as String,
      teamPass: map['team_pass'] as String,
      createdBy: map['created_by'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Konversi ke Map untuk insert ke Supabase (tanpa id & created_at).
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'team_code': teamCode,
      'team_pass': teamPass,
      'created_by': createdBy,
    };
  }

  @override
  String toString() => 'TeamModel(id: $id, name: $name, teamCode: $teamCode)';
}
