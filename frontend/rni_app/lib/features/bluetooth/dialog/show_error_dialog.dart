import 'package:flutter/material.dart';

Future<void> showAlert(
  BuildContext context, {
  required String title,
  required String message,
  String buttonText = 'OK',
  VoidCallback? onPressed,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onPressed?.call();
          },
          child: Text(buttonText),
        ),
      ],
    ),
  );
}
