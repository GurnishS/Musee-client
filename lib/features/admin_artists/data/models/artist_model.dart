import 'dart:convert';
import '../../domain/entities/artist.dart';

class ArtistModel extends Artist {
  const ArtistModel({
    required super.id,
    required super.bio,
    super.coverUrl,
    super.genres = const [],
    super.debutYear,
    super.isVerified = false,
    super.socialLinks,
    super.monthlyListeners = 0,
    super.regionId,
    super.dateOfBirth,
    super.createdAt,
    super.updatedAt,
    super.userId,
    super.userName,
    super.userEmail,
    super.userAvatarUrl,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    final users = json['users'] as Map<String, dynamic>?;
    return ArtistModel(
      id: (json['artist_id'] ?? json['id'] ?? '') as String,
      bio: (json['bio'] ?? '') as String,
      coverUrl: json['cover_url'] as String?,
      genres:
          (json['genres'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      debutYear: json['debut_year'] as int?,
      isVerified: (json['is_verified'] as bool?) ?? false,
      socialLinks: json['social_links'] is Map<String, dynamic>
          ? (json['social_links'] as Map<String, dynamic>)
          : (json['social_links'] is String &&
                    (json['social_links'] as String).isNotEmpty
                ? jsonDecode(json['social_links'] as String)
                      as Map<String, dynamic>
                : null),
      monthlyListeners: (json['monthly_listeners'] as int?) ?? 0,
      regionId: json['region_id'] as String?,
      dateOfBirth:
          json['date_of_birth'] != null &&
              (json['date_of_birth'] as String).isNotEmpty
          ? DateTime.tryParse((json['date_of_birth'] as String))
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      userId: users != null ? users['user_id'] as String? : null,
      userName: users != null ? users['name'] as String? : null,
      userEmail: users != null ? users['email'] as String? : null,
      userAvatarUrl: users != null ? users['avatar_url'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artist_id': id,
      'bio': bio,
      'cover_url': coverUrl,
      'genres': genres,
      'debut_year': debutYear,
      'is_verified': isVerified,
      'social_links': socialLinks,
      'monthly_listeners': monthlyListeners,
      'region_id': regionId,
      'date_of_birth': dateOfBirth != null ? _dateOnly(dateOfBirth!) : null,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'users': {
        'user_id': userId,
        'name': userName,
        'email': userEmail,
        'avatar_url': userAvatarUrl,
      },
    }..removeWhere((k, v) => v == null);
  }
}

String _dateOnly(DateTime dt) => dt.toIso8601String().split('T').first;
