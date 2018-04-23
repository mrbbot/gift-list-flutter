import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

const kTakenStyle = const TextStyle(
  color: Colors.grey,
  decoration: TextDecoration.lineThrough,
);

class GiftList extends StatelessWidget {
  final int id;
  final String ownerName, ownerPhoto, listName, currentUid;
  final List<Gift> gifts;
  final bool isFriends;

  GiftList(
      {this.id, this.listName, this.ownerName, this.ownerPhoto, this.gifts, this.isFriends, this.currentUid});

  factory GiftList.fromJson(Map<String, dynamic> json,
      {String ownerName, String ownerPhoto, bool isFriends, String currentUid}) {
    List<dynamic> dynamicGiftList =
    json["gifts"]
        .map((json) =>
    new Gift.fromJson(json, currentUid: currentUid, isFriends: isFriends))
        .toList();
    List<Gift> gifts = <Gift>[];
    for (dynamic gift in dynamicGiftList) {
      Gift g = gift;
      gifts.add(g);
    }

    return new GiftList(
      id: json["id"],
      listName: json["name"],
      ownerName: ownerName,
      ownerPhoto: ownerPhoto,
      isFriends: isFriends,
      gifts: gifts,
      currentUid: currentUid,
    );
  }

  double get progress {
    double numClaimed = 0.0;
    gifts.forEach((gift) => numClaimed += (gift.claim.state ? 1.0 : 0.0));
    return gifts.length > 0 ? (numClaimed / gifts.length) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    bool claimed = false;
    for (Gift item in gifts) {
      if (item.claim.user == currentUid) {
        claimed = true;
        break;
      }
    }

    List<Widget> list = <Widget>[
      new ListTile(
        leading: new CircleAvatar(
          backgroundImage: new NetworkImage(ownerPhoto),
          backgroundColor: Colors.transparent,
        ),
        title: new Text(this.listName),
        subtitle: new Text(isFriends ? this.ownerName : "Me"),
        trailing: isFriends
            ? new Stack(
          alignment: Alignment.center,
          children: <Widget>[
            new CircularProgressIndicator(value: progress),
            new Icon(claimed ? Icons.favorite : Icons.favorite_border,
                color: claimed ? Theme
                    .of(context)
                    .primaryColor : null),
          ],
        )
            : null,
      ),
    ];

    final TextStyle takenMeStyle =
    kTakenStyle.copyWith(color: Theme
        .of(context)
        .primaryColor);
    gifts.forEach((item) {
      list.add(new Divider(height: 1.0));
      list.add(new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Text(
          item.name,
          textAlign: TextAlign.center,
          style: isFriends
              ? (item.claim.state
              ? (item.claim.user == currentUid ? takenMeStyle : kTakenStyle)
              : null)
              : null,
        ),
      ));
    });

    return new Container(
      margin: new EdgeInsets.symmetric(vertical: 6.0),
      child: new Card(
        child: new InkWell(
          onTap: () {
            Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => new GiftListDetail(this)),
            );
          },
          child: new Column(
            children: list,
          ),
        ),
      ),
    );
  }
}

class GiftListDetail extends StatelessWidget {
  final GiftList list;

  GiftListDetail(this.list);

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
          primaryColor: Theme
              .of(context)
              .primaryColor,
          accentColor: Theme
              .of(context)
              .accentColor,
          primaryColorBrightness: Brightness.light),
      child: new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.grey[100],
          title: new Text(list.listName),
        ),
        body: new RefreshIndicator(
          onRefresh: () {
            final Completer<Null> completer = new Completer<Null>();
            new Timer(const Duration(seconds: 1), () {
              completer.complete(null);
            });
            return completer.future;
          },
          child: list.gifts.length > 0
              ? new ListView.builder(
            scrollDirection: Axis.vertical,
            padding: new EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 10.0),
            itemBuilder: (_, int index) => list.gifts[index],
            itemCount: list.gifts.length,
          )
              : new Center(
            child: new Icon(Icons.sentiment_dissatisfied,
                size: 100.0, color: Colors.grey[500]),
          ),
        ),
      ),
    );
  }
}

class Gift extends StatelessWidget {
  final int id;
  final String name, url, imageUrl, currentUid;
  final Claim claim;
  final bool isFriends;

  Gift(this.id, this.name, this.url, this.imageUrl, this.claim, this.isFriends,
      this.currentUid);

  factory Gift.fromJson(Map<String, dynamic> json,
      { bool isFriends, String currentUid }) {
    return new Gift(
        json["id"],
        json["name"],
        json["url"],
        json["imageUrl"],
        new Claim.fromJson(json["claim"]),
        isFriends,
        currentUid
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = <Widget>[];
    if (isFriends) {
      if (claim.user == currentUid || !claim.state) {
        icons.add(new IconButton(
          icon: new Icon(
              claim.state ? Icons.favorite : Icons.favorite_border),
          color: claim.user == currentUid ? Theme
              .of(context)
              .primaryColor : null,
          onPressed: () {},
        ));
      }
    } else {
      icons.addAll(<Widget>[
        new IconButton(
          icon: new Icon(Icons.edit),
          onPressed: () {},
        ),
        new IconButton(
          icon: new Icon(Icons.delete),
          onPressed: () {},
        )
      ]);
    }
    if (url != null && url != '') {
      icons.add(new IconButton(
        icon: new Icon(Icons.shopping_cart),
        onPressed: () async {
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            print("Could not launch url: $url");
          }
        },
      ));
    }

    return new Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: new Card(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            (imageUrl != null) && (imageUrl != "") ? new Container(
              width: double.infinity,
              height: 150.0,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: new NetworkImage(imageUrl),
                      fit: BoxFit.cover)),
            ) : new Container(),
            new ListTile(
              title: new Text(
                name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: isFriends
                  ? new Text(
                  claim.state ? 'Claimed by ${claim.name}' : 'Not Claimed')
                  : null,
              trailing: new Row(
                children: icons,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Claim {
  bool state;
  String user;
  String name;
  String photo;

  Claim(this.state, this.user, this.name, this.photo);

  factory Claim.fromJson(Map<String, dynamic> json) {
    return new Claim(
      json["state"] != null ? json["state"] == 1 : false,
      json["user"] != null ? json["user"] : "Unknwon UID",
      json["name"] != null ? json["name"] : "Unknwon Name",
      json["photo"] != null
          ? json["photo"]
          : "https://via.placeholder.com/128?text=U",
    );
  }
}