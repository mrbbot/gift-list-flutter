import 'dart:async';
import 'dart:io';

import 'package:gift_list/models/friend.dart';
import 'package:gift_list/models/gift_list.dart';
import 'package:gift_list/models/user.dart';
import 'package:gift_list/services/api.dart';
import 'package:gift_list/services/auth_service.dart';
import 'package:gift_list/services/friends_service.dart';

final AuthService _authService = AuthService.instance;
final FriendsService _friendsService = FriendsService.instance;

class ListsService {
  static ListsService instance = new ListsService._();

  StreamController<List<GiftList>> _friendsListsStreamController;
  StreamController<List<GiftList>> _myListsStreamController;

  ListsService._() {
    _friendsListsStreamController = new StreamController.broadcast();
    _myListsStreamController = new StreamController.broadcast();
  }

  List<GiftList> _cachedFriendsLists;
  List<GiftList> _cachedMyLists;

  bool isFriendsListsCacheValid() => _cachedFriendsLists != null;

  bool isMyListsCacheValid() => _cachedMyLists != null;

  Stream<List<GiftList>> get friendsListsStream =>
      _friendsListsStreamController.stream;

  Stream<List<GiftList>> get myListsStream => _myListsStreamController.stream;

  List<GiftList> _pushFriendsLists() {
    List<GiftList> result = new List.from(_cachedFriendsLists);

    result.sort((a, b) {
      bool aHasClaim = a.hasClaim;
      bool bHasClaim = b.hasClaim;
      double aClaimedPercent = a.claimedPercent;
      double bClaimedPercent = b.claimedPercent;

      if (aClaimedPercent == 1.0) aClaimedPercent = -1.0;
      if (bClaimedPercent == 1.0) bClaimedPercent = -1.0;

      if (aHasClaim == bHasClaim) {
        return ((bClaimedPercent - aClaimedPercent) * 100).round();
      } else {
        if (aHasClaim)
          return 1;
        else if (bHasClaim) return -1;
      }
    });

    _friendsListsStreamController.add(result);
    return result;
  }

  List<GiftList> _pushMyLists() {
    List<GiftList> result = new List.from(_cachedMyLists);

    result.sort((a, b) => b.id - a.id);

    _myListsStreamController.add(result);
    return result;
  }

  Future<List<GiftList>> _getLists(Friend friend) async {
    ApiResponse response = await get("/lists/${friend.user.uid}");
    //TODO: Check status code

    List<dynamic> listsResponse = response.body as List<dynamic>;
    //TODO: Check for invalid urls here and remove them
    return listsResponse
        .map((listJson) => new GiftList.fromJson(listJson, friend: friend))
        .toList();
  }

  Future<Null> refreshFriendsLists(Friend friend, bool refresh) async {
    _cachedFriendsLists
        .removeWhere((list) => list.friend.user.uid == friend.user.uid);
    if (refresh) {
      _cachedFriendsLists.addAll(await _getLists(friend));
    }
    _pushFriendsLists();
  }

  bool _listeningToFriendsStream = false;

  void listenToFriendsStreamChanges() {
    if (!_listeningToFriendsStream) {
      print("Listening for changes to friends...");
      _listeningToFriendsStream = true;
      _friendsService.currentFriendsChangesStream.forEach((change) {
        print("Friends updated, so updating friends' lists too");
        if (change.friend == null) {
          print("  Updating all friends' lists...");
          getFriendsLists(cache: false).listen((i) => {});
        } else {
          print("  Updating ${change.friend.user.name}'s lists...");
          refreshFriendsLists(change.friend, change.refresh);
        }
      });
    }
  }

  Stream<int> getFriendsLists({bool cache = true}) {
    if (cache && isFriendsListsCacheValid()) {
      _pushFriendsLists();
      return null;
    }

    StreamController<int> streamController;

    streamController = new StreamController(onListen: () async {
      List<Friend> friends = await _friendsService.getCurrentFriends();
      friends.removeWhere((friend) => !friend.state);

      List<GiftList> friendsLists = <GiftList>[];

      for (int i = 0; i < friends.length; i++) {
        friendsLists.addAll(await _getLists(friends[i]));
        streamController.add(i + 1);
      }

      friendsLists.removeWhere((list) => list.gifts.length == 0);

      this._cachedFriendsLists = friendsLists;
      _pushFriendsLists();

      streamController.close();
    });

    return streamController.stream;
  }

  Stream<GiftList> getFriendsList(int id) {
    //TODO: May be able to click on list whilst updating them after removing
    //friend leading to an error state with first where
    return friendsListsStream.transform(new StreamTransformer.fromHandlers(
      handleData: (List<GiftList> data, EventSink<GiftList> sink) {
        sink.add(data.firstWhere((list) => list.id == id));
      },
    ));
  }

  Future<String> claimGift(int listId, int giftId, int state) {
    return post("/list/$listId/gift/$giftId/claim", {"state": state})
        .then((response) {
      if (response.statusCode == HttpStatus.OK) {
        int listIndex =
            _cachedFriendsLists.indexWhere((list) => list.id == listId);
        int giftIndex = _cachedFriendsLists[listIndex]
            .gifts
            .indexWhere((gift) => gift.id == giftId);

        if (state == 1) {
          _cachedFriendsLists[listIndex].gifts[giftIndex].claim.state = 1;
          _cachedFriendsLists[listIndex].gifts[giftIndex].claim.user =
              _authService.cachedCurrentUser;
        } else {
          _cachedFriendsLists[listIndex].gifts[giftIndex].claim.state = 0;
          _cachedFriendsLists[listIndex].gifts[giftIndex].claim.user =
              User.nullUser;
        }

        _pushFriendsLists();

        return null;
      } else {
        return "An unexpected error occurred.";
      }
    });
  }

  Future<List<GiftList>> getMyLists({bool cache = true}) async {
    if (!cache || !isMyListsCacheValid()) {
      ApiResponse response =
          await get("/lists/${(await _authService.currentUser()).uid}");
      _cachedMyLists = (response.body as List<dynamic>)
          .map((listJson) => new GiftList.fromJson(listJson, friend: null))
          .toList();
    }
    return _pushMyLists();
  }

  Stream<GiftList> getMyList(int id) {
    return myListsStream.transform(new StreamTransformer.fromHandlers(
        handleData: (List<GiftList> data, EventSink<GiftList> sink) {
      sink.add(data.firstWhere((list) => list.id == id));
    }));
  }

  Future<String> editList(int id, String name, String description) {
    return post("/list/$id", {
      "name": name,
      "description": description,
    }).then((response) {
      if (response.statusCode == HttpStatus.OK) {
        int listIndex = _cachedMyLists.indexWhere((list) => list.id == id);
        _cachedMyLists[listIndex].name = name;
        _cachedMyLists[listIndex].description = description;
        _pushMyLists();
        return null;
      } else {
        return "An unexpected error occurred.";
      }
    });
  }

  Future<String> removeList(int id) {
    return delete("/list/$id").then((response) {
      if (response.statusCode == HttpStatus.OK) {
        _cachedMyLists.removeWhere((list) => list.id == id);
        _pushMyLists();
        return null;
      } else {
        return "An unexpected error occurred.";
      }
    });
  }
}
