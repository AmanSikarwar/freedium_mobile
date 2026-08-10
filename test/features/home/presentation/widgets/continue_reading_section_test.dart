import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/history/domain/reading_history.dart';
import 'package:freedium_mobile/features/home/presentation/widgets/continue_reading_section.dart';

void main() {
  testWidgets('shows the three latest unfinished articles', (tester) async {
    final tapped = <ReadingHistory>[];
    final history = [
      _article('First', 0.2),
      _article('Second', 0.4),
      _article('Finished', 1),
      _article('Not started', 0),
      _article('Third', 0.8),
      _article('Fourth', 0.6),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContinueReadingSection(
            history: history,
            onArticleTap: tapped.add,
          ),
        ),
      ),
    );

    expect(find.text('Continue Reading'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Third'), findsOneWidget);
    expect(find.text('Finished'), findsNothing);
    expect(find.text('Not started'), findsNothing);
    expect(find.text('Fourth'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(3));

    await tester.tap(find.text('Second'));
    expect(tapped, [history[1]]);
  });

  testWidgets('stays hidden without an article in progress', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContinueReadingSection(
            history: [_article('Not started', 0), _article('Finished', 1)],
            onArticleTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Continue Reading'), findsNothing);
  });
}

ReadingHistory _article(String title, double progress) {
  return ReadingHistory(
    url: 'https://medium.com/$title',
    title: title,
    timestamp: DateTime.utc(2026, 8, 10),
    progress: progress,
  );
}
