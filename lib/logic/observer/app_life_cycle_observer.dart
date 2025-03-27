import 'package:chatting_app_flutter/data/repositories/chat_repository.dart';
import 'package:flutter/material.dart';

class AppLifeCycleObserver extends WidgetsBindingObserver {
  final String userId;
  final ChatRepository chatRepository;

  AppLifeCycleObserver({required this.userId, required this.chatRepository});
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        chatRepository.updateOnoineStatus(userId, false);
        break;
      case AppLifecycleState.resumed:
        chatRepository.updateOnoineStatus(userId, true);
      default:
        break;
    }
  }
}
