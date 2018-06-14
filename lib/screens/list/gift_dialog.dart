import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gift_list/components/loading_stack.dart';
import 'package:gift_list/models/gift.dart';

typedef Future<Null> AddGiftCallback(String name, String description,
    String url, String imageUrl);
typedef Future<Null> EditGiftCallback(int id, String name, String description,
    String url, String imageUrl);

class GiftDialog extends StatefulWidget {
  final Gift gift;
  final AddGiftCallback onAdd;
  final EditGiftCallback onEdit;

  GiftDialog({this.gift, this.onAdd, this.onEdit});

  @override
  _GiftDialogState createState() => _GiftDialogState();
}

class _GiftDialogState extends State<GiftDialog>
    with SingleTickerProviderStateMixin {
  AnimationController _opacityAnimationController;
  Animation _opacityAnimation;

  TextEditingController _nameController;
  TextEditingController _descriptionController;

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

    _nameController = new TextEditingController(text: widget.gift.name);
    _descriptionController =
    new TextEditingController(text: widget.gift.description);
  }

  @override
  void dispose() {
    _opacityAnimationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool working = _opacityAnimation.value < 1.0;

    return new AlertDialog(
        title: new Text("${widget.gift.id == null ? "Add" : "Edit"} Gift"),
        content: new LoadingStack(
          opacityAnimation: _opacityAnimation,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new TextField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: "Name",
                ),
              ),
              new TextField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: new InputDecoration(
                  labelText: "Notes",
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Cancel'),
            onPressed: working ? null : () => Navigator.of(context).pop(),
          ),
          new FlatButton(
            child: new Text(widget.gift.id == null ? "Add" : "Save"),
            onPressed: working
                ? null
                : () async {
              _opacityAnimationController.reverse();

              if(widget.gift.id == null)
                await widget.onAdd(_nameController.text, _descriptionController.text, "", "");
              else
                await widget.onEdit(widget.gift.id, _nameController.text, _descriptionController.text, widget.gift.url, widget.gift.imageUrl);

              Navigator.of(context).pop();
            },
          ),
        ]);
  }
}
