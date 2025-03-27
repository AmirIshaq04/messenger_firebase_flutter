import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final Timestamp? lastMessageTime;
  final Map<String, Timestamp>? lastReadTime;
  final Map<String, String>? participantsName;
  final bool isTyping;
  final bool typingUser;
  final bool isCallActive;

  ChatRoomModel(
      {required this.id,
      required this.participants,
      this.lastMessage,
      this.lastMessageSenderId,
      this.lastMessageTime,
      Map<String, Timestamp>? lastReadTime,
      Map<String, String>? participantsName,
      this.isTyping = false,
      this.typingUser = false,
      this.isCallActive = false})
      : lastReadTime = lastReadTime ?? {},
        participantsName = participantsName ?? {};

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(
        data['participants'],
      ),
      lastMessage: data['lastMessage'] ?? "",
      lastMessageSenderId: data['lastMessageSenderId'] ?? "",
      lastMessageTime: data['lastMessageTime'] ?? Timestamp.now(),
      lastReadTime: Map<String, Timestamp>.from(data["lastReadTime"] ?? {}),
      participantsName: Map<String, String>.from(
        data['participantsName'] ?? {},
      ),
      isTyping: data['isTyping'] ?? false,
      typingUser: data['typingUser'] ?? false,
      isCallActive: data['isCallActive'] ?? false,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime,
      'lastReadTime': lastReadTime,
      'participantsName': participantsName,
      'isTyping': isTyping,
      'typingUser': typingUser,
      'isCallActive': isCallActive,
    };
  }
}
