// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatting_app_flutter/data/repositories/chat_repository.dart';
import 'package:chatting_app_flutter/data/services/service_locator.dart';
import 'package:flutter/material.dart';

import 'package:chatting_app_flutter/data/models/chat_room_model.dart';

class ChatListTile extends StatelessWidget {
  final ChatRoomModel chat;
  final String currentUserId;
  final VoidCallback onTap;
  const ChatListTile({
    super.key,
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });
  String _getOtherUserName() {
  try {
    final otherUserId = chat.participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => "", 
    );
    if (otherUserId.isEmpty) return "Unknown";
    return chat.participantsName?[otherUserId] ?? "Unknown";
  } catch (e) {
    return "Unknown";
  }
}

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(_getOtherUserName()[0].toString()),
        ),
        title: Text(
          _getOtherUserName(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          chat.lastMessage ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey),
        ),
        trailing: StreamBuilder<int>(
          stream: getIt<ChatRepository>()
              .getUnreadMessageCount(chat.id, currentUserId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == 0) {
              return const SizedBox();
            }
            return Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                snapshot.data.toString(),
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ));
  }
}
