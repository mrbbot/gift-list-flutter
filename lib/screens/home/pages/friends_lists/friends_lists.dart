import 'package:flutter/material.dart';
import 'package:gift_list/models/gift_list.dart';
import 'package:gift_list/screens/home/pages/friends_lists/gift_list_card.dart';

class FriendsListsPage extends StatelessWidget {
  final List<GiftList> friendsLists;

  final RefreshCallback onRefresh;
  final ValueSetter<int> onClick;

  FriendsListsPage({
    this.friendsLists,
    this.onRefresh,
    this.onClick
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: new ListView.builder(
        itemBuilder: (BuildContext context, int i) {
          return new Padding(
            padding: (i == friendsLists.length - 1)
                ? const EdgeInsets.all(8.0)
                : const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: new GiftListCard(
              giftList: friendsLists[i],
              onClick: () => onClick(friendsLists[i].id),
            ),
          );
        },
        itemCount: friendsLists.length,
      ),
    );
  }
}
