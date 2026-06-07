import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/books_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/shimmer_book_card.dart';
import 'widgets/book_card.dart';
import 'widgets/category_chips.dart';
import 'widgets/featured_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadInitial();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BooksProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final books = context.watch<BooksProvider>();
    final hour = DateTime.now().hour;
    final name = auth.user?.name.split(' ').first ?? 'Reader';

    if (books.error != null && books.books.isEmpty) {
      return AppErrorWidget(
        message: books.error!,
        onRetry: books.loadInitial,
      );
    }

    return RefreshIndicator(
      onRefresh: books.refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('${greetingForHour(hour)}, $name'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SearchBar(
                hintText: 'Search books...',
                leading: const Icon(Icons.search),
                onTap: () => context.go('/search'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FeaturedBanner(books: books.featuredBooks),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: CategoryChips(
              categories: books.categories,
              selected: books.selectedCategory,
              onSelected: books.selectCategory,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'All Books',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          if (books.isLoading && books.books.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const ShimmerBookCard(),
                  childCount: 6,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= books.books.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return BookCard(book: books.books[index]);
                  },
                  childCount:
                      books.books.length + (books.isLoadingMore ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
