import 'package:flutter/material.dart';
import 'package:gift_list/components/dialog.dart';
import 'package:gift_list/models/gift_list.dart';
import 'package:transparent_image/transparent_image.dart';

class GiftListCard extends StatelessWidget {
  final GiftList giftList;
  final VoidCallback onClick;
  final VoidCallback onRemove;
  final bool working;

  GiftListCard({
    @required this.giftList,
    this.onClick,
    this.onRemove,
    this.working = false,
  });

  @override
  Widget build(BuildContext context) {
    bool hasClaim = giftList.hasClaim;
    bool currentUsers = giftList.currentUsers;

    return new Card(
      child: new ListTile(
        onTap: onClick,
        leading: currentUsers
            ? null
            : new ClipOval(
                child: new FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: giftList.friend.user.photo,
                ),
              ),
        title: new Text(giftList.name),
        subtitle: currentUsers
            ? new Text(
                "${giftList.gifts.length} gift${giftList.gifts.length == 1
                ? ''
                : 's'}")
            : new Text(giftList.friend.user.firstName),
        trailing: currentUsers
            ? (working
                ? new CircularProgressIndicator()
                : new IconButton(
                    icon: new Icon(Icons.delete),
                    onPressed: () {
                      showConfirmDialog(
                          context,
                          "Remove",
                          "Are you sure you want to remove this list?",
                          onRemove);
                    },
                  ))
            : new Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  new CircularProgressIndicator(
                    value: giftList.claimedPercent,
                  ),
                  new Icon(
                    hasClaim ? Icons.favorite : Icons.favorite_border,
                    color: hasClaim ? Theme.of(context).primaryColor : null,
                  ),
                ],
              ),
      ),
    );
  }
}
