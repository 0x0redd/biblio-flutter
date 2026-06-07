import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/utils/helpers.dart';

/// Loads remote book covers. On web uses `<img>` to avoid CORS (statusCode 0).
class BookCoverImage extends StatelessWidget {
  const BookCoverImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = resolveImageUrl(imageUrl);

    Widget image;
    if (url.isEmpty) {
      image = _placeholder();
    } else if (kIsWeb) {
      image = Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _loading();
        },
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => _loading(),
        errorWidget: (context, url, error) => _placeholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _loading() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.menu_book, size: 40),
    );
  }
}
