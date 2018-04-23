import 'package:flutter/material.dart';
import 'me.dart';
import 'friends.dart';
import 'list.dart';
import 'logo.dart';
import 'api.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();
final FacebookLogin _facebookSignIn = new FacebookLogin();

void main() {
  runApp(new GiftListApp());
}

class GiftListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Gift List',
      theme: new ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: new MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  AnimationController _animationController;
  int _page = 1;
  FirebaseUser _user;
  bool _loaded;
  double _listLoadProgress;

  /*List<GiftList> _myLists = <GiftList>[
    new GiftList(
      ownerName: 'Brendan Coll',
      listName: 'Birthday',
      progress: 0.33,
      items: <Gift>[
        new Gift("Computer", '', false),
        new Gift("Big Man", 'Kate', false),
        new Gift("Something", '', false),
      ],
      isFriends: false,
    ),
    new GiftList(
      ownerName: 'Brendan Coll',
      listName: 'Christmas',
      progress: 0.0,
      items: <Gift>[],
      isFriends: false,
    ),
  ];

  List<Friend> _friends = <Friend>[
    new Friend(
        id: 25,
        name: "Rose Coll",
        email: "rose@email.com",
        photo: "https://lh5.googleusercontent.com/-mOX5jEmh7Hc/AAAAAAAAAAI/AAAAAAAAABU/HBgCiaEU2Ww/photo.jpg",
        */ /*lists: <GiftList>[
          new GiftList(
            ownerName: 'Rose Coll',
            listName: 'Birthday',
            progress: 0.5,
            items: <Gift>[
              new Gift("Horse", '', true),
              new Gift("Gloves", 'Tony', true),
              new Gift(
                  "Something really really long that will probably overflow",
                  'Me',
                  true),
            ],
            isFriends: true,
          ),
        ],*/ /*
        isRequest: true,
        sentRequest: false),
    new Friend(
        name: "Brendan Coll",
        email: "brendan@email.com",
        */ /*lists: <GiftList>[
          new GiftList(
            ownerName: 'Brendan Coll',
            listName: 'Christmas',
            progress: 0.0,
            items: <Gift>[],
            isFriends: true,
          ),
          new GiftList(
            ownerName: 'Brendan Coll',
            listName: 'Birthday',
            progress: 0.33,
            items: <Gift>[
              new Gift("Computer", '', true),
              new Gift("Big Man", 'Kate', true),
              new Gift("Something", '', true),
            ],
            isFriends: true,
          ),
        ],*/ /*
        isRequest: false,
        sentRequest: false)
  ];

  List<GiftList> _friendsLists = <GiftList>[];*/

  /*void _updateFriendsLists() {
    _friendsLists.clear();
    _friends.forEach((friend) => _friendsLists.addAll(friend.lists));
    _friendsLists.sort((a, b) => ((a.progress - b.progress) * 100).round());
  }*/

  List<Friend> _friends;
  List<GiftList> _friendsLists;
  List<GiftList> _myLists;

  void loadMe() async {
    List<GiftList> myLists =
        await getLists((await getCurrentUser()).uid, _friends);
    setState(() => _myLists = myLists);
  }

  void loadUserData() async {
    List<Friend> friends = await getFriends();
    setState(() => _friends = friends);
    loadMe();
    List<GiftList> friendsLists = <GiftList>[];
    Iterable<Friend> friendsWithLists = friends.where((friend) => !friend.isRequest && !friend.sentRequest);
    int i = 0;
    for(Friend friend in friendsWithLists) {
      friendsLists.addAll(await getLists(friend.uid, friends));
      i++;
      setState(() => _listLoadProgress = i / friendsWithLists.length);
    }
    friendsLists.sort((a, b) => ((a.progress - b.progress) * 100).round());
    setState(() => _friendsLists = friendsLists);
  }

  void resetUserData() {
    setState(() {
      _friends = null;
      _friendsLists = null;
      _myLists = null;
      _listLoadProgress = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        duration: const Duration(seconds: 2), vsync: this)
      ..repeat();
    _pageController = new PageController(
      initialPage: _page,
    );
    //_updateFriendsLists();
    _loaded = false;
    _auth.onAuthStateChanged.forEach((user) {
      (user != null ? loadUserData : resetUserData)();
      setState(() {
        _user = user;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void onNavigationTap(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  Widget _buildLoadingPage([double value]) {
    return new Center(
      child: new CircularProgressIndicator(value: value),
    );
  }

  Widget _buildLoginButton(String name, VoidCallback onPressed) {
    return new Container(
      margin: new EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: new RaisedButton(
        color: Colors.white,
        onPressed: onPressed,
        child: new Row(
          children: <Widget>[
            new Image(
              image: new AssetImage("assets/${name.toLowerCase()}.png"),
              width: 24.0,
              height: 24.0,
            ),
            new Expanded(
              child:
                  new Text("Sign in with $name", textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return new Scaffold(
      body: new Container(
        margin: const EdgeInsets.only(top: 24.0),
        child: new Center(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Logo(
                animation: _animationController,
              ),
              _buildLoginButton("Google", () async {
                GoogleSignInAccount googleUser = await _googleSignIn.signIn();
                GoogleSignInAuthentication googleAuth =
                    await googleUser.authentication;
                _auth.signInWithGoogle(
                  accessToken: googleAuth.accessToken,
                  idToken: googleAuth.idToken,
                );
              }),
              _buildLoginButton("Facebook", () async {
                FacebookLoginResult result =
                    await _facebookSignIn.logInWithReadPermissions(['email']);
                if (result.status == FacebookLoginStatus.loggedIn) {
                  _auth.signInWithFacebook(
                      accessToken: result.accessToken.token);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMain() {
    final ThemeData appBarTheme =
        Theme.of(context).copyWith(brightness: Brightness.light);
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.white,
        textTheme: appBarTheme.textTheme,
        iconTheme: appBarTheme.iconTheme,
        title: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Image(
              image: new AssetImage("assets/logo.png"),
              width: 24.0,
              height: 24.0,
            ),
          ],
        ),
        actions: <Widget>[
          new PopupMenuButton(
            onSelected: (item) => _auth.signOut(),
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem>[
                new PopupMenuItem(
                  value: "Sign out",
                  child: new Text("Sign out"),
                ),
              ];
            },
          )
        ],
      ),
      body: new PageView(
        children: <Widget>[
          _myLists != null ? new MyLists(_myLists) : _buildLoadingPage(),
          _friendsLists != null
              ? new FriendsLists(_friendsLists)
              : _buildLoadingPage(_listLoadProgress),
          _friends != null ? new FriendsList(_friends) : _buildLoadingPage(),
        ],
        controller: _pageController,
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: new BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
            icon: new Icon(Icons.add),
            title: new Text("My Lists"),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.cake),
            title: new Text("Friends' Lists"),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.people),
            title: new Text("My Friends"),
          )
        ],
        onTap: onNavigationTap,
        currentIndex: _page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loaded
        ? (_user != null ? _buildMain() : _buildLogin())
        : _buildLoadingPage();
  }
}
