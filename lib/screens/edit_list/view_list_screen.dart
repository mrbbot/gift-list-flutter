import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gift_list/components/gift_card.dart';
import 'package:gift_list/models/gift_list.dart';
import 'package:gift_list/services/lists_service.dart';

typedef Future<Null> ListActionCallback(int listId, int giftId);

ListsService _listsService = ListsService.instance;

class ViewListScreen extends StatefulWidget {
  final GiftList list;
  final RefreshCallback onRefresh;
  final ListActionCallback onClaim;
  final ListActionCallback onRemoveClaim;

  ViewListScreen({
    this.list,
    this.onRefresh,
    this.onClaim,
    this.onRemoveClaim,
  });

  @override
  _ViewListScreenState createState() => _ViewListScreenState();
}

class _ViewListScreenState extends State<ViewListScreen> {
  List<int> _working;

  @override
  void initState() {
    super.initState();
    _working = [];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _listsService.getFriendsList(widget.list.id),
      initialData: widget.list,
      builder: (BuildContext context, AsyncSnapshot<GiftList> snapshot) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(snapshot.data.name),
          ),
          body: new RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: new ListView.builder(
              itemBuilder: (BuildContext context, int i) {
                if (i % 2 == 0) {
                  return new GiftCard(
                    gift: snapshot.data.gifts[i ~/ 2],
                    working: _working.contains(snapshot.data.gifts[i ~/ 2].id),
                    onClaim: () async {
                      int giftId = snapshot.data.gifts[i ~/ 2].id;
                      setState(() => _working.add(giftId));
                      await widget.onClaim(widget.list.id, giftId);
                      setState(() => _working.remove(giftId));
                    },
                    onRemoveClaim: () async {
                      int giftId = snapshot.data.gifts[i ~/ 2].id;
                      setState(() => _working.add(giftId));
                      await widget.onRemoveClaim(widget.list.id, giftId);
                      setState(() => _working.remove(giftId));
                    },
                  );
                } else {
                  return new Divider(
                    height: 0.0,
                  );
                }
              },
              itemCount: (snapshot.data.gifts.length * 2) - 1,
            ),
          ),
        );
      },
    );
  }
}
