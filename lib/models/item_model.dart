// lib/models/item_model.dart
// Model data untuk entitas "Item" yang disimpan di Supabase.

class Item {
  final String id;
  final String teamId;
  final String name;
  final String description;
  final DateTime createdAt;
  final int stock;
  final double buyPrice;
  final double sellPrice;
  final String category;

  const Item({
    required this.id,
    required this.teamId,
    required this.name,
    required this.description,
    required this.createdAt,
    this.stock = 0,
    this.buyPrice = 0.0,
    this.sellPrice = 0.0,
    this.category = '',
  });

  /// Buat objek Item dari Map (respons Supabase).
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'].toString(),
      teamId: map['team_id'].toString(),
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      stock: map['stock'] as int? ?? 0,
      buyPrice: (map['buy_price'] as num?)?.toDouble() ?? 0.0,
      sellPrice: (map['sell_price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? '',
    );
  }

  /// Konversi Item ke Map untuk dikirim ke Supabase.
  /// Tidak menyertakan 'id' dan 'created_at' karena di-generate oleh DB.
  Map<String, dynamic> toMap() {
    return {
      'team_id': teamId,
      'name': name,
      'description': description,
      'stock': stock,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'category': category,
    };
  }

  /// Buat salinan Item dengan field yang diubah.
  Item copyWith({
    String? id,
    String? teamId,
    String? name,
    String? description,
    DateTime? createdAt,
    int? stock,
    double? buyPrice,
    double? sellPrice,
    String? category,
  }) {
    return Item(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      stock: stock ?? this.stock,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Item(id: $id, name: $name, description: $description, createdAt: $createdAt, stock: $stock, buyPrice: $buyPrice, sellPrice: $sellPrice, category: $category)';
  }
}
