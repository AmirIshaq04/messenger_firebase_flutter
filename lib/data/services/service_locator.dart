import 'package:chatting_app_flutter/data/repositories/auth_repository.dart';
import 'package:chatting_app_flutter/data/repositories/chat_repository.dart';
import 'package:chatting_app_flutter/data/repositories/contact_repository.dart';
import 'package:chatting_app_flutter/firebase_options.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_cubit.dart';
import 'package:chatting_app_flutter/logic/cubits/chat/chat_cubit.dart';
import 'package:chatting_app_flutter/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;
Future<void> setupServiceLocator() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => AuthRepository());
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton(() => ContactRepository());
  getIt.registerLazySingleton(() => ChatRepository());
  getIt.registerLazySingleton(
    () => AuthCubit(
      authRepository: AuthRepository(),
    ),
  );
  getIt.registerFactory(
    () => ChatCubit(
        ChatRepository: ChatRepository(),
        currentUserId: getIt<FirebaseAuth>().currentUser!.uid),
  );
}
