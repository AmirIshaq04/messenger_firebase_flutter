import 'package:chatting_app_flutter/core/common/custom_button.dart';
import 'package:chatting_app_flutter/core/common/custom_textfield.dart';
import 'package:chatting_app_flutter/core/utils/toast.dart';
import 'package:chatting_app_flutter/data/repositories/auth_repository.dart';
import 'package:chatting_app_flutter/data/services/service_locator.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_cubit.dart';
import 'package:chatting_app_flutter/logic/cubits/auth/auth_state.dart';
import 'package:chatting_app_flutter/presentation/pages/home/home_screen.dart';
import 'package:chatting_app_flutter/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _userNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    _userNameFocus.dispose();
    _emailFocus.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name can not be empty";
    }
    return null;
  }

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

  String? _validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return "User Name can not be empty";
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone can not be empty";
    }
    final RegExp phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
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

  Future<void> handleSignup() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().signUp(
            email: emailController.text.trim(),
            fullName: nameController.text.trim(),
            userName: usernameController.text.trim(),
            phoneNumber: phoneController.text.trim(),
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
      // listenWhen: (previous, current) {
      //   return previous.status != current.status ||
      //       previous.error != current.error;
      // },
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          getIt<AppRouter>().pushAndRemoveUntil(HomeScreen());
        } else if (state.status == AuthStatus.error && state.error != null) {
          ShowToast.flutterToast(context, message: state.error.toString());
        }
      },
      child: Scaffold(
        appBar: AppBar(),
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
                    'Create account',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Please fill the details to continue',
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
                      controller: emailController,
                      prefexIcon: Icon(
                        Icons.email_outlined,
                        size: 20,
                      ),
                      hintText: 'Email'),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextfield(
                      obsecreText: false,
                      focusNode: _nameFocus,
                      validator: _validateName,
                      prefexIcon: Icon(
                        Icons.person_2_outlined,
                        size: 20,
                      ),
                      controller: nameController,
                      hintText: 'Full name'),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextfield(
                      obsecreText: false,
                      focusNode: _userNameFocus,
                      validator: _validateUserName,
                      prefexIcon: Icon(
                        Icons.alternate_email,
                        size: 20,
                      ),
                      controller: usernameController,
                      hintText: 'User name'),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextfield(
                      obsecreText: false,
                      focusNode: _phoneFocus,
                      validator: _validatePhone,
                      prefexIcon: Icon(
                        Icons.call_end_outlined,
                        size: 20,
                      ),
                      controller: phoneController,
                      hintText: 'Phone number'),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextfield(
                      obsecreText: !_isPasswordVisible,
                      focusNode: _passwordFocus,
                      validator: _validatePassword,
                      prefexIcon: Icon(
                        Icons.lock_outline,
                        size: 20,
                      ),
                      controller: passwordController,
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
                      hintText: 'password'),
                  SizedBox(
                    height: 30,
                  ),
                  CustomButton(
                    onPressed: handleSignup,
                    text: 'Create Account',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account?",
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                        children: [
                          TextSpan(
                            text: ' Login',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
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
