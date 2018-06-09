import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class User {
  static User nullUser =
      new User(uid: null, name: null, email: null, photo: null);

  String uid;
  String name;
  String email;
  String photo;

  User({
    @required this.uid,
    @required this.name,
    @required this.email,
    @required this.photo,
  });

  factory User.fromJson(Map<String, dynamic> json, {String uidKey}) {
    return new User(
      uid: uidKey != null ? json[uidKey] as String : null,
      email: json["email"] as String,
      name: json["name"] as String,
      photo: json["photo"] as String,
    );
  }

  factory User.fromFirebaseUser(FirebaseUser user) {
    return new User(
        uid: user.uid,
        email: user.email,
        name: user.displayName,
        photo: user.photoUrl);
  }

  String get firstName => name.split(" ")[0];

  @override
  String toString() {
    return "{User: uid: $uid, name: $name, email: $email}";
  }
}
