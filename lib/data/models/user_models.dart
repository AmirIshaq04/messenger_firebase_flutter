import 'package:cloud_firestore/cloud_firestore.dart';

class UserModels {
  final String uid;
  final String userName;
  final String fullName;
  final String email;
  final String phoneNumber;
  final bool isOnline;
  final Timestamp lastSeen;
  final Timestamp createdAt;
  final String? fcmToken;
  final List<String> blockedUsers;

  UserModels({
    required this.uid,
    required this.userName,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.isOnline = false,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    this.fcmToken,
    this.blockedUsers = const [],
  })  : lastSeen = lastSeen ?? Timestamp.now(),
        createdAt = createdAt ?? Timestamp.now();

  UserModels copyWith({
    String? uid,
    String? userName,
    String? fullName,
    String? email,
    String? phoneNumber,
    bool? isOnline,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    String? fcmToken,
    List<String>? blockedUsers,
  }) {
    return UserModels(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  factory UserModels.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModels(
      uid: doc.id,
      userName: data['userName'] ?? "",
      fullName: data['fullName'] ?? "",
      email: data['email'] ?? "",
      phoneNumber: data['phoneNumber'] ?? "",
      fcmToken: data['fcmToken'],
      lastSeen: data['lastSeen'] ?? Timestamp.now(),
      isOnline: data['isOnline'] ?? false,
      createdAt: data['createdAt'],
      blockedUsers: List<String>.from(data['blockedUsers']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'blockedUsers': blockedUsers,
      'createdAt': createdAt,
      'fcmToken': fcmToken,
    };
  }
}
