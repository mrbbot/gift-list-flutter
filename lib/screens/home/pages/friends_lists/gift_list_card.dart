import 'package:flutter/material.dart';
import 'package:gift_list/models/gift_list.dart';
import 'package:transparent_image/transparent_image.dart';

class GiftListCard extends StatelessWidget {
  final GiftList giftList;
  final bool currentUsers;
  final VoidCallback onClick;

  GiftListCard({
    @required this.giftList,
    this.currentUsers = false,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    bool hasClaim = giftList.hasClaim;
    return new Card(
      child: new ListTile(
        onTap: onClick,
        leading: new ClipOval(
          child: new FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: giftList.friend.user.photo,
          ),
        ),
        title: new Text(giftList.name),
        subtitle: new Text(giftList.friend.user.firstName),
        trailing: new Stack(
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
