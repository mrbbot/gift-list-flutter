import 'package:flutter/material.dart';
import 'dart:async';
import 'list.dart';

class FriendsLists extends StatelessWidget {
  /*List<GiftList> _lists = <GiftList>[
    new GiftList(
      ownerName: 'Brendan Coll',
      listName: 'Birthday',
      progress: 0.33,
      items: <Gift>[
        new Gift("Computer", '', true),
        new Gift("Big Man", 'Kate', true),
        new Gift("Something", '', true),
      ],
      isFriends: true,
    ),
    new GiftList(
      ownerName: 'Rose Coll',
      listName: 'Birthday',
      progress: 0.5,
      items: <Gift>[
        new Gift("Horse", '', true),
        new Gift("Gloves", 'Tony', true),
        new Gift(
            "Something really really long that will probably overflow", 'Me',
            true),
      ],
      isFriends: true,
    ),
    new GiftList(
      ownerName: 'Brendan Coll',
      listName: 'Christmas',
      progress: 0.0,
      items: <Gift>[],
      isFriends: true,
    ),
  ];*/

  final List<GiftList> lists;

  FriendsLists(this.lists);

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

class FriendsList extends StatelessWidget {
  final List<Friend> list;

  FriendsList(this.list);

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
      child: list.length > 0
          ? new ListView.builder(
              scrollDirection: Axis.vertical,
              padding:
                  new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              itemBuilder: (_, int index) =>
                  index % 2 == 0 ? list[(index / 2).floor()] : new Divider(),
              itemCount: (list.length * 2) - 1,
            )
          : new Center(
              child: new Icon(Icons.sentiment_dissatisfied,
                  size: 100.0, color: Colors.grey[500]),
            ),
    );
  }
}

class Friend extends StatelessWidget {
  final int id;
  final String uid;
  final String name;
  final String email;
  final String photo;

  // Incoming request
  final bool isRequest;

  // User sent request
  final bool sentRequest;

  Friend(
      {this.id,
      this.uid,
      this.name,
      this.email,
      this.photo,
      this.isRequest,
      this.sentRequest});

  factory Friend.fromJson(
    Map<String, dynamic> json, {
    bool isRequest,
    bool sentRequest,
  }) {
    return new Friend(
      id: json["id"],
      uid: json["friend"],
      name: json["name"],
      email: json["email"],
      photo: json["photo"],
      isRequest: isRequest,
      sentRequest: sentRequest,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = <Widget>[];
    if (isRequest) {
      icons.add(new IconButton(
        icon: new Icon(Icons.person_add),
        onPressed: () {},
      ));
    }
    icons.add(new IconButton(
      icon: new Icon(Icons.delete),
      onPressed: () {},
    ));

    return new ListTile(
      leading: new CircleAvatar(
        backgroundImage: new NetworkImage(photo),
        backgroundColor: Colors.transparent,
      ),
      title: new Text(
        name,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: new Text(
        isRequest
            ? "Friend Request"
            : (sentRequest ? "Friend Request Sent" : email),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: new Row(
        children: icons,
      ),
    );
  }
}
