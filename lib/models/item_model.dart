// lib/models/item_model.dart
// Model data untuk entitas "Item" yang disimpan di Supabase.

class Item {
  final String id;
  final String teamId;
  final String name;
  final String description;
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.teamId,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  /// Buat objek Item dari Map (respons Supabase).
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      teamId: map['team_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Konversi Item ke Map untuk dikirim ke Supabase.
  /// Tidak menyertakan 'id' dan 'created_at' karena di-generate oleh DB.
  Map<String, dynamic> toMap() {
    return {
      'team_id': teamId,
      'name': name,
      'description': description,
    };
  }

  /// Buat salinan Item dengan field yang diubah.
  Item copyWith({
    String? id,
    String? teamId,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Item(id: $id, name: $name, description: $description, createdAt: $createdAt)';
  }
}
