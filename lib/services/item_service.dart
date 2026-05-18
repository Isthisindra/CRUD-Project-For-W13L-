// lib/services/item_service.dart
// Bertanggung jawab untuk semua operasi CRUD ke Supabase.
// Layer ini HANYA menangani komunikasi dengan database, tidak ada logika UI.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item_model.dart';
import '../utils/constants.dart';

class ItemService {
  // Gunakan singleton client Supabase yang sudah diinisialisasi di main.dart
  final SupabaseClient _client = Supabase.instance.client;

  /// Ambil semua item dari tabel berdasarkan teamId, diurutkan dari yang terbaru.
  Future<List<Item>> fetchAll(String teamId) async {
    final data = await _client
        .from(itemsTable)
        .select()
        .eq('team_id', teamId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => Item.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Tambah item baru ke tabel Supabase.
  Future<void> create(Item item, String teamId) async {
    final itemMap = item.toMap();
    itemMap['team_id'] = teamId;
    await _client.from(itemsTable).insert(itemMap);
  }

  /// Update item berdasarkan ID.
  Future<void> update(String id, Item item) async {
    await _client
        .from(itemsTable)
        .update(item.toMap())
        .eq('id', id);
  }

  /// Hapus item berdasarkan ID.
  Future<void> delete(String id) async {
    await _client.from(itemsTable).delete().eq('id', id);
  }
}
