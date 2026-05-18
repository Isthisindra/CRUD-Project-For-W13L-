// lib/providers/item_provider.dart
// Mengelola state aplikasi menggunakan ChangeNotifier (Provider pattern).
// Menjadi jembatan antara ItemService (data) dan UI (screen).

import 'package:flutter/foundation.dart';
import '../models/item_model.dart';
import '../services/item_service.dart';

class ItemProvider extends ChangeNotifier {
  final ItemService _service = ItemService();

  // State internal
  List<Item> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters (read-only akses dari UI)
  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Muat semua item dari Supabase berdasarkan teamId.
  Future<void> loadItems(String teamId) async {
    _setLoading(true);
    try {
      _items = await _service.fetchAll(teamId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat data: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Tambah item baru, lalu refresh list.
  Future<void> addItem(Item item, String teamId) async {
    _setLoading(true);
    try {
      await _service.create(item, teamId);
      await loadItems(teamId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal menambah item: ${e.toString()}';
      _setLoading(false);
    }
  }

  /// Update item berdasarkan ID, lalu refresh list.
  Future<void> updateItem(String id, Item item, String teamId) async {
    _setLoading(true);
    try {
      await _service.update(id, item);
      await loadItems(teamId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal mengupdate item: ${e.toString()}';
      _setLoading(false);
    }
  }

  /// Hapus item berdasarkan ID, lalu refresh list.
  Future<void> deleteItem(String id, String teamId) async {
    _setLoading(true);
    try {
      await _service.delete(id);
      await loadItems(teamId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal menghapus item: ${e.toString()}';
      _setLoading(false);
    }
  }

  /// Helper untuk set loading state dan notify listener.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
