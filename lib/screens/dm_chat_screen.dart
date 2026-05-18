// lib/screens/dm_chat_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../providers/team_provider.dart';

class DMChatScreen extends StatefulWidget {
  final UserModel otherUser;

  const DMChatScreen({super.key, required this.otherUser});

  @override
  State<DMChatScreen> createState() => _DMChatScreenState();
}

class _DMChatScreenState extends State<DMChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChat();
    });
  }

  Future<void> _initChat() async {
    final teamId = context.read<TeamProvider>().activeTeam!.id;
    final msgProvider = context.read<MessageProvider>();
    
    await msgProvider.loadConversation(
      teamId: teamId,
      otherUserId: widget.otherUser.id,
    );
    msgProvider.subscribeRealtime(
      teamId: teamId,
      otherUserId: widget.otherUser.id,
    );
    
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Di real app, batalkan subscription di sini jika perlu, 
    // tapi kita biarkan provider mengaturnya.
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    
    final teamId = context.read<TeamProvider>().activeTeam!.id;
    await context.read<MessageProvider>().sendMessage(
      teamId: teamId,
      receiverId: widget.otherUser.id,
      content: text,
    );
    
    _scrollToBottom();
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final msgProvider = context.watch<MessageProvider>();
    final currentUserId = context.read<AuthProvider>().currentUser?.id;

    // Auto-scroll saat pesan baru masuk
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.otherUser.name),
        previousPageTitle: 'Back',
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: msgProvider.isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : msgProvider.messages.isEmpty
                      ? const Center(child: Text('Belum ada pesan.'))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: msgProvider.messages.length,
                          itemBuilder: (context, index) {
                            final msg = msgProvider.messages[index];
                            final isMe = msg.senderId == currentUserId;
                            
                            return Container(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.content,
                                      style: TextStyle(
                                        color: isMe ? CupertinoColors.white : CupertinoColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(msg.createdAt.toLocal()),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe ? CupertinoColors.white.withOpacity(0.7) : CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: CupertinoColors.systemGrey4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _messageController,
                      placeholder: 'Ketik pesan...',
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _sendMessage,
                    child: const Icon(CupertinoIcons.paperplane_fill, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
