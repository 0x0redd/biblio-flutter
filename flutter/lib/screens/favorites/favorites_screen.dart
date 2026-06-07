import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/book_model.dart';
import '../../services/user_service.dart';
import '../../widgets/book_grid_view.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_indicator.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _userService = UserService();
  List<BookModel> _books = [];
  bool _loading = true;
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
      final books = await _userService.getFavoriteBooks();
      if (mounted) {
        setState(() {
          _books = books;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: _loading
          ? const LoadingIndicator()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : _books.isEmpty
                  ? EmptyStateWidget(
                      message: 'No favorites yet',
                      actionLabel: 'Browse books',
                      onAction: () => context.go('/home'),
                      icon: Icons.favorite_border,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: BookGridView(books: _books),
                    ),
    );
  }
}
