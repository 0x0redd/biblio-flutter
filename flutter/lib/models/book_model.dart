class BookModel {
  const BookModel({
    required this.id,
    required this.bookId,
    required this.title,
    required this.price,
    this.priceExclTax,
    this.priceInclTax,
    this.tax,
    this.rating = 1,
    this.availability,
    this.inStock = true,
    this.stockCount,
    this.category = '',
    this.subcategory,
    this.upc,
    this.productType,
    this.numberOfReviews = 0,
    this.url,
    this.imageUrl = '',
    this.description,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      bookId: _toInt(json['book_id']),
      title: json['title'] as String? ?? '',
      price: _toDouble(json['price']),
      priceExclTax: _toDoubleNullable(json['price_excl_tax']),
      priceInclTax: _toDoubleNullable(json['price_incl_tax']),
      tax: _toDoubleNullable(json['tax']),
      rating: _toInt(json['rating']),
      availability: json['availability'] as String?,
      inStock: json['in_stock'] as bool? ?? true,
      stockCount: json['stock_count'] == null
          ? null
          : _toInt(json['stock_count']),
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String?,
      upc: json['upc'] as String?,
      productType: json['product_type'] as String?,
      numberOfReviews: _toInt(json['number_of_reviews']),
      url: json['url'] as String?,
      imageUrl: json['image_url'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  final String id;
  final int bookId;
  final String title;
  final double price;
  final double? priceExclTax;
  final double? priceInclTax;
  final double? tax;
  final int rating;
  final String? availability;
  final bool inStock;
  final int? stockCount;
  final String category;
  final String? subcategory;
  final String? upc;
  final String? productType;
  final int numberOfReviews;
  final String? url;
  final String imageUrl;
  final String? description;

  String get priceLabel => '£${price.toStringAsFixed(2)}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'book_id': bookId,
        'title': title,
        'price': price,
        'price_excl_tax': priceExclTax,
        'price_incl_tax': priceInclTax,
        'tax': tax,
        'rating': rating,
        'availability': availability,
        'in_stock': inStock,
        'stock_count': stockCount,
        'category': category,
        'subcategory': subcategory,
        'upc': upc,
        'product_type': productType,
        'number_of_reviews': numberOfReviews,
        'url': url,
        'image_url': imageUrl,
        'description': description,
      };

  static int _toInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _toDouble(Object? v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double? _toDoubleNullable(Object? v) {
    if (v == null) return null;
    return _toDouble(v);
  }
}

class PaginationModel {
  const PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;
}
