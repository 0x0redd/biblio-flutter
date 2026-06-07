class UserSettings {
  const UserSettings({
    this.theme = 'system',
    this.language = 'en',
    this.notificationsEnabled = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      theme: json['theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
    );
  }

  final String theme;
  final String language;
  final bool notificationsEnabled;

  Map<String, dynamic> toJson() => {
        'theme': theme,
        'language': language,
        'notifications_enabled': notificationsEnabled,
      };

  UserSettings copyWith({
    String? theme,
    String? language,
    bool? notificationsEnabled,
  }) {
    return UserSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.role = 'user',
    this.favorites = const [],
    this.readingList = const [],
    this.settings = const UserSettings(),
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
      favorites: (json['favorites'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      readingList: (json['reading_list'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : const UserSettings(),
    );
  }

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String role;
  final List<String> favorites;
  final List<String> readingList;
  final UserSettings settings;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
        'role': role,
        'favorites': favorites,
        'reading_list': readingList,
        'settings': settings.toJson(),
      };

  UserModel copyWith({
    String? name,
    String? avatarUrl,
    List<String>? favorites,
    List<String>? readingList,
    UserSettings? settings,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      favorites: favorites ?? this.favorites,
      readingList: readingList ?? this.readingList,
      settings: settings ?? this.settings,
    );
  }

  bool isFavorite(String bookId) => favorites.contains(bookId);
  bool isInReadingList(String bookId) => readingList.contains(bookId);
}
