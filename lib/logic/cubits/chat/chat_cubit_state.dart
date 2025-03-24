import 'package:chatting_app_flutter/data/models/chat_message.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus {
  initial,
  loading,
  loded,
  error,
}

class ChatCubitState extends Equatable {
  final ChatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;
  final List<ChatMessage> messages;

  const ChatCubitState(
      {this.status = ChatStatus.initial,
      this.error,
      this.messages = const [],
      this.receiverId,
      this.chatRoomId});
  ChatCubitState copyWith(
      {ChatStatus? status,
      String? error,
      String? receiverId,
      List<ChatMessage>? messages,
      String? chatRoomId}) {
    return ChatCubitState(
        status: status ?? this.status,
        error: error ?? this.error,
        messages: messages ?? this.messages,
        chatRoomId: chatRoomId ?? this.chatRoomId,
        receiverId: receiverId ?? this.receiverId);
  }

  @override
  List<Object?> get props => [status, error, receiverId, chatRoomId, messages];
}
