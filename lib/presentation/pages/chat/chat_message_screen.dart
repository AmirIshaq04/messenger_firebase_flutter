import 'dart:io';

import 'package:chatting_app_flutter/data/models/chat_message.dart';
import 'package:chatting_app_flutter/data/services/service_locator.dart';
import 'package:chatting_app_flutter/logic/cubits/chat/chat_cubit.dart';
import 'package:chatting_app_flutter/logic/cubits/chat/chat_cubit_state.dart';
import 'package:chatting_app_flutter/presentation/widgets/loading_dots.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

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
  bool _isComposing = false;
  bool _showEmojis = false;
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _previousMessages = [];

  @override
  void initState() {
    chatCubit = getIt<ChatCubit>();
    chatCubit.enterChat(widget.receiverId);
    messageController.addListener(_onTextChange);
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      chatCubit.loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _newMessages(List<ChatMessage> message) {
    if (message.length != _previousMessages.length) {
      _scrollToBottom();
      _previousMessages = message;
    }
  }

  Future<void> handleMessage() async {
    final message = messageController.text.trim();
    messageController.clear();
    await chatCubit.sendMessage(
        content: message, receiverId: widget.receiverId);
  }

  void _onTextChange() {
    final isComposing = messageController.text.isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
      if (isComposing) {
        chatCubit.startTyping();
      }
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    chatCubit.leaveChat();
    _scrollController.dispose();
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
                BlocBuilder<ChatCubit, ChatCubitState>(
                  bloc: chatCubit,
                  builder: (context, state) {
                    if (state.isReceiverTyping) {
                      return Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              right: 4,
                            ),
                            child: const LoadingDots(),
                          ),
                          Text(
                            "Typing",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      );
                    }
                    if (state.isReceiverOnline) {
                      return Text(
                        "Online",
                        style: TextStyle(color: Colors.green, fontSize: 14),
                      );
                    }
                    if (state.receiverLastSeen != null) {
                      final lastSeen = state.receiverLastSeen!.toDate();
                      return Text(
                        "last seen at ${DateFormat('h:mm:a').format(lastSeen)}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      );
                    }
                    return SizedBox();
                  },
                )
              ],
            ),
          ],
        ),
        actions: [
          BlocBuilder<ChatCubit, ChatCubitState>(
            bloc: chatCubit,
            builder: (context, state) {
              if (state.isuserBlocked) {
                return TextButton.icon(
                  onPressed: () {
                    chatCubit.unBlockUser(widget.receiverId);
                  },
                  label: Text(
                    "Unblock",
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              return PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == "block") {
                    final bool? confirm = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content:
                              Text("Are you sure you want to block this user?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text(
                                "Block",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true) {
                      await chatCubit.blockUser(widget.receiverId);
                    }
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem(
                    value: "block",
                    child: Text("Block"),
                  )
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatCubit, ChatCubitState>(
        listener: (context, state) {
          _newMessages(state.messages);
        },
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
              if (state.amIBlocked)
                Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.red.withOpacity(0.1),
                  child: Text(
                    textAlign: TextAlign.center,
                    "You have been blocked by this${widget.receiverName}",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    bool isMe = message.senderId == chatCubit.currentUserId;
                    return MessageBubble(chatMessage: message, isMe: isMe);
                  },
                ),
              ),
              if (!state.amIBlocked && !state.isuserBlocked)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(
                                () {
                                  _showEmojis = !_showEmojis;
                                  if (_showEmojis) {
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                              );
                            },
                            icon: Icon(Icons.emoji_emotions),
                          ),
                          Expanded(
                            child: TextField(
                              onTap: () {
                                if (_showEmojis) {
                                  setState(() {
                                    _showEmojis = false;
                                  });
                                }
                              },
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
                            onPressed: _isComposing ? handleMessage : null,
                            icon: Icon(Icons.send,
                                color: _isComposing
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey),
                          ),
                        ],
                      ),
                      if (_showEmojis)
                        SizedBox(
                          height: 250,
                          child: EmojiPicker(
                            textEditingController: messageController,
                            onEmojiSelected: (category, emoji) {
                              messageController
                                ..text += emoji.emoji
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(
                                      offset: messageController.text.length),
                                );
                              setState(() {
                                _isComposing =
                                    messageController.text.isNotEmpty;
                              });
                            },
                            config: Config(
                              height: 250,
                              emojiViewConfig: EmojiViewConfig(
                                columns: 7,
                                emojiSizeMax:
                                    32.0 * (Platform.isIOS ? 1.30 : 1.0),
                                verticalSpacing: 0,
                                horizontalSpacing: 0,
                                gridPadding: EdgeInsets.zero,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                loadingIndicator: const SizedBox.shrink(),
                              ),
                              categoryViewConfig: const CategoryViewConfig(
                                initCategory: Category.RECENT,
                              ),
                              bottomActionBarConfig: BottomActionBarConfig(
                                enabled: true,
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                buttonColor: Theme.of(context).primaryColor,
                              ),
                              skinToneConfig: const SkinToneConfig(
                                enabled: true,
                                dialogBackgroundColor: Colors.white,
                                indicatorColor: Colors.grey,
                              ),
                              searchViewConfig: SearchViewConfig(
                                backgroundColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                buttonIconColor: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
            ],
          );
        },
      ),
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
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                DateFormat('h:mm:a').format(
                  chatMessage.timestamp.toDate(),
                ),
                style: TextStyle(
                    color: isMe ? Colors.white : Colors.black, fontSize: 9),
              ),
              if (isMe) ...[
                SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.done_all,
                  size: 14,
                  color: chatMessage.status == MessageStatus.read
                      ? Colors.red
                      : Colors.white70,
                )
              ],
            ]),
          ],
        ),
      ),
    );
  }
}
