import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowToast {
  static void flutterToast(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: isError ? Colors.red : Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
