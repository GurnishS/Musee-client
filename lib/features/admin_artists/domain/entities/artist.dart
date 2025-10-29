class Artist {
  // Core identifiers
  final String id; // artist_id

  // Artist profile fields
  final String bio;
  final String? coverUrl;
  final List<String> genres;
  final int? debutYear;
  final bool isVerified;
  final Map<String, dynamic>? socialLinks;
  final int monthlyListeners;
  final String? regionId;
  final DateTime? dateOfBirth; // date-only

  // Audit
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Linked user snapshot (convenience for admin UI)
  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? userAvatarUrl;

  const Artist({
    required this.id,
    required this.bio,
    this.coverUrl,
    this.genres = const [],
    this.debutYear,
    this.isVerified = false,
    this.socialLinks,
    this.monthlyListeners = 0,
    this.regionId,
    this.dateOfBirth,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.userName,
    this.userEmail,
    this.userAvatarUrl,
  });

  // Backwards compatibility getters for existing UI
  String get name => userName ?? '';
  String? get avatarUrl => userAvatarUrl;

  Artist copyWith({
    String? id,
    String? bio,
    String? coverUrl,
    List<String>? genres,
    int? debutYear,
    bool? isVerified,
    Map<String, dynamic>? socialLinks,
    int? monthlyListeners,
    String? regionId,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? userName,
    String? userEmail,
    String? userAvatarUrl,
  }) {
    return Artist(
      id: id ?? this.id,
      bio: bio ?? this.bio,
      coverUrl: coverUrl ?? this.coverUrl,
      genres: genres ?? this.genres,
      debutYear: debutYear ?? this.debutYear,
      isVerified: isVerified ?? this.isVerified,
      socialLinks: socialLinks ?? this.socialLinks,
      monthlyListeners: monthlyListeners ?? this.monthlyListeners,
      regionId: regionId ?? this.regionId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
    );
  }
}
