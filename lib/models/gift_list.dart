import 'package:flutter/foundation.dart';
import 'package:gift_list/models/friend.dart';
import 'package:gift_list/models/gift.dart';
import 'package:gift_list/services/auth_service.dart';

final AuthService _authService = AuthService.instance;

class GiftList {
  int id;
  String name;
  Friend friend;
  String description;
  List<Gift> gifts;

  GiftList({
    @required this.id,
    @required this.name,
    @required this.friend,
    @required this.description,
    @required this.gifts,
  });

  factory GiftList.fromJson(Map<String, dynamic> json, {Friend friend}) {
    return new GiftList(
        id: json["id"] as int,
        name: json["name"] as String,
        friend: friend,
        description: json["description"] as String,
        gifts: (json["gifts"] as List<dynamic>)
            .map((giftJson) =>
                new Gift.fromJson(giftJson as Map<String, dynamic>))
            .toList());
  }

  int get claimedGifts {
    int count = 0;
    gifts.forEach((gift) {
      if (gift.claim.state == 1) count++;
    });
    return count;
  }

  double get claimedPercent {
    return claimedGifts / gifts.length;
  }

  bool get hasClaim =>
      gifts.indexWhere((gift) =>
          gift.claim.user.uid == _authService.cachedCurrentUser?.uid) !=
      -1;

  List<String> get images => gifts
      .where((gift) => gift.imageUrl != null && gift.imageUrl != "")
      .map((gift) => gift.imageUrl)
      .toList();

  bool get currentUsers => friend == null;

  @override
  String toString() {
    return "{GiftList: id: $id, name: $name, friend: $friend, description: $description, gifts: $gifts}";
  }
}
