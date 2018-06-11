import 'package:flutter/material.dart';
import 'package:gift_list/components/dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gift_list/models/gift.dart';

class GiftCard extends StatelessWidget {
  final Gift gift;
  final bool working;
  final bool currentUsers;
  final VoidCallback onClaim;
  final VoidCallback onRemoveClaim;

  GiftCard({
    this.gift,
    this.working,
    this.currentUsers,
    this.onClaim,
    this.onRemoveClaim,
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
        //TODO: Add edit/remove buttons
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

    Text descriptionText =
        gift.description != null ? new Text(gift.description) : null;

    return new ListTile(
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
    );
  }
}
