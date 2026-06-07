import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/book_service.dart';
import '../../services/user_service.dart';
import '../../widgets/book_cover_image.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_indicator.dart';
import 'widgets/rating_bar.dart';
import 'widgets/review_tile.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _bookService = BookService();
  final _userService = UserService();

  BookModel? _book;
  List<ReviewModel> _reviews = [];
  bool _loading = true;
  bool _expanded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final book = await _bookService.getBook(widget.bookId);
      final reviews = await _bookService.getReviews(widget.bookId);
      if (mounted) {
        setState(() {
          _book = book;
          _reviews = reviews;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null || _book == null) return;
    final add = !auth.user!.isFavorite(_book!.id);
    final updated = await _userService.toggleFavorite(_book!.id, add: add);
    auth.updateUser(updated);
  }

  Future<void> _toggleReadingList() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null || _book == null) return;
    final add = !auth.user!.isInReadingList(_book!.id);
    final updated = await _userService.toggleReadingList(_book!.id, add: add);
    auth.updateUser(updated);
  }

  Future<void> _showReviewSheet() async {
    double rating = 5;
    final commentController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Write a Review', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Slider(
                    value: rating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: rating.round().toString(),
                    onChanged: (v) => setModalState(() => rating = v),
                  );
                },
              ),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Your review...'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _bookService.postReview(
                    bookId: widget.bookId,
                    rating: rating.round(),
                    comment: commentController.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _load();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingIndicator());
    if (_error != null || _book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: _error ?? 'Book not found',
          onRetry: _load,
        ),
      );
    }

    final book = _book!;
    final auth = context.watch<AuthProvider>();
    final isFavorite = auth.user?.isFavorite(book.id) ?? false;
    final inReadingList = auth.user?.isInReadingList(book.id) ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => Share.share('${book.title} - ${book.priceLabel}'),
              ),
              IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: BookCoverImage(
                imageUrl: book.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 280,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  if (book.category.isNotEmpty)
                    Chip(label: Text(book.category)),
                  const SizedBox(height: 8),
                  BookRatingBar(rating: book.rating.toDouble()),
                  Text('${book.numberOfReviews} reviews'),
                  const SizedBox(height: 8),
                  Text(
                    book.priceLabel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: book.inStock
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      book.availability ?? (book.inStock ? 'In Stock' : 'Out of Stock'),
                      style: TextStyle(
                        color: book.inStock ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleReadingList,
                          icon: Icon(inReadingList ? Icons.check : Icons.bookmark_add),
                          label: Text(inReadingList ? 'In Reading List' : 'Add to Reading List'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleFavorite,
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                          label: Text(isFavorite ? 'Favorited' : 'Add to Favorites'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Description', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    book.description ?? 'No description available.',
                    maxLines: _expanded ? null : 3,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                  ),
                  if ((book.description?.length ?? 0) > 120)
                    TextButton(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      child: Text(_expanded ? 'Show less' : 'Read more'),
                    ),
                  const SizedBox(height: 16),
                  Text('Book Details', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _infoRow('UPC', book.upc),
                  _infoRow('Product Type', book.productType),
                  _infoRow('Tax', book.tax?.toString()),
                  _infoRow('Price excl. tax', book.priceExclTax?.toString()),
                  _infoRow('Price incl. tax', book.priceInclTax?.toString()),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
                      TextButton(
                        onPressed: _showReviewSheet,
                        child: const Text('Write a Review'),
                      ),
                    ],
                  ),
                  if (_reviews.isEmpty)
                    const EmptyStateWidget(message: 'No reviews yet')
                  else
                    ..._reviews.map((r) => ReviewTile(review: r)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
