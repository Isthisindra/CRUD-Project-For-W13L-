// lib/services/message_service.dart
// Menangani pengiriman pesan DM dan Supabase Realtime subscription.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';

class MessageService {
  final SupabaseClient _client = Supabase.instance.client;

  // Simpan referensi channel realtime agar bisa di-unsubscribe
  RealtimeChannel? _channel;

  /// Ambil semua pesan percakapan antara user login dan otherUserId dalam satu tim.
  Future<List<MessageModel>> getConversation({
    required String teamId,
    required String otherUserId,
  }) async {
    final myId = _client.auth.currentUser!.id;

    // Ambil pesan di kedua arah (saya → dia & dia → saya)
    final data = await _client
        .from(messagesTable)
        .select()
        .eq('team_id', teamId)
        .or(
          'and(sender_id.eq.$myId,receiver_id.eq.$otherUserId),'
          'and(sender_id.eq.$otherUserId,receiver_id.eq.$myId)',
        )
        .order('created_at', ascending: true);

    return (data as List<dynamic>)
        .map((e) => MessageModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Kirim pesan baru ke Supabase.
  Future<void> sendMessage({
    required String teamId,
    required String receiverId,
    required String content,
  }) async {
    final myId = _client.auth.currentUser!.id;

    await _client.from(messagesTable).insert({
      'team_id': teamId,
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': content,
    });
  }

  /// Subscribe ke Supabase Realtime untuk mendapatkan pesan baru secara live.
  /// [onNewMessage] dipanggil setiap kali ada pesan baru.
  void subscribeToConversation({
    required String teamId,
    required String otherUserId,
    required void Function(MessageModel) onNewMessage,
  }) {
    final myId = _client.auth.currentUser!.id;

    // Cancel subscription lama jika ada
    unsubscribe();

    _channel = _client
        .channel('dm_${teamId}_${myId}_$otherUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: messagesTable,
          callback: (payload) {
            final newMsg = MessageModel.fromMap(
              payload.newRecord,
            );

            // Filter hanya pesan yang relevan dengan percakapan ini
            final isRelevant = (newMsg.senderId == myId &&
                    newMsg.receiverId == otherUserId) ||
                (newMsg.senderId == otherUserId && newMsg.receiverId == myId);

            if (isRelevant && newMsg.teamId == teamId) {
              onNewMessage(newMsg);
            }
          },
        )
        .subscribe();
  }

  /// Batalkan subscription realtime yang aktif.
  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }
}
