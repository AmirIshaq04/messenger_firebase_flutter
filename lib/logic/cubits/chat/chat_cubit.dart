import 'dart:async';
import 'dart:developer';

import 'package:chatting_app_flutter/data/repositories/chat_repository.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_state.dart';
import 'package:chatting_app_flutter/logic/cubits/chat/chat_cubit_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatCubitState> {
  final ChatRepository _chatRepository;
  final String currentUserId;
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onlineStatusSubscription;
  StreamSubscription? _typingSbscription;
  StreamSubscription? _blockStatusSubscription;
  StreamSubscription? _amIblockStatusSubscription;
  bool _isUserInChat = false;
  Timer? typingTimer;
  ChatCubit({
    required ChatRepository ChatRepository,
    required this.currentUserId,
  })  : _chatRepository = ChatRepository,
        super(const ChatCubitState());

  void enterChat(String receiverId) async {
    _isUserInChat = true;
    emit(
      state.copyWith(status: ChatStatus.loading),
    );
    try {
      final chatRoom =
          await _chatRepository.getOrCreateChatRoom(currentUserId, receiverId);
      emit(
        state.copyWith(
            chatRoomId: chatRoom.id,
            receiverId: receiverId,
            status: ChatStatus.loded),
      );
      _subscribeToMessages(chatRoom.id);
      _subscribeToOnlineStatus(receiverId);
      _subscribeToTypingStatus(chatRoom.id);
      _subscribeToBlockStatus(receiverId);

      await _chatRepository.updateOnoineStatus(currentUserId, true);
    } catch (e) {
      emit(
        state.copyWith(
            status: ChatStatus.error, error: "Failed to create Chat Room$e"),
      );
    }
  }

  Future<void> sendMessage(
      {required String content, required String receiverId}) async {
    if (state.chatRoomId == null) {
      return;
    }
    try {
      await _chatRepository.sendMessage(
          chatRoomId: state.chatRoomId!,
          senderId: currentUserId,
          receiverId: receiverId,
          content: content);
    } catch (e) {
      log(e.toString());
      emit(
        state.copyWith(error: "Failed to send message"),
      );
    }
  }

  void _subscribeToMessages(String chatRoomId) {
    _streamSubscription?.cancel();
    _streamSubscription =
        _chatRepository.getMessage(chatRoomId).listen((messages) {
      if (_isUserInChat) {
        _markMessagAsRead(chatRoomId);
      }
      emit(
        state.copyWith(messages: messages, error: null),
      );
    }, onError: (onError) {
      emit(
        state.copyWith(
            error: "failed to load messages", status: ChatStatus.error),
      );
    });
  }

  Future<void> _markMessagAsRead(String chatRoomId) async {
    try {
      await _chatRepository.markMessagesAsRead(chatRoomId, currentUserId);
    } catch (e) {
      print("error$e");
    }
  }

  Future<void> leaveChat() async {
    _isUserInChat = false;
  }

  void _subscribeToOnlineStatus(String userId) {
    _onlineStatusSubscription?.cancel();
    _onlineStatusSubscription =
        _chatRepository.getUserOnlineStatus(userId).listen((status) {
      final isOnline = status["isOnline"] as bool;
      final lastSeen = status["lastSeen"] as Timestamp?;
      emit(
        state.copyWith(isReceiverOnline: isOnline, receiverLastSeen: lastSeen),
      );
    }, onError: (error) {
      print(error);
    });
  }

  void _subscribeToTypingStatus(String chatRoomIe) {
    _typingSbscription?.cancel();
    _onlineStatusSubscription =
        _chatRepository.getUserOnlineStatus(chatRoomIe).listen((status) {
      final isTyping = status["isTyping"] as bool;
      final typingUserId = status["typingUser"] as String;
      emit(
        state.copyWith(
            isReceiverTyping: isTyping && typingUserId != currentUserId),
      );
    }, onError: (error) {
      print(error);
    });
  }

  void _subscribeToBlockStatus(String otherUserId) {
    _blockStatusSubscription?.cancel();
    _amIblockStatusSubscription?.cancel();

    _blockStatusSubscription = _chatRepository
        .isUserBlocked(currentUserId, otherUserId)
        .listen((isBlocked) {
      _amIblockStatusSubscription =
          _chatRepository.amIBlocked(currentUserId, otherUserId).listen(
        (amIBlocked) {
          emit(
            state.copyWith(
              isuserBlocked: isBlocked,
              amIBlocked: amIBlocked,
            ),
          );
        },
      );
    }, onError: (onError) {
      print("Error blocking user$onError");
    });
  }

  void startTyping() {
    if (state.chatRoomId == null) {
      return;
    }
    typingTimer?.cancel();
    _updateTypingStatus(true);
    typingTimer = Timer(const Duration(seconds: 3), () {
      _updateTypingStatus(false);
    });
  }

  Future<void> _updateTypingStatus(bool isTyping) async {
    if (state.chatRoomId == null) {
      return;
    }
    try {
      await _chatRepository.updateTypingStatus(
          state.chatRoomId!, currentUserId, isTyping);
    } catch (e) {
      print("Error updating typing status$e");
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _chatRepository.blockedUsers(currentUserId, userId);
    } catch (e) {
      emit(
        state.copyWith(error: "Failed to block$e"),
      );
    }
  }

  Future<void> unBlockUser(String userId) async {
    try {
      await _chatRepository.unBlockedUsers(currentUserId, userId);
    } catch (e) {
      emit(
        state.copyWith(error: "Failed to unblock$e"),
      );
    }
  }

  Future<void> loadMoreMessages() async {
    if (state.status != ChatStatus.loded ||
        state.messages.isEmpty ||
        !state.hasMoreMessages ||
        state.isUserLoadingMore) {
      return;
    }
    try {
      emit(
        state.copyWith(isUserLoadingMore: true),
      );
      final lastMessage = state.messages.last;
      final lastDoc = await _chatRepository
          .getChatRoomMessages(
            state.chatRoomId!,
          )
          .doc(lastMessage.id)
          .get();
      final moreMessages = await _chatRepository.getMoreMessage(
        state.chatRoomId!,
        lastDocument: lastDoc,
      );
      if (moreMessages.isEmpty) {
        emit(
          state.copyWith(hasMoreMessages: false, isUserLoadingMore: false),
        );
        return;
      }
      emit(
        state.copyWith(
          messages: [...state.messages, ...moreMessages],
          hasMoreMessages: moreMessages.length > 20,
          isUserLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
            error: "Failed to load messages$e", isUserLoadingMore: false),
      );
    }
  }
}
