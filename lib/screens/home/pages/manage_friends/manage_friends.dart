import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gift_list/models/friend.dart';
import 'package:gift_list/screens/home/pages/manage_friends/friend_tile.dart';

class ManageFriendsPage extends StatefulWidget {
  final List<Friend> currentFriends;
  final List<Friend> friendRequests;

  final RefreshCallback onRefresh;
  final AsyncValueSetter<int> onRemove;
  final AsyncValueSetter<int> onAccept;
  final AsyncValueSetter<int> onReject;

  ManageFriendsPage({
    this.currentFriends,
    this.friendRequests,
    this.onRefresh,
    this.onRemove,
    this.onAccept,
    this.onReject,
  });

  @override
  _ManageFriendsPageState createState() => _ManageFriendsPageState();
}

class _ManageFriendsPageState extends State<ManageFriendsPage> {
  List<int> _working;

  @override
  void initState() {
    super.initState();
    _working = [];
  }

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: new ListView.builder(
        itemBuilder: (context, i) {
          if (i > widget.friendRequests.length + 1 ||
              widget.friendRequests.length == 0) {
            Friend friend = widget.currentFriends[i -
                (widget.friendRequests.length > 0
                    ? widget.friendRequests.length + 2
                    : 0)];
            return new FriendTile(
              friend: friend,
              onRemove: () async {
                setState(() => _working.add(friend.id));
                await widget.onRemove(friend.id);
                setState(() => _working.remove(friend.id));
              },
              working: _working.contains(friend.id),
            );
          } else if (i == widget.friendRequests.length + 1) {
            return new Divider();
          } else if (i == 0) {
            return new Padding(
              padding:
                  const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: new Text(
                "Friend Requests",
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.grey[700]),
              ),
            );
          } else {
            Friend friend = widget.friendRequests[i - 1];
            return new FriendTile(
              friend: friend,
              isRequest: true,
              onAccept: () async {
                setState(() => _working.add(friend.id));
                await widget.onAccept(friend.id);
                setState(() => _working.remove(friend.id));
              },
              onReject: () async {
                setState(() => _working.add(friend.id));
                await widget.onReject(friend.id);
                setState(() => _working.remove(friend.id));
              },
              working: _working.contains(friend.id),
            );
          }
        },
        itemCount: widget.friendRequests.length +
            (widget.friendRequests.length > 0 ? 2 : 0) +
            widget.currentFriends.length,
      ),
    );
  }
}
