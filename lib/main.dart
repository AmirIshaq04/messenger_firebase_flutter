import 'package:chatting_app_flutter/config/theme/app_theme.dart';
import 'package:chatting_app_flutter/data/services/service_locator.dart';
import 'package:chatting_app_flutter/firebase_options.dart';
import 'package:chatting_app_flutter/presentation/pages/auth/login_screen.dart';
import 'package:chatting_app_flutter/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';

void main() async {
 await  setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: getIt<AppRouter>().navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.lightThme,
      home: LoginScreen(),
    );
  }
}
