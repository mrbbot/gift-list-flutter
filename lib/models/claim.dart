import 'package:flutter/foundation.dart';
import 'package:gift_list/models/user.dart';

class Claim {
  int state;
  User user;

  Claim({@required this.state, this.user});

  factory Claim.fromJson(Map<String, dynamic> json) {
    return new Claim(
        state: json["state"] as int,
        user: new User.fromJson(
          json,
          uidKey: "user",
        ));
  }

  @override
  String toString() {
    return "{Claim: state: $state, user: $user}";
  }
}
