import 'dart:async';

import 'package:gift_list/models/friend.dart';
import 'package:gift_list/services/friends_service.dart';
import 'package:gift_list/services/lists_service.dart';

final FriendsService _friendsService = FriendsService.instance;
final ListsService _listsService = ListsService.instance;

Stream<double> load() {
  StreamController<double> controller;
  controller = new StreamController<double>(onListen: () async {
    controller.add(0.1);
    await _listsService.getMyLists(cache: false);

    controller.add(0.2);
    List<Friend> friends =
        new List.from(await _friendsService.getCurrentFriends(cache: false));
    friends.removeWhere((friend) => !friend.state);

    if (friends.length > 0) {
      await for (int i in _listsService.getFriendsLists(cache: false)) {
        controller.add(((i / friends.length) * 0.8) + 0.2);
      }
    } else {
      controller.add(1.0);
    }

    controller.close();
  });
  return controller.stream;
}
