import 'package:flutter/material.dart';
import 'list.dart';
import 'dart:async';

class MyLists extends StatelessWidget {
  /*List<GiftList> _lists = <GiftList>[
    new GiftList(
      ownerName: 'Brendan Coll',
      listName: 'Birthday',
      progress: 0.33,
      items: <Gift>[
        new Gift("Computer", '', false),
        new Gift("Big Man", 'Kate', false),
        new Gift("Something", '', false),
      ],
      isFriends: false,
    ),
    new GiftList(
      ownerName: 'Brendan Coll',
      listName: 'Christmas',
      progress: 0.0,
      items: <Gift>[],
      isFriends: false,
    ),
  ];*/

  final List<GiftList> lists;

  MyLists(this.lists);

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      onRefresh: () {
        final Completer<Null> completer = new Completer<Null>();
        new Timer(const Duration(seconds: 1), () {
          completer.complete(null);
        });
        return completer.future;
      },
      child: new ListView.builder(
        padding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        itemBuilder: (_, int index) => lists[index],
        itemCount: lists.length,
      ),
    );
  }
}
