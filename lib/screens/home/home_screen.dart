import 'package:flutter/material.dart';
import 'package:gift_list/components/dialog.dart';
import 'package:gift_list/components/empty_state.dart';
import 'package:gift_list/models/friend.dart';
import 'package:gift_list/models/gift.dart';
import 'package:gift_list/models/gift_list.dart';
import 'package:gift_list/screens/list/list_screen.dart';
import 'package:gift_list/screens/home/pages/friends_lists/friends_lists.dart';
import 'package:gift_list/screens/home/pages/manage_friends/add_friend_dialog.dart';
import 'package:gift_list/screens/home/pages/manage_friends/manage_friends.dart';
import 'package:gift_list/screens/home/pages/my_lists/my_lists.dart';
import 'package:gift_list/services/friends_service.dart';
import 'package:gift_list/services/lists_service.dart';

final FriendsService _friendsService = FriendsService.instance;
final ListsService _listsService = ListsService.instance;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _page = 1;
  PageController _pageController;

  AnimationController _requestsBadgeAnimationController;
  Animation<double> _requestsBadgeAnimation;

  List<GiftList> _myLists = <GiftList>[];

  List<GiftList> _friendsLists = <GiftList>[];

  List<Friend> _currentFriends = <Friend>[];
  List<Friend> _friendRequests = <Friend>[];

  @override
  void initState() {
    super.initState();
    _pageController = new PageController(initialPage: _page);
    _requestsBadgeAnimationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: _page != 2 ? 1.0 : 0.0,
    );
    _requestsBadgeAnimation = new CurvedAnimation(
      parent: _requestsBadgeAnimationController,
      curve: Curves.easeInOut,
    )..addListener(() {
        setState(() {});
      });

    if (_friendsService.isCacheValid()) {
      _friendsService.currentFriendsStream.forEach((currentFriends) {
        setState(() {
          this._currentFriends = currentFriends;
        });
      });

      _friendsService.friendRequestsStream.forEach((friendRequests) {
        setState(() {
          this._friendRequests = friendRequests;
        });
      });

      _friendsService.getCurrentFriends();
      _friendsService.getFriendRequests();

      if (_listsService.isFriendsListsCacheValid()) {
        _listsService.friendsListsStream.forEach((friendsLists) {
          setState(() {
            this._friendsLists = friendsLists;
          });

          _listsService.listenToFriendsStreamChanges();
        });

        _listsService.getFriendsLists();
      }

      if (_listsService.isMyListsCacheValid()) {
        _listsService.myListsStream.forEach((myLists) {
          setState(() {
            this._myLists = myLists;
          });
        });

        _listsService.getMyLists();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _requestsBadgeAnimationController.dispose();
    super.dispose();
  }

  void onNavigationTap(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onPageChanged(int page) {
    if (page == 2)
      _requestsBadgeAnimationController.reverse();
    else
      _requestsBadgeAnimationController.forward();
    setState(() => this._page = page);
  }

  Widget _buildMyListsPage() {
    return new MyListsPage(
      myLists: _myLists,
      onRefresh: () async {
        await _listsService.getMyLists(cache: false);
        return null;
      },
      onClick: (int id) {
        Navigator
            .of(context)
            .push(new MaterialPageRoute(builder: (BuildContext context) {
          return new ListScreen(
            list: _myLists.firstWhere((list) => list.id == id),
            onRefresh: () async {
              await _listsService.getMyLists(cache: false);
              return null;
            },
            onEdit: (int listId, String name, String description) async {
              await _listsService.editList(listId, name, description);
              return null;
            },
          );
        }));
      },
      onRemove: (int id) async {
        print("Remove List: $id");
        String error = await _listsService.removeList(id);
        if (error != null) showMessageDialog(context, "Error", error);
      },
    );
  }

  Widget _buildFriendsListsPage() {
    return new FriendsListsPage(
      friendsLists: _friendsLists,
      onRefresh: () async {
        await for (int _ in _listsService.getFriendsLists(cache: false)) {}
        return null;
      },
      onClick: (id) {
        Navigator
            .of(context)
            .push(new MaterialPageRoute(builder: (BuildContext context) {
          return new ListScreen(
            list: _friendsLists.firstWhere((list) => list.id == id),
            onRefresh: () async {
              //Technically updates all of the friend's lists but meh, would
              //require backend changes to fix
              await _listsService.refreshFriendsLists(
                  _friendsLists.firstWhere((list) => list.id == id).friend,
                  true);
              return null;
            },
            onClaim: (int listId, int giftId) async {
              print("Claim $giftId on $listId");
              String error = await _listsService.claimGift(listId, giftId, 1);
              if (error != null) showMessageDialog(context, "Error", error);
            },
            onRemoveClaim: (int listId, int giftId) async {
              print("Remove claim for $giftId on $listId");
              String error = await _listsService.claimGift(listId, giftId, 0);
              if (error != null) showMessageDialog(context, "Error", error);
            },
          );
        }));
      },
    );
  }

  Widget _buildManageFriendsPage() {
    return new ManageFriendsPage(
      currentFriends: _currentFriends,
      friendRequests: _friendRequests,
      onRefresh: () async {
        await _friendsService.getCurrentFriends(cache: false);
        await _friendsService.getFriendRequests();
        return null;
      },
      onRemove: (int id) async {
        print("Remove Friend: $id");
        String error = await _friendsService.removeFriend(id);
        if (error != null) showMessageDialog(context, "Error", error);
      },
      onAccept: (int id) async {
        print("Accept Friend: $id");
        String error = await _friendsService.acceptFriend(id);
        if (error != null) showMessageDialog(context, "Error", error);
      },
      onReject: (int id) async {
        print("Reject Friend: $id");
        String error = await _friendsService.rejectFriend(id);
        if (error != null) showMessageDialog(context, "Error", error);
      },
    );
  }

  Widget _buildPageView() {
    return new PageView(
      children: <Widget>[
        _myLists.length > 0
            ? _buildMyListsPage()
            : new EmptyState(
                icon: Icons.layers_clear,
                message:
                    "You don't have any lists! Add some so friends know what you want!",
              ),
        _friendsLists.length > 0
            ? _buildFriendsListsPage()
            : new EmptyState(
                icon: Icons.cake,
                message:
                    "You don't have any lists that you can claim from! Add some more friends so you can start sharing ideas!",
              ),
        (_currentFriends.length + _friendRequests.length) > 0
            ? _buildManageFriendsPage()
            : new EmptyState(
                icon: Icons.person_outline,
                message:
                    "It seems you don't have any friends! Send a request to start seeing other peoples' lists!",
              ),
      ],
      controller: _pageController,
      onPageChanged: onPageChanged,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    List<Widget> manageFriendsItemStackChildren = <Widget>[
      new Icon(Icons.people),
    ];
    if (_friendRequests.length > 0) {
      manageFriendsItemStackChildren.add(
        new Positioned(
          top: 0.0,
          right: 0.0,
          child: new Transform.scale(
            scale: _requestsBadgeAnimation.value,
            child: new Stack(
              children: <Widget>[
                new Icon(
                  Icons.brightness_1,
                  size: 12.0,
                  color: Theme.of(context).primaryColor,
                ),
                new Positioned(
                  top: 2.0,
                  right: 3.0,
                  child: new Text(
                    (_friendRequests.length > 9 ? "+" : _friendRequests.length)
                        .toString(),
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 8.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return new BottomNavigationBar(
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
          icon: new Stack(
            children: manageFriendsItemStackChildren,
          ),
          title: new Text("My Friends"),
        )
      ],
      onTap: onNavigationTap,
      currentIndex: _page,
    );
  }

  Widget _buildFloatingActionButton() {
    return _page == 0
        ? new FloatingActionButton(
            onPressed: () {
              Navigator
                  .of(context)
                  .push(new MaterialPageRoute(builder: (BuildContext context) {
                return new ListScreen(
                  list: new GiftList(
                    id: null,
                    name: "",
                    friend: null,
                    description: "",
                    gifts: <Gift>[],
                  ),
                  onRefresh: () {},
                );
              }));
            },
            tooltip: "Add List",
            child: new Icon(Icons.add),
          )
        : (_page == 2
            ? new FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return new AddFriendDialog(
                          addFriendCallback: (String email) async {
                            print("Add Friend: $email");
                            return await _friendsService.addFriend(email);
                          },
                        );
                      });
                },
                tooltip: "Add Friend",
                child: new Icon(Icons.person_add),
              )
            : null);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Gift List"),
      ),
      body: _buildPageView(),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
