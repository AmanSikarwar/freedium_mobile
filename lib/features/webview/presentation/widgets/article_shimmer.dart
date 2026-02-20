import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ArticleShimmer extends StatelessWidget {
  const ArticleShimmer({super.key});

  static BoxDecoration _roundedBox(double radius) =>
      BoxDecoration(color: Colors.white, borderRadius: .circular(radius));

  static const _circleDecoration = BoxDecoration(
    color: Colors.white,
    shape: .circle,
  );

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 4,
  }) =>
      Container(width: width, height: height, decoration: _roundedBox(radius));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.primaryContainer.withValues(alpha: 0.7);
    final highlightColor = colorScheme.surface.withValues(alpha: 0.8);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: .all(16.0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                _shimmerBox(width: 40, height: 40, radius: 8),
                const Spacer(),
                _shimmerBox(width: 40, height: 40, radius: 8),
              ],
            ),
            const SizedBox(height: 24),
            _shimmerBox(width: 150, height: 16),
            const SizedBox(height: 16),
            _shimmerBox(width: double.infinity, height: 200, radius: 12),
            const SizedBox(height: 24),
            _shimmerBox(width: double.infinity, height: 32),
            const SizedBox(height: 8),
            _shimmerBox(width: screenWidth * 0.7, height: 32),
            const SizedBox(height: 24),
            _shimmerBox(width: double.infinity, height: 20),
            const SizedBox(height: 8),
            _shimmerBox(width: screenWidth * 0.9, height: 20),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(width: 48, height: 48, decoration: _circleDecoration),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    _shimmerBox(width: 120, height: 16),
                    const SizedBox(height: 4),
                    _shimmerBox(width: 80, height: 14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            ...List.generate(
              6,
              (index) => Padding(
                padding: .only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    _shimmerBox(width: double.infinity, height: 16),
                    const SizedBox(height: 4),
                    _shimmerBox(width: double.infinity, height: 16),
                    const SizedBox(height: 4),
                    _shimmerBox(width: screenWidth * 0.8, height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
