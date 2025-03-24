import 'package:chatting_app_flutter/data/models/chat_message.dart';
import 'package:chatting_app_flutter/data/models/chat_room_model.dart';
import 'package:chatting_app_flutter/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository extends BaseRepository {
  CollectionReference get chatRooms => firebaseFirestor.collection("chatRoom");
  CollectionReference getChatRoomMessages(String chatRoomId) {
    return chatRooms.doc(chatRoomId).collection("messages");
  }

  Future<ChatRoomModel> getOrCreateChatRoom(
      String currentUserId, String otherUserId) async {
    final users = [currentUserId, otherUserId]..sort();
    final roomId = users.join("_");
    final roomDoc = await chatRooms.doc("roomId").get();
    if (roomDoc.exists) {
      return ChatRoomModel.fromFirestore(roomDoc);
    }
    final currentUserData =
        (await firebaseFirestor.collection("users").doc(currentUserId).get())
            .data() as Map<String, dynamic>;
    final otherUserUserData =
        (await firebaseFirestor.collection("users").doc(otherUserId).get())
            .data() as Map<String, dynamic>;

    final participantsName = {
      currentUserId: currentUserData["fullName"]?.toString() ?? "",
      otherUserId: otherUserUserData["fullName"]?.toString() ?? "",
    };
    final newRoom = ChatRoomModel(
      id: roomId,
      participants: users,
      participantsName: participantsName,
      lastReadTime: {
        currentUserId: Timestamp.now(),
        otherUserId: Timestamp.now(),
      },
    );
    await chatRooms.doc(roomId).set(newRoom.toMap());
    return newRoom;
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType tye = MessageType.text,
  }) async {
    //batch
    final batch = firebaseFirestor.batch();

    //get messages sub collection
    final messageRef = getChatRoomMessages(chatRoomId);
    final messageDoc = messageRef.doc();

    //message
    final message = ChatMessage(
      id: messageDoc.id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      type: tye,
      receiverId: receiverId,
      content: content,
      timestamp: Timestamp.now(),
      readBy: [senderId],
    );
    //add message to sub collection
    batch.set(
      messageDoc,
      message.toMap(),
    );
    //update chatRoom
    batch.update(
      chatRooms.doc(
        chatRoomId,
      ),
      {
        "lastMessage": content,
        "lastMessageSenderId": senderId,
        "lastMessageTime": message.timestamp,
      },
    );
    await batch.commit();
  }

  Stream<List<ChatMessage>> getMessage(String chatRoomId,
      {DocumentSnapshot? lastDocument}) {
    var query = getChatRoomMessages(chatRoomId)
        .orderBy("timestamp", descending: true)
        .limit(20);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatMessage.fromFirestore(doc),
              )
              .toList(),
        );
  }

  Future<List<ChatMessage>> getMoreMessage(String chatRoomId,
      {required DocumentSnapshot lastDocument}) async {
    final query = getChatRoomMessages(chatRoomId)
        .orderBy("timestamp", descending: true)
        .startAfterDocument(lastDocument)
        .limit(20);

    final snapShot = await query.get();

    return snapShot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
  }

  Stream<List<ChatRoomModel>> getChatRoom(String userId) {
    return chatRooms
        .where("participants", arrayContains: userId)
        .orderBy("lastMessageTime", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromFirestore(doc))
            .toList());
  }
}
