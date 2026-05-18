// lib/models/message_model.dart
// Model data untuk pesan Direct Message antar member tim.

class MessageModel {
  final String id;
  final String teamId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.teamId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
  });

  /// Buat objek MessageModel dari Map (respons Supabase).
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      teamId: map['team_id'] as String,
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Konversi ke Map untuk insert ke Supabase.
  Map<String, dynamic> toMap() {
    return {
      'team_id': teamId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    };
  }

  @override
  String toString() =>
      'MessageModel(id: $id, senderId: $senderId, content: $content)';
}
