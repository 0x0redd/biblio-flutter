import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/book_model.dart';
import '../../../widgets/book_cover_image.dart';

class FeaturedBanner extends StatefulWidget {
  const FeaturedBanner({super.key, required this.books});

  final List<BookModel> books;

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.books.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted || widget.books.isEmpty) return;
        _index = (_index + 1) % widget.books.length;
        _controller.animateToPage(
          _index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.books.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final book = widget.books[i];
              return GestureDetector(
                onTap: () => context.push('/book/${book.id}'),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.primary,
                  ),
                  child: Row(
                    children: [
                      BookCoverImage(
                        imageUrl: book.imageUrl,
                        width: 100,
                        height: 160,
                        fit: BoxFit.cover,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Featured',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              Text(
                                book.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                book.priceLabel,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.books.length.clamp(0, 10),
            (i) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _index == i ? AppColors.primary : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
