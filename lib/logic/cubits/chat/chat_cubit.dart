import 'dart:async';
import 'dart:developer';

import 'package:chatting_app_flutter/data/repositories/chat_repository.dart';
import 'package:chatting_app_flutter/logic/cubits/chat/chat_cubit_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatCubitState> {
  final ChatRepository _chatRepository;
  final String currentUserId;
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onlineStatusSubscription;
  StreamSubscription? _typingSbscription;
  bool _isUserInChat = false;
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
}
