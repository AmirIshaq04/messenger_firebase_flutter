import 'package:chatting_app_flutter/config/theme/app_theme.dart';
import 'package:chatting_app_flutter/data/repositories/chat_repository.dart';
import 'package:chatting_app_flutter/data/services/service_locator.dart';
import 'package:chatting_app_flutter/firebase_options.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_cubit.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_state.dart';
import 'package:chatting_app_flutter/logic/observer/app_life_cycle_observer.dart';
import 'package:chatting_app_flutter/presentation/pages/auth/login_screen.dart';
import 'package:chatting_app_flutter/presentation/pages/home/home_screen.dart';
import 'package:chatting_app_flutter/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';

void main() async {
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLifeCycleObserver _appLifeCycleObserver;
  @override
  void initState() {
    getIt<AuthCubit>().stream.listen(
      (state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          _appLifeCycleObserver = AppLifeCycleObserver(
              userId: state.user!.uid, chatRepository: getIt<ChatRepository>());
        }
        WidgetsBinding.instance.addObserver(_appLifeCycleObserver);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        navigatorKey: getIt<AppRouter>().navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: AppTheme.lightThme,
        home: BlocBuilder<AuthCubit, AuthState>(
          bloc: getIt<AuthCubit>(),
          builder: (context, state) {
            if (state.status == AuthStatus.initial) {
              Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state.status == AuthStatus.authenticated) {
              return const HomeScreen();
            }
            return LoginScreen();
          },
        ),
      ),
    );
  }
}
