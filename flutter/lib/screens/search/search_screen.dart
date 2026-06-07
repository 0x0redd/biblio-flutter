import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/book_model.dart';
import '../../providers/books_provider.dart';
import '../../widgets/book_grid_view.dart';
import '../../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<BookModel> _results = [];
  bool _loading = false;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        _query = value.trim();
        _loading = true;
      });
      if (_query.isEmpty) {
        setState(() {
          _results = [];
          _loading = false;
        });
        return;
      }
      final results = await context.read<BooksProvider>().search(_query);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by title or category...',
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _query.isEmpty
              ? const EmptyStateWidget(message: 'Start typing to search books')
              : _results.isEmpty
                  ? EmptyStateWidget(
                      message: 'No books found for "$_query"',
                      actionLabel: 'Clear search',
                      onAction: () {
                        _controller.clear();
                        setState(() {
                          _query = '';
                          _results = [];
                        });
                      },
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _onChanged(_controller.text),
                      child: BookGridView(books: _results),
                    ),
    );
  }
}
