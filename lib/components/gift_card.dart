import 'package:flutter/material.dart';
import 'package:gift_list/components/dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gift_list/models/gift.dart';
import 'package:transparent_image/transparent_image.dart';

class GiftCard extends StatelessWidget {
  final Gift gift;
  final bool working;
  final bool currentUsers;
  final VoidCallback onClaim;
  final VoidCallback onRemoveClaim;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  GiftCard({
    this.gift,
    this.working,
    this.currentUsers,
    this.onClaim,
    this.onRemoveClaim,
    this.onEdit,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = <Widget>[];

    if (gift.url != null && gift.url != "") {
      buttons.add(new IconButton(
        icon: new Icon(Icons.shopping_cart),
        onPressed: () async {
          if (await canLaunch(gift.url)) {
            await launch(gift.url);
          } else {
            showMessageDialog(context, "Invalid", "Could not launch URL!");
          }
        },
        tooltip: "Buy",
      ));
    }

    if (working) {
      buttons.add(new CircularProgressIndicator());
    } else {
      if (currentUsers) {
        buttons.add(new IconButton(
          icon: new Icon(Icons.delete),
          onPressed: onRemove,
        ));
      } else {
        if (gift.canClaim) {
          buttons.add(new IconButton(
            icon: gift.claimed
                ? new Icon(
                    Icons.favorite,
                    color: Theme.of(context).primaryColor,
                  )
                : new Icon(Icons.favorite_border),
            onPressed: gift.claimed ? onRemoveClaim : onClaim,
            tooltip: gift.claimed ? "Remove Claim" : "Claim",
          ));
        }
      }
    }

    Text descriptionText = (gift.description != null && gift.description != "")
        ? new Text(gift.description)
        : null;

    List<Widget> cardColumnChildren = <Widget>[];

    if (gift.imageUrl != null && gift.imageUrl != "") {
      cardColumnChildren.add(new FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: gift.imageUrl,
      ));
    }

    cardColumnChildren.add(
      new ListTile(
        title: new Text(gift.name),
        subtitle: currentUsers
            ? descriptionText
            : (gift.claimed
                ? new Text("Claimed by ${gift.claimedBy}")
                : descriptionText),
        trailing: new Row(
          mainAxisSize: MainAxisSize.min,
          children: buttons,
        ),
      ),
    );

    return new Card(
      child: new InkWell(
        onTap: currentUsers ? onEdit : null,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: cardColumnChildren,
        ),
      ),
    );
  }
}
