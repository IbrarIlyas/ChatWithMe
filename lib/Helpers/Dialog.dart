import 'package:flutter/material.dart';

class Dialogs {
  static void showprogressbar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
