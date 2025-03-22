import 'dart:async';

import 'package:chatting_app_flutter/data/repositories/auth_repository.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? streamSubscription;
  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(status: AuthStatus.initial));
    streamSubscription = _authRepository.authStateChanges.listen(
      (user) async {
        try {
          if (user != null) {
            final userData = await _authRepository.getUserData(user.uid);
            emit(state.copyWith(
                status: AuthStatus.authenticated, user: userData));
          } else {
            emit(state.copyWith(status: AuthStatus.notAuthenticated));
          }
        } catch (e) {
          emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
        }
      },
    );
  }

  Future<void> signUp(
      {required String email,
      required String password,
      required String phoneNumber,
      required String userName,
      required String fullName}) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.signUp(
          email: email,
          password: password,
          fullName: fullName,
          phoneNumber: phoneNumber,
          userName: userName);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.signIn(email: email, password: password);
      emit(state.copyWith(status: AuthStatus.authenticated,user: user));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      emit(state.copyWith(status: AuthStatus.notAuthenticated,user: null));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }


}
