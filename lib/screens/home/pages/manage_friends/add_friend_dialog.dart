import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gift_list/components/loading_stack.dart';

typedef Future<String> AddFriendCallback(String email);

final RegExp _emailRegExp =
    new RegExp(r"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}", caseSensitive: false);

class AddFriendDialog extends StatefulWidget {
  final AddFriendCallback addFriendCallback;

  AddFriendDialog({@required this.addFriendCallback});

  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog>
    with SingleTickerProviderStateMixin {
  AnimationController _opacityAnimationController;
  Animation _opacityAnimation;

  TextEditingController _textController;

  bool _emailValid;
  String _errorText;

  @override
  void initState() {
    super.initState();

    _opacityAnimationController = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _opacityAnimationController.value = 1.0;
    _opacityAnimation = new CurvedAnimation(
        parent: _opacityAnimationController, curve: Curves.easeInOut)
      ..addListener(() {
        setState(() {});
      });

    _textController = new TextEditingController();
    _emailValid = false;
  }

  @override
  void dispose() {
    _opacityAnimationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool adding = _opacityAnimation.value < 1.0;

    return new AlertDialog(
      title: new Text("Add Friend"),
      content: new LoadingStack(
        opacityAnimation: _opacityAnimation,
        child: new TextField(
          enabled: !adding,
          controller: _textController,
          decoration: new InputDecoration(
            labelText: "Email",
            errorText: _errorText
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (email) {
            bool emailValid = _emailRegExp.hasMatch(email);
            if (emailValid != _emailValid) {
              setState(() {
                _emailValid = emailValid;
              });
            }
          },
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Cancel'),
          onPressed: adding ? null : () => Navigator.of(context).pop(),
        ),
        new FlatButton(
          child: new Text('Add'),
          onPressed: adding || !_emailValid
              ? null
              : () async {
                  _opacityAnimationController.reverse();

                  String error =
                      await widget.addFriendCallback(_textController.text);

                  if(error == null) {
                    Navigator.of(context).pop();
                  } else {
                    _opacityAnimationController.forward();
                    setState(() {
                      _errorText = error;
                    });
                  }
                },
        ),
      ],
    );
  }
}
