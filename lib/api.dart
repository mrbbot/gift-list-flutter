import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'list.dart';
import 'friends.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const API_URL = "https://mrbbot.co.uk:7687";
final _auth = FirebaseAuth.instance;

class _UserRecord {
  String uid, name, photo;

  _UserRecord(this.uid, this.name, this.photo);
}

Future<String> _getIdToken() async {
  FirebaseUser user = await _auth.currentUser();
  return await user.getIdToken(refresh: false);
}

Future<FirebaseUser> getCurrentUser() {
  return _auth.currentUser();
}

Future<_UserRecord> _getUserFromUid(String uid, List<Friend> friends) async {
  FirebaseUser currentUser = await getCurrentUser();
  if (currentUser.uid == uid)
    return new _UserRecord(uid, 'Me', currentUser.photoUrl);

  for (Friend friend in friends) {
    if (friend.uid == uid)
      return new _UserRecord(uid, friend.name, friend.photo);
  }

  return new _UserRecord(
      uid, "Unknown", "http://via.placeholder.com/128?text=?");
}

Future<dynamic> _get(String route) async {
  final res = await http.get(API_URL + route,
      headers: {"Authorization": await _getIdToken()});
  print("GET $route: ${res.body}");
  return json.decode(res.body);
}

Future<dynamic> _post(String route, Map<String, dynamic> data) async {
  final res = await http.post(API_URL + route,
      headers: {
        "Authorization": await _getIdToken(),
        HttpHeaders.CONTENT_TYPE: "application/json"
      },
      body: json.encode(data));
  print("POST $route: ${res.body}");
  return json.decode(res.body);
}

Future<dynamic> _delete(String route) async {
  final res = await http.delete(API_URL + route,
      headers: {"Authorization": await _getIdToken()});
  print("DELETE $route: ${res.body}");
  return json.decode(res.body);
}

Future<List<Friend>> getFriends() async {
  print("Getting friends...");

  Map res = await _get("/friends");

  List<Friend> friends = <Friend>[];

  Iterable current = res["current"];
  current.forEach((json) =>
      friends.add(new Friend.fromJson(json,
          isRequest: false, sentRequest: !json["state"])));

  Iterable requests = res["requests"];
  requests.forEach((json) =>
      friends
          .add(new Friend.fromJson(json, isRequest: true, sentRequest: false)));

  return friends;
}

Future<List<GiftList>> getLists(String uid, List<Friend> friends) async {
  Iterable res = await _get("/lists/$uid");
  List<GiftList> lists = <GiftList>[];
  FirebaseUser currentUser = await getCurrentUser();
  for (dynamic json in res) {
    _UserRecord record = await _getUserFromUid(json["owner"], friends);
    lists.add(new GiftList.fromJson(
      json,
      ownerName: record.name,
      ownerPhoto: record.photo,
      isFriends: currentUser.uid != record.uid,
      currentUid: currentUser.uid,
    ));
  }
  return lists;
}