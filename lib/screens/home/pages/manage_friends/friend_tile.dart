import 'package:flutter/material.dart';
import 'package:gift_list/components/dialog.dart';
import 'package:gift_list/models/friend.dart';
import 'package:transparent_image/transparent_image.dart';

class FriendTile extends StatelessWidget {
  final Friend friend;
  final bool isRequest;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onRemove;
  final bool working;

  FriendTile(
      {@required this.friend,
      this.isRequest = false,
      this.onAccept,
      this.onReject,
      this.onRemove,
      this.working = false});

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onLongPress: isRequest || working
          ? null
          : () {
              showConfirmDialog(
                  context,
                  friend.state ? "Unfriend?" : "Withdraw?",
                  friend.state
                      ? "Are you sure you want to unfriend ${friend.user
                .name}?"
                      : "Are you sure you want to withdraw this request?",
                  onRemove);
            },
      child: new Opacity(
        opacity: (isRequest || friend.state) && !working ? 1.0 : 0.5,
        child: new ListTile(
          leading: new ClipOval(
            child: new FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: friend.user.photo,
            ),
          ),
          title: new Text(friend.user.name),
          subtitle: new Text(
            friend.state ? friend.user.email : "Pending Friend Request",
            overflow: TextOverflow.ellipsis,
          ),
          trailing: working
              ? new CircularProgressIndicator()
              : (isRequest
                  ? new Row(
                      children: <Widget>[
                        new IconButton(
                          icon: new Icon(Icons.check),
                          tooltip: "Accept",
                          onPressed: onAccept,
                        ),
                        new IconButton(
                          icon: new Icon(Icons.clear),
                          tooltip: "Reject",
                          onPressed: () {
                            showConfirmDialog(
                                context,
                                "Reject?",
                                "Are you sure you want to reject this request?",
                                onReject);
                          },
                        ),
                      ],
                    )
                  : null),
        ),
      ),
    );
  }
}
