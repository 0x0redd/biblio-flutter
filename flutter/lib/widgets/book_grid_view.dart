import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../screens/home/widgets/book_card.dart';
import 'shimmer_book_card.dart';

class BookGridView extends StatelessWidget {
  const BookGridView({
    super.key,
    required this.books,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.scrollController,
  });

  final List<BookModel> books;
  final bool isLoading;
  final bool isLoadingMore;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    if (isLoading && books.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.58,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const ShimmerBookCard(),
      );
    }

    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.58,
      ),
      itemCount: books.length + (isLoadingMore ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= books.length) {
          return const ShimmerBookCard();
        }
        return BookCard(book: books[index]);
      },
    );
  }
}
