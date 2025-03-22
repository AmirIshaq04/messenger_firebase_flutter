import 'package:chatting_app_flutter/data/models/user_models.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, notAuthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModels? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserModels? user, String? error}) {
    return AuthState(
        error: error ?? this.error,
        status: status ?? this.status,
        user: user ?? this.user);
  }

  @override
  List<Object?> get props => [error, status, user];
}
