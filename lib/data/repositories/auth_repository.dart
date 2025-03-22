import 'dart:developer';

import 'package:chatting_app_flutter/data/models/user_models.dart';
import 'package:chatting_app_flutter/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository extends BaseRepository {
  Stream<User?> get authStateChanges => firebaseauth.authStateChanges();
  Future<UserModels> signUp({
    required String email,
    required String fullName,
    required String userName,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final formatedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), "".trim());
      final emailExist = await emailAlreadyExists(email);
      final phoneNumberExists = await phoneAlreadyExists(formatedNumber);
      final userNameExists = await userNameAlreadyExists(userName);
      if (emailExist) {
        throw 'Account with this email already exists';
      }
      if (phoneNumberExists) {
        throw 'Account with this Phone number already exists';
      }
      if (userNameExists) {
        throw 'Account with this Username already exists';
      }

      final userCredentials = await firebaseauth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (userCredentials.user == null) {
        throw 'Error while creating account';
      }
      //create user and save the user in db firestore
      final user = UserModels(
        uid: userCredentials.user!.uid,
        userName: userName,
        fullName: fullName,
        email: email,
        phoneNumber: formatedNumber,
      );
      await saveUserData(user);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  //
  Future<UserModels> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredentials = await firebaseauth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredentials.user == null) {
        throw 'Error while creating account';
      }
      final userData = await getUserData(userCredentials.user!.uid);
      return userData;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModels> getUserData(String id) async {
    try {
      final doc = await firebaseFirestor.collection('users').doc(id).get();
      if (!doc.exists) {
        throw 'User not found';
      }
      log(doc.id);
      return UserModels.fromFirestore(doc);
    } catch (e) {
      throw 'Failed to save user data';
    }
  }

  Future<void> saveUserData(UserModels user) async {
    try {
      await firebaseFirestor
          .collection('users')
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      throw 'Failed to save user data';
    }
  }

  //
  Future<void> signOut() async {
    try {
      await firebaseauth.signOut();
    } catch (e) {
      throw 'Failed to signout';
    }
  }

  Future<bool> emailAlreadyExists(String email) async {
    try {
      final methods = await firebaseauth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<bool> phoneAlreadyExists(String phoneNumber) async {
    try {
      final formattedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), "".trim());
      final querySnapshot = await firebaseFirestor
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedNumber)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> userNameAlreadyExists(String userName) async {
    try {
      final querySnapshot = await firebaseFirestor
          .collection('users')
          .where('userName', isEqualTo: userName)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
