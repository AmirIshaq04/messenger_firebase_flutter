import 'package:chatting_app_flutter/data/models/chat_message.dart';
import 'package:chatting_app_flutter/data/services/service_locator.dart';
import 'package:chatting_app_flutter/logic/cubits/chat/chat_cubit.dart';
import 'package:chatting_app_flutter/logic/cubits/chat/chat_cubit_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatMessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatMessageScreen(
      {super.key, required this.receiverId, required this.receiverName});

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  late final ChatCubit chatCubit;
  @override
  void initState() {
    chatCubit = getIt<ChatCubit>();
    chatCubit.enterChat(widget.receiverId);

    super.initState();
  }

  Future<void> handleMessage() async {
    final message = messageController.text.trim();
    messageController.clear();
    await chatCubit.sendMessage(
        content: message, receiverId: widget.receiverId);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                widget.receiverName[0].toUpperCase(),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverName),
                Text(
                  "Online",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 15,
            ),
            child: Icon(Icons.more_vert),
          )
        ],
      ),
      body: BlocBuilder<ChatCubit, ChatCubitState>(
          bloc: chatCubit,
          builder: (context, state) {
            if (state.status == ChatStatus.loading) {
              CircularProgressIndicator();
            }
            if (state.status == ChatStatus.error) {
              Text(state.error ?? "Something went wrong");
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      bool isMe = message.senderId == chatCubit.currentUserId;
                      return MessageBubble(chatMessage: message, isMe: isMe);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.emoji_emotions),
                          ),
                          Expanded(
                            child: TextField(
                              onTap: () {},
                              controller: messageController,
                              keyboardType: TextInputType.multiline,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  hintText: "Type a message",
                                  filled: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  fillColor: Theme.of(context).cardColor),
                            ),
                          ),
                          IconButton(
                            onPressed: handleMessage,
                            icon: Icon(
                              Icons.send,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage chatMessage;
  final bool isMe;
  // final String showTime;
  const MessageBubble({
    super.key,
    required this.chatMessage,
    required this.isMe,
    // required this.showTime
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.only(
            left: isMe ? 64 : 8, right: isMe ? 8 : 64, bottom: 4),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              chatMessage.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "5.48",
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
                Icon(
                  Icons.done_all,
                  color: chatMessage.status == MessageStatus.read
                      ? Colors.red
                      : Colors.white70,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
