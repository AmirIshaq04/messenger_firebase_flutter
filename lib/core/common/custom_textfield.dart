import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool? obsecreText;
  final TextInputType? inputType;
  final Widget? prefexIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  const CustomTextfield({
    super.key,
    this.inputType,
    this.prefexIcon,
    this.suffixIcon,
    this.validator,
    required this.controller,
    this.focusNode,
    this.obsecreText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obsecreText!,
      keyboardType: inputType,
      focusNode: focusNode,
      validator: validator,
      decoration: InputDecoration(
          hintText: hintText, prefixIcon: prefexIcon, suffixIcon: suffixIcon),
    );
  }
}
