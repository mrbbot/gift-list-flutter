import 'dart:async';
import 'dart:io';

import 'package:gift_list/models/friend.dart';
import 'package:gift_list/services/api.dart';

class FriendChange {
  Friend friend;
  bool refresh;

  FriendChange({this.friend, this.refresh});
}

class FriendsService {
  static FriendsService instance = new FriendsService._();

  StreamController<List<Friend>> _currentFriendsStreamController;
  StreamController<FriendChange> _currentFriendsChangesStreamController;
  StreamController<List<Friend>> _friendRequestsStreamController;

  FriendsService._() {
    _currentFriendsStreamController = new StreamController.broadcast();
    _currentFriendsChangesStreamController = new StreamController.broadcast();
    _friendRequestsStreamController = new StreamController.broadcast();
  }

  List<Friend> _cachedCurrentFriends;
  List<Friend> _cachedFriendRequests;

  bool isCacheValid() =>
      _cachedCurrentFriends != null && _cachedFriendRequests != null;

  Stream<List<Friend>> get currentFriendsStream =>
      _currentFriendsStreamController.stream;

  Stream<FriendChange> get currentFriendsChangesStream =>
      _currentFriendsChangesStreamController.stream;

  Stream<List<Friend>> get friendRequestsStream =>
      _friendRequestsStreamController.stream;

  List<Friend> _pushCurrentFriends() {
    List<Friend> result = new List.from(_cachedCurrentFriends);
    _currentFriendsStreamController.add(result);
    return result;
  }

  List<Friend> _pushFriendRequests() {
    List<Friend> result = new List.from(_cachedFriendRequests);
    _friendRequestsStreamController.add(result);
    return result;
  }

  Future<void> _getFriends() {
    return get("/friends").then((response) {
      //TODO: Check status code
      Map<String, dynamic> friendsResponse =
          response.body as Map<String, dynamic>;

      List<dynamic> currentFriendsResponse =
          friendsResponse["current"] as List<dynamic>;
      List<dynamic> friendRequestsResponse =
          friendsResponse["requests"] as List<dynamic>;

      List<Friend> currentFriends = <Friend>[];
      List<Friend> friendRequests = <Friend>[];

      currentFriends.addAll(currentFriendsResponse.map(
          (friendJson) => new Friend.fromJson(friendJson, uidKey: "friend")));
      friendRequests.addAll(friendRequestsResponse.map(
          (friendJson) => new Friend.fromJson(friendJson, uidKey: "owner")));

      this._cachedCurrentFriends = currentFriends;
      this._cachedFriendRequests = friendRequests;

      _currentFriendsChangesStreamController.add(new FriendChange(
        friend: null,
        refresh: true,
      ));
    });
  }

  Future<List<Friend>> getCurrentFriends({cache = true}) async {
    if (!cache || !isCacheValid()) await _getFriends();
    return _pushCurrentFriends();
  }

  Future<List<Friend>> getFriendRequests({cache = true}) async {
    if (!cache || !isCacheValid()) await _getFriends();
    return _pushFriendRequests();
  }

  Future<String> addFriend(String email) async {
    //TODO: issue when adding friend with existing pending request
    return post("/friend", {"email": email}).then((response) {
      switch (response.statusCode) {
        case HttpStatus.OK:
          Friend newFriend = new Friend.fromJson(
            response.body as Map<String, dynamic>,
            uidKey: "friend",
          );
          _cachedCurrentFriends.add(newFriend);
          _pushCurrentFriends();

          _currentFriendsChangesStreamController.add(new FriendChange(
            friend: newFriend,
            refresh: true,
          ));

          return null;
        case HttpStatus.UNAUTHORIZED:
          return "You are already friends!";
        case HttpStatus.NOT_FOUND:
          return "Cannot find user!";
      }
      return "An unexpected error occured.";
    });
  }

  Future<String> acceptFriend(int id) async {
    return post("/friend/accept/$id", {}).then((response) {
      if (response.statusCode == HttpStatus.OK) {
        int i = _cachedFriendRequests.indexWhere((friend) => friend.id == id);
        _cachedFriendRequests[i].state = true;
        Friend friend = _cachedFriendRequests[i];
        _cachedCurrentFriends.add(_cachedFriendRequests[i]);
        _cachedFriendRequests.removeAt(i);
        _pushCurrentFriends();
        _pushFriendRequests();

        _currentFriendsChangesStreamController.add(new FriendChange(
          friend: friend,
          refresh: true,
        ));

        return null;
      } else {
        return "An unexpected error occued.";
      }
    });
  }

  Future<String> rejectFriend(int id) async {
    return post("/friend/reject/$id", {}).then((response) {
      if (response.statusCode == HttpStatus.OK) {
        _cachedFriendRequests.removeWhere((friend) => friend.id == id);
        _pushFriendRequests();
        return null;
      } else {
        return "An unexpected error occued.";
      }
    });
  }

  Future<String> removeFriend(int id) async {
    return delete("/friend/$id").then((response) {
      if (response.statusCode == HttpStatus.OK) {
        Friend toRemove =
            _cachedCurrentFriends.firstWhere((friend) => friend.id == id);
        _cachedCurrentFriends.remove(toRemove);
        _pushCurrentFriends();

        _currentFriendsChangesStreamController
            .add(new FriendChange(friend: toRemove, refresh: false));

        return null;
      } else {
        return "An unexpected error occued.";
      }
    });
  }
}
