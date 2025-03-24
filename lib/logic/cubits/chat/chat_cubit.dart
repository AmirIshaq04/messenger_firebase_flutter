import 'dart:async';
import 'dart:developer';

import 'package:chatting_app_flutter/data/repositories/chat_repository.dart';
import 'package:chatting_app_flutter/logic/cubits/chat/chat_cubit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatCubitState> {
  final ChatRepository _chatRepository;
  final String currentUserId;
  StreamSubscription? _streamSubscription;
  ChatCubit({
    required ChatRepository ChatRepository,
    required this.currentUserId,
  })  : _chatRepository = ChatRepository,
        super(const ChatCubitState());

  void enterChat(String receiverId) async {
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
}
