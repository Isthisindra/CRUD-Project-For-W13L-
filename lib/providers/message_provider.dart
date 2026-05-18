// lib/providers/message_provider.dart
// Mengelola state pesan DM dan Supabase Realtime subscription.

import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

class MessageProvider extends ChangeNotifier {
  final MessageService _service = MessageService();

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Muat riwayat percakapan antara user login dan otherUserId.
  Future<void> loadConversation({
    required String teamId,
    required String otherUserId,
  }) async {
    _setLoading(true);
    try {
      _messages = await _service.getConversation(
        teamId: teamId,
        otherUserId: otherUserId,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Gagal memuat pesan: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// Kirim pesan baru (pesan akan muncul via realtime subscription).
  Future<void> sendMessage({
    required String teamId,
    required String receiverId,
    required String content,
  }) async {
    try {
      await _service.sendMessage(
        teamId: teamId,
        receiverId: receiverId,
        content: content,
      );
    } catch (e) {
      _errorMessage = 'Gagal mengirim pesan: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Aktifkan Supabase Realtime untuk pesan baru muncul otomatis.
  void subscribeRealtime({
    required String teamId,
    required String otherUserId,
  }) {
    _service.subscribeToConversation(
      teamId: teamId,
      otherUserId: otherUserId,
      onNewMessage: (msg) {
        // Hindari duplikat jika pesan sudah ada di list
        if (!_messages.any((m) => m.id == msg.id)) {
          _messages.add(msg);
          notifyListeners();
        }
      },
    );
  }

  /// Bersihkan list pesan dan hentikan subscription.
  void clearMessages() {
    _messages = [];
    _service.unsubscribe();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.unsubscribe();
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
