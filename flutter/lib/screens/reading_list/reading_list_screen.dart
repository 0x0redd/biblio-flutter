import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/book_model.dart';
import '../../services/user_service.dart';
import '../../widgets/book_grid_view.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_indicator.dart';

class ReadingListScreen extends StatefulWidget {
  const ReadingListScreen({super.key});

  @override
  State<ReadingListScreen> createState() => _ReadingListScreenState();
}

class _ReadingListScreenState extends State<ReadingListScreen> {
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
      final books = await _userService.getReadingListBooks();
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
      appBar: AppBar(title: const Text('Reading List')),
      body: _loading
          ? const LoadingIndicator()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : _books.isEmpty
                  ? EmptyStateWidget(
                      message: 'Your reading list is empty',
                      actionLabel: 'Browse books',
                      onAction: () => context.go('/home'),
                      icon: Icons.bookmark_border,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: BookGridView(books: _books),
                    ),
    );
  }
}
