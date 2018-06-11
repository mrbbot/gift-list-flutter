import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gift_list/components/empty_state.dart';
import 'package:gift_list/components/gift_card.dart';
import 'package:gift_list/models/gift_list.dart';
import 'package:gift_list/services/lists_service.dart';

typedef Future<Null> ListActionCallback(int listId, int giftId);
typedef Future<Null> ListEditCallback(
    int listId, String text, String description);

ListsService _listsService = ListsService.instance;

class ListScreen extends StatefulWidget {
  final GiftList list;
  final RefreshCallback onRefresh;
  final ListActionCallback onClaim;
  final ListActionCallback onRemoveClaim;
  final ListEditCallback onEdit;

  ListScreen({
    this.list,
    this.onRefresh,
    this.onClaim,
    this.onRemoveClaim,
    this.onEdit,
  });

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<int> _working;
  TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _working = [];
    if (widget.list.currentUsers) {
      _titleController = new TextEditingController(
        text: widget.list.id != null ? widget.list.name : "",
      );
    }
  }

  @override
  void dispose() {
    if (widget.list.currentUsers) _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool currentUsers = widget.list.currentUsers;
    return new StreamBuilder(
      stream: currentUsers
          ? _listsService.getMyList(widget.list.id)
          : _listsService.getFriendsList(widget.list.id),
      initialData: widget.list,
      builder: (BuildContext context, AsyncSnapshot<GiftList> snapshot) {
        return new Scaffold(
          appBar: new AppBar(
            leading: new IconButton(
                icon: currentUsers ? new Icon(Icons.check) : const BackButton(),
                tooltip: currentUsers
                    ? "Save"
                    : MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () {
                  if (currentUsers) {
                    widget.onEdit(
                      snapshot.data.id,
                      _titleController.text,
                      snapshot.data.description,
                    );
                  }
                  Navigator.maybePop(context);
                }),
            title: currentUsers
                ? new TextField(
                    controller: _titleController,
                    keyboardType: TextInputType.text,
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration.collapsed(
                      hintText: "Title",
                      hintStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20.0,
                      ),
                    ),
                  )
                : new Text(snapshot.data.name),
          ),
          body: new RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: snapshot.data.gifts.length > 0
                ? new ListView.builder(
                    itemBuilder: (BuildContext context, int i) {
                      if (i % 2 == 0) {
                        return new GiftCard(
                          gift: snapshot.data.gifts[i ~/ 2],
                          working:
                              _working.contains(snapshot.data.gifts[i ~/ 2].id),
                          currentUsers: currentUsers,
                          onClaim: () async {
                            int giftId = snapshot.data.gifts[i ~/ 2].id;
                            setState(() => _working.add(giftId));
                            await widget.onClaim(snapshot.data.id, giftId);
                            setState(() => _working.remove(giftId));
                          },
                          onRemoveClaim: () async {
                            int giftId = snapshot.data.gifts[i ~/ 2].id;
                            setState(() => _working.add(giftId));
                            await widget.onRemoveClaim(
                                snapshot.data.id, giftId);
                            setState(() => _working.remove(giftId));
                          },
                        );
                      } else {
                        return new Divider(
                          height: 0.0,
                          //color: Colors.transparent,
                        );
                      }
                    },
                    itemCount: (snapshot.data.gifts.length * 2) - 1,
                  )
                : new EmptyState(
                    icon: Icons.mood_bad,
                    message:
                        "This list is empty! Add some gifts so your friends can start claiming stuff!",
                  ),
          ),
        );
      },
    );
  }
}
