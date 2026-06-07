import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/book_model.dart';
import '../models/review_model.dart';

class BookListResult {
  const BookListResult({required this.books, required this.pagination});

  final List<BookModel> books;
  final PaginationModel pagination;
}

class BookService {
  BookService({ApiClient? apiClient})
      : _dio = (apiClient ?? ApiClient.instance).dio;

  final Dio _dio;

  Future<BookListResult> listBooks({
    int page = 1,
    int limit = 20,
    String? category,
    int? rating,
  }) async {
    final response = await _dio.get(
      ApiConstants.books,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (rating != null) 'rating': rating,
      },
    );
    final body = response.data as Map<String, dynamic>;
    final books = (body['data'] as List<dynamic>)
        .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = PaginationModel.fromJson(
      body['pagination'] as Map<String, dynamic>,
    );
    return BookListResult(books: books, pagination: pagination);
  }

  Future<BookModel> getBook(String id) async {
    final response = await _dio.get('${ApiConstants.books}/$id');
    final body = response.data as Map<String, dynamic>;
    return BookModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<BookModel>> searchBooks(String query) async {
    final response = await _dio.get(
      ApiConstants.booksSearch,
      queryParameters: {'q': query},
    );
    final body = response.data as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getCategories() async {
    final response = await _dio.get(ApiConstants.booksCategories);
    final body = response.data as Map<String, dynamic>;
    return (body['data'] as List<dynamic>).map((e) => e.toString()).toList();
  }

  Future<List<ReviewModel>> getReviews(String bookId) async {
    final response = await _dio.get('${ApiConstants.reviews}/book/$bookId');
    final body = response.data as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReviewModel> postReview({
    required String bookId,
    required int rating,
    required String comment,
  }) async {
    final response = await _dio.post(
      ApiConstants.reviews,
      data: {'book_id': bookId, 'rating': rating, 'comment': comment},
    );
    final body = response.data as Map<String, dynamic>;
    return ReviewModel.fromJson(body['data'] as Map<String, dynamic>);
  }
}
