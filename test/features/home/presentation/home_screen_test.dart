import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/services/clipboard_service.dart';
import 'package:freedium_mobile/features/home/presentation/home_screen.dart';

class _FakeClipboardService extends ClipboardService {
  _FakeClipboardService(this.text);

  String? text;
  int pasteCount = 0;

  @override
  Future<String?> paste() async {
    pasteCount++;
    return text;
  }
}

class _DelayedPasteClipboardService extends ClipboardService {
  final pasteCompleter = Completer<String?>();
  int pasteCount = 0;

  @override
  Future<String?> paste() {
    pasteCount++;
    if (pasteCount == 1) {
      return Future<String?>.value();
    }
    return pasteCompleter.future;
  }
}

void main() {
  group('HomeScreen clipboard detection', () {
    testWidgets('renders the documented primary action', (tester) async {
      final clipboard = _FakeClipboardService(null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clipboardServiceProvider.overrideWith((ref) => clipboard),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Read Article'), findsOneWidget);
      expect(find.text('Get Article'), findsNothing);
    });

    testWidgets('auto-fills a valid article URL from the clipboard', (
      tester,
    ) async {
      final clipboard = _FakeClipboardService(
        'Read HTTPS://Medium.COM/example/story/?sk=abc',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clipboardServiceProvider.overrideWith((ref) => clipboard),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(
        editableText.controller.text,
        'https://medium.com/example/story?sk=abc',
      );
      expect(clipboard.pasteCount, 1);
    });

    testWidgets('ignores clipboard text that does not contain a URL', (
      tester,
    ) async {
      final clipboard = _FakeClipboardService('plain text');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clipboardServiceProvider.overrideWith((ref) => clipboard),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.controller.text, isEmpty);
    });

    testWidgets('shows paste failure when clipboard has no text', (
      tester,
    ) async {
      final clipboard = _FakeClipboardService(null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clipboardServiceProvider.overrideWith((ref) => clipboard),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.paste));
      await tester.pumpAndSettle();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(clipboard.pasteCount, 2);
      expect(editableText.controller.text, isEmpty);
      expect(find.text('Could not paste from clipboard'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overwrite typed input when the app resumes', (
      tester,
    ) async {
      final clipboard = _FakeClipboardService(null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clipboardServiceProvider.overrideWith((ref) => clipboard),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'https://medium.com/manual/story',
      );
      clipboard.text = 'https://medium.com/clipboard/story';

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.controller.text, 'https://medium.com/manual/story');
    });

    testWidgets('ignores paste completion after the screen is disposed', (
      tester,
    ) async {
      final clipboard = _DelayedPasteClipboardService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clipboardServiceProvider.overrideWith((ref) => clipboard),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.paste));
      await tester.pump();
      expect(clipboard.pasteCount, 2);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clipboardServiceProvider.overrideWith((ref) => clipboard),
          ],
          child: const MaterialApp(home: SizedBox.shrink()),
        ),
      );

      clipboard.pasteCompleter.complete('https://medium.com/clipboard/story');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
