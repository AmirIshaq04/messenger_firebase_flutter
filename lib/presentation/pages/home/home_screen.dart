import 'package:chatting_app_flutter/data/services/service_locator.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_cubit.dart';
import 'package:chatting_app_flutter/presentation/pages/auth/login_screen.dart';
import 'package:chatting_app_flutter/router/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await getIt<AuthCubit>().signOut();
              getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(child: Text('Authenticated')),
        ],
      ),
    );
  }
}
