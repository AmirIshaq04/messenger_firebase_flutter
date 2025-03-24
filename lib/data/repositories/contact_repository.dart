import 'package:chatting_app_flutter/data/models/user_models.dart';
import 'package:chatting_app_flutter/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactRepository extends BaseRepository {
  String get currentUserId => FirebaseAuth.instance.currentUser!.uid ?? "";

  Future<bool> requestPermission() async {
    return await FlutterContacts.requestPermission();
  }

  Future<List<Map<String, dynamic>>> getRegisteredContact() async {
    try {
     // requestPermission();
          if (!await FlutterContacts.requestPermission()) {
        return []; // Return empty if permission is denied
      }
      // if (!await FlutterContacts.requestPermission()) {
      //   return []; // Return empty if permission is denied
      // }
      //get device contacts with phone number
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      // extract phone number and normalize them
      final phoneNumber = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map(
            (contact) => {
              'name': contact.displayName,
              'phoneNumber':
                  contact.phones.first.number.replaceAll(r'[^\d+]', ''),
              'photo': contact.photo,
            },
          )
          .toList();
      //get all users from firestore
      final usersSnapshot = await firebaseFirestor.collection("users").get();
      final registeredUers = usersSnapshot.docs
          .map((doc) => UserModels.fromFirestore(doc))
          .toList();
      //match contacts with registered users
      final matchedContacts = phoneNumber.where((contact) {
        final phoneNumber = contact['phoneNumber'];
        return registeredUers.any((user) =>
            user.phoneNumber == phoneNumber && user.uid != currentUserId);
      }).map(
        (contact) {
          final registeredUser = registeredUers
              .firstWhere((user) => user.phoneNumber == contact['phoneNumber']);
          return {
            "id": registeredUser.uid,
            "name": contact["name"],
            "phoneNumber": contact["phoneNumber"],
          };
        },
      ).toList();
      return matchedContacts;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
