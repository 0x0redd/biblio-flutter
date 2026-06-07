import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBookCard extends StatelessWidget {
  const ShimmerBookCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Container(color: Colors.white)),
          const SizedBox(height: 8),
          Container(height: 14, color: Colors.white),
          const SizedBox(height: 4),
          Container(height: 12, width: 80, color: Colors.white),
        ],
      ),
    );
  }
}
