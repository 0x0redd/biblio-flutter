import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../core/constants/app_colors.dart';

class BookRatingBar extends StatelessWidget {
  const BookRatingBar({
    super.key,
    required this.rating,
    this.size = 20,
    this.showValue = true,
  });

  final double rating;
  final double size;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (_, __) =>
              const Icon(Icons.star, color: AppColors.secondary),
          itemCount: 5,
          itemSize: size,
        ),
        if (showValue) ...[
          const SizedBox(width: 8),
          Text(rating.toStringAsFixed(1)),
        ],
      ],
    );
  }
}
