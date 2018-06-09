import 'dart:async';

import 'package:flutter/material.dart';

Future<Null> showMessageDialog(
    BuildContext context, String title, String message) {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text(title),
        content: new Text(message),
        actions: <Widget>[
          new FlatButton(
            child: new Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

Future<Null> showConfirmDialog(BuildContext context, String title,
    String message, VoidCallback confirmCallback) {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return new AlertDialog(
        title: new Text(title),
        content: new Text(message),
        actions: <Widget>[
          new FlatButton(
            child: new Text('No'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          new FlatButton(
            child: new Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
              confirmCallback();
            },
          ),
        ],
      );
    },
  );
}