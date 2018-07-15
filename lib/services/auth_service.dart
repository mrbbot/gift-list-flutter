import 'dart:async';

import 'package:gift_list/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef Future<FirebaseUser> UserSignInHandler();

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();
final FacebookLogin _facebookSignIn = new FacebookLogin();

class AuthService {
  static AuthService instance = new AuthService._();

  User _cachedUser;

  AuthService._() {
    _auth.onAuthStateChanged.forEach((user) {
      if(user != null) {
        print("Setting cached user to ${user.email}");
        _cachedUser = new User.fromFirebaseUser(user);
      } else {
        _cachedUser = null;
      }
    });
  }

  Future<FirebaseUser> signInWithGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    return _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  Future<FirebaseUser> signInWithFacebook() {
    Completer<FirebaseUser> completer = new Completer();

    _facebookSignIn.logInWithReadPermissions(['email']).then((result) {
      if (result.status == FacebookLoginStatus.loggedIn) {
        _auth
            .signInWithFacebook(accessToken: result.accessToken.token)
            .then((user) => completer.complete(user));
      } else {
        completer.complete(null);
      }
    });

    return completer.future;
  }

  User get cachedCurrentUser => _cachedUser;

  Future<FirebaseUser> currentUser() => _auth.currentUser();

  String _currentIdToken;
  DateTime _idTokenCreationTime;

  Future<String> idToken() async {
    DateTime now = new DateTime.now();
    if (_currentIdToken != null &&
        _idTokenCreationTime != null &&
        now.difference(_idTokenCreationTime).inMinutes < 50) {
      print("Using existing ID token...");
      return _currentIdToken;
    } else {
      print("Generating new ID token...");
      String newToken =
          await currentUser().then((user) => user.getIdToken(refresh: true));
      _currentIdToken = newToken;
      _idTokenCreationTime = now;
      return newToken;
    }
  }

  Future<void> signOut() => _auth.signOut();
}
