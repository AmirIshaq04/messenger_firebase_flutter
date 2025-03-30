import 'package:chatting_app_flutter/data/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loded, error, isLoadingMore }

class ChatCubitState extends Equatable {
  final ChatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;
  final bool isReceiverTyping;
  final bool isReceiverOnline;
  final bool hasMoreMessages;
  final Timestamp? receiverLastSeen;
  final bool isUserLoadingMore;
  final List<ChatMessage> messages;
  final bool isuserBlocked;
  final bool amIBlocked;

  const ChatCubitState(
      {this.status = ChatStatus.initial,
      this.error,
      this.isReceiverOnline = false,
      this.isUserLoadingMore = false,
      this.isuserBlocked = false,
      this.amIBlocked = false,
      this.isReceiverTyping = false,
      this.receiverLastSeen,
      this.hasMoreMessages = true,
      this.messages = const [],
      this.receiverId,
      this.chatRoomId});
  ChatCubitState copyWith(
      {ChatStatus? status,
      String? error,
      bool? isReceiverTyping,
      bool? isReceiverOnline,
      bool? hasMoreMessages,
      bool? isUserLoadingMore,
      bool? isuserBlocked,
      bool? amIBlocked,
      Timestamp? receiverLastSeen,
      String? receiverId,
      List<ChatMessage>? messages,
      String? chatRoomId}) {
    return ChatCubitState(
        amIBlocked: amIBlocked ?? this.amIBlocked,
        hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
        isReceiverOnline: isReceiverOnline ?? this.isReceiverOnline,
        isReceiverTyping: isReceiverTyping ?? this.isReceiverTyping,
        isUserLoadingMore: isUserLoadingMore ?? this.isUserLoadingMore,
        isuserBlocked: isuserBlocked ?? this.isuserBlocked,
        receiverLastSeen: receiverLastSeen ?? this.receiverLastSeen,
        status: status ?? this.status,
        error: error ?? this.error,
        messages: messages ?? this.messages,
        chatRoomId: chatRoomId ?? this.chatRoomId,
        receiverId: receiverId ?? this.receiverId);
  }

  @override
  List<Object?> get props => [
        status,
        error,
        receiverId,
        chatRoomId,
        messages,
        isReceiverOnline,
        isReceiverTyping,
        receiverLastSeen,
        isUserLoadingMore,
        isuserBlocked,
        amIBlocked,
        hasMoreMessages
      ];
}
