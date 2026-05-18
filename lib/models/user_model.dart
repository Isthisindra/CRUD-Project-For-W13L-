// lib/models/user_model.dart
// Model data untuk profil user yang disimpan di tabel 'profiles'.

class UserModel {
  final String id;
  final String name;
  final String username;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.createdAt,
  });

  /// Buat objek UserModel dari Map (respons Supabase).
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      username: map['username'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Konversi ke Map untuk operasi database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
    };
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, username: $username)';
}
