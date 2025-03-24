import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseRepository {
  final FirebaseAuth firebaseauth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestor = FirebaseFirestore.instance;
  User? get currentuser => firebaseauth.currentUser;
  String get uid => currentuser?.uid ?? "";
  bool get isAuthenticated => currentuser != null;
}
