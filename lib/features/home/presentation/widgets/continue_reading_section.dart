import 'package:flutter/material.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:freedium_mobile/shared/widgets/article_card.dart';

class ContinueReadingSection extends StatelessWidget {
  const ContinueReadingSection({
    required this.history,
    required this.onArticleTap,
    super.key,
  });

  final List<ReadingHistory> history;
  final ValueChanged<ReadingHistory> onArticleTap;

  @override
  Widget build(BuildContext context) {
    final articles = history
        .where(
          (item) =>
              item.progress > readingProgressRestoreThreshold &&
              !item.isFinished,
        )
        .take(3)
        .toList(growable: false);
    if (articles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Continue Reading',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          for (final article in articles)
            ArticleCard(
              title: article.title,
              subtitle: '${(article.progress * 100).round()}% read',
              url: article.url,
              progress: article.progress,
              onTap: () => onArticleTap(article),
            ),
        ],
      ),
    );
  }
}
