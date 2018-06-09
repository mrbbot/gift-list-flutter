import 'package:flutter/foundation.dart';
import 'package:gift_list/models/claim.dart';
import 'package:gift_list/services/auth_service.dart';

final AuthService _authService = AuthService.instance;

class Gift {
  int id;
  String name;
  String description;
  String url;
  String imageUrl;
  Claim claim;

  Gift({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.url,
    @required this.imageUrl,
    @required this.claim,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return new Gift(
        id: json["id"] as int,
        name: json["name"] as String,
        description: json["description"] as String,
        url: json["url"] as String,
        imageUrl: json["imageUrl"] as String,
        claim: Claim.fromJson(json["claim"] as Map<String, dynamic>));
  }

  String get claimedBy => claim.user.uid == _authService.cachedCurrentUser.uid
      ? "Me"
      : claim.user.firstName;

  bool get claimed => claim.state != 0;

  bool get canClaim =>
      !claimed || claim.user.uid == _authService.cachedCurrentUser.uid;

  @override
  String toString() {
    return "{Gfit: id: $id, name: $name, description: $description, url: $url, claim: $claim}";
  }
}
