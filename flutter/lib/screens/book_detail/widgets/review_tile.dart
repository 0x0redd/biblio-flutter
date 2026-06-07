import 'package:flutter/material.dart';

import '../../../models/review_model.dart';
import 'rating_bar.dart';

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final name = review.user?.name ?? 'Anonymous';
    final date = review.createdAt.toLocal().toString().split(' ').first;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(name.isNotEmpty ? name[0] : '?')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(date, style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                BookRatingBar(rating: review.rating.toDouble(), size: 14, showValue: false),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
          ],
        ),
      ),
    );
  }
}
