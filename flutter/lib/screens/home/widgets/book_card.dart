import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/book_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/user_service.dart';
import '../../../widgets/book_cover_image.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    this.onFavoriteToggle,
  });

  final BookModel book;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isFavorite = auth.user?.isFavorite(book.id) ?? false;

    return InkWell(
      onTap: () => context.push('/book/${book.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              children: [
                BookCoverImage(
                  imageUrl: book.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(12),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.error : Colors.white,
                    ),
                    onPressed: onFavoriteToggle ?? () => _toggleFavorite(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            book.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          if (book.category.isNotEmpty)
            Chip(
              label: Text(book.category, style: const TextStyle(fontSize: 10)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
          RatingBarIndicator(
            rating: book.rating.toDouble(),
            itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.secondary),
            itemCount: 5,
            itemSize: 14,
          ),
          Text(
            book.priceLabel,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;
    final add = !auth.user!.isFavorite(book.id);
    final userService = UserService();
    final updated = await userService.toggleFavorite(book.id, add: add);
    auth.updateUser(updated);
  }
}
