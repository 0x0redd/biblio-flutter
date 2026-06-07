import 'package:flutter/foundation.dart';

import '../models/book_model.dart';
import '../services/book_service.dart';

class BooksProvider extends ChangeNotifier {
  BooksProvider({BookService? bookService})
      : _bookService = bookService ?? BookService();

  final BookService _bookService;

  List<BookModel> books = [];
  List<BookModel> featuredBooks = [];
  List<String> categories = [];
  String? selectedCategory;
  int currentPage = 1;
  bool hasMore = true;
  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;

  Future<void> loadInitial() async {
    isLoading = true;
    error = null;
    currentPage = 1;
    hasMore = true;
    notifyListeners();

    try {
      final listResult = await _bookService.listBooks(
        page: 1,
        category: selectedCategory,
      );
      final featuredResult = await _bookService.listBooks(
        page: 1,
        rating: 5,
        limit: 10,
      );
      final cats = await _bookService.getCategories();

      books = listResult.books;
      hasMore = listResult.pagination.hasMore;
      featuredBooks = featuredResult.books;
      categories = cats;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    currentPage = 1;
    hasMore = true;
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      final result = await _bookService.listBooks(
        page: nextPage,
        category: selectedCategory,
      );
      books = [...books, ...result.books];
      currentPage = nextPage;
      hasMore = result.pagination.hasMore;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String? category) async {
    selectedCategory = category;
    await loadInitial();
  }

  Future<List<BookModel>> search(String query) async {
    if (query.trim().isEmpty) return [];
    return _bookService.searchBooks(query.trim());
  }
}
