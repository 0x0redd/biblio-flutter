class ReviewUserModel {
  const ReviewUserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) {
    return ReviewUserModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  final String id;
  final String name;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar_url': avatarUrl,
      };
}

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int? ?? 1,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      user: json['user'] != null
          ? ReviewUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final String bookId;
  final String userId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final ReviewUserModel? user;

  Map<String, dynamic> toJson() => {
        'id': id,
        'book_id': bookId,
        'user_id': userId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
        'user': user?.toJson(),
      };
}
