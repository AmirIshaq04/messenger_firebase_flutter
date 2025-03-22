import 'package:chatting_app_flutter/core/common/custom_button.dart';
import 'package:chatting_app_flutter/core/common/custom_textfield.dart';
import 'package:chatting_app_flutter/core/utils/toast.dart';
import 'package:chatting_app_flutter/data/services/service_locator.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_cubit.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_state.dart';
import 'package:chatting_app_flutter/presentation/pages/auth/sign_up.dart';
import 'package:chatting_app_flutter/presentation/pages/home/home_screen.dart';
import 'package:chatting_app_flutter/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _isPasswordVisible = false;
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email can not be empty";
    }
    final RegExp emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address(eg.example@email.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password can not be empty";
    }
    if (value.length < 6) {
      return 'Please enter 6 digits long password';
    }
    return null;
  }

  Future<void> handleSignIn() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().signIn(
            email: emailController.text.trim(),
            password: passwordController.text.trim());
      } catch (e) {
        Fluttertoast.showToast(
            msg: "$e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.error != current.error;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          getIt<AppRouter>().pushAndRemoveUntil(HomeScreen());
        } else if (state.status == AuthStatus.error && state.error != null) {
          ShowToast.flutterToast(context, message: state.error.toString());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CustomTextfield(
                      obsecreText: false,
                      focusNode: _emailFocus,
                      validator: _validateEmail,
                      prefexIcon: Icon(Icons.email_outlined),
                      controller: emailController,
                      hintText: 'Enter your email'),
                  SizedBox(
                    height: 16,
                  ),
                  CustomTextfield(
                      focusNode: _passwordFocus,
                      validator: _validatePassword,
                      prefexIcon: Icon(Icons.lock_open_outlined),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        icon: _isPasswordVisible
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                      ),
                      obsecreText: !_isPasswordVisible,
                      controller: passwordController,
                      hintText: 'Enter your Password'),
                  SizedBox(
                    height: 50,
                  ),
                  Builder(builder: (context) {
                    return CustomButton(
                      onPressed: handleSignIn,
                      text: 'Login',
                    );
                  }),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account?",
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                        children: [
                          TextSpan(
                            text: ' Sign up',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                getIt<AppRouter>().push(SignUp());
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
