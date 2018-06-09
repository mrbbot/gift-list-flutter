import 'package:flutter/foundation.dart';
import 'package:gift_list/models/user.dart';

class Friend {
  int id;
  User user;
  bool state;

  Friend({
    @required this.id,
    this.user,
    @required this.state,
  });

  factory Friend.fromJson(Map<String, dynamic> json,
      {@required String uidKey}) {
    return new Friend(
        id: json["id"] as int,
        user: new User.fromJson(json, uidKey: uidKey),
        state: json["state"] as bool);
  }

  @override
  String toString() {
    return "{Friend: id: $id, user: $user, state: $state}";
  }
}
