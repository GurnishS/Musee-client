import 'package:musee/core/common/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String name,
    String? email,
    SubscriptionType subscriptionType = SubscriptionType.free,
    String? planId,
    String avatarUrl =
        'https://xvpputhovrhgowfkjhfv.supabase.co/storage/v1/object/public/avatars/users/default_avatar.png',
    List<String>? playlists,
    Map<String, dynamic>? favorites,
    int followersCount = 0,
    int followingsCount = 0,
    DateTime? lastLoginAt,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserType userType = UserType.listener,
  }) : super(
         id: id,
         name: name,
         email: email,
         subscriptionType: subscriptionType,
         planId: planId,
         avatarUrl: avatarUrl,
         playlists: playlists,
         favorites: favorites,
         followersCount: followersCount,
         followingsCount: followingsCount,
         lastLoginAt: lastLoginAt,
         settings: settings,
         createdAt: createdAt,
         updatedAt: updatedAt,
         userType: userType,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final base = User.fromJson(json);
    return UserModel(
      id: base.id,
      name: base.name,
      email: base.email,
      subscriptionType: base.subscriptionType,
      planId: base.planId,
      avatarUrl: base.avatarUrl,
      playlists: List<String>.from(base.playlists),
      favorites: Map<String, dynamic>.from(base.favorites),
      followersCount: base.followersCount,
      followingsCount: base.followingsCount,
      lastLoginAt: base.lastLoginAt,
      settings: Map<String, dynamic>.from(base.settings),
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
      userType: base.userType,
    );
  }

  Map<String, dynamic> toJson() => super.toJson();

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    SubscriptionType? subscriptionType,
    String? planId,
    String? avatarUrl,
    List<String>? playlists,
    Map<String, dynamic>? favorites,
    int? followersCount,
    int? followingsCount,
    DateTime? lastLoginAt,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserType? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      planId: planId ?? this.planId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      playlists: playlists ?? List<String>.from(this.playlists),
      favorites: favorites ?? Map<String, dynamic>.from(this.favorites),
      followersCount: followersCount ?? this.followersCount,
      followingsCount: followingsCount ?? this.followingsCount,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      settings: settings ?? Map<String, dynamic>.from(this.settings),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userType: userType ?? this.userType,
    );
  }
}
