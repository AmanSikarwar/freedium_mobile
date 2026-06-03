import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/utils/article_url_parser.dart';

void main() {
  group('extractArticleUrl', () {
    test('returns a direct http URL', () {
      expect(
        extractArticleUrl('https://medium.com/example/story?sk=abc#intro'),
        'https://medium.com/example/story?sk=abc#intro',
      );
    });

    test('extracts the first URL from shared text', () {
      expect(
        extractArticleUrl(
          'Read this article: https://towardsdatascience.com/post?source=share',
        ),
        'https://towardsdatascience.com/post?source=share',
      );
    });

    test('normalizes URL casing and trailing slashes', () {
      expect(
        extractArticleUrl('Read HTTPS://Medium.COM/example/story/?sk=abc'),
        'https://medium.com/example/story?sk=abc',
      );
    });

    test('strips trailing punctuation added by message text', () {
      expect(
        extractArticleUrl('Open https://medium.com/example/story.'),
        'https://medium.com/example/story',
      );
    });

    test('rejects unsupported schemes', () {
      expect(extractArticleUrl('ftp://medium.com/example/story'), isNull);
    });

    test('rejects text without a URL', () {
      expect(extractArticleUrl('not an article link'), isNull);
    });
  });

  group('extractFirstArticleUrl', () {
    test('returns the first valid URL across shared values', () {
      expect(
        extractFirstArticleUrl([
          'plain text without a link',
          'Read https://medium.com/example/story',
          'https://towardsdatascience.com/other',
        ]),
        'https://medium.com/example/story',
      );
    });

    test('returns null when no shared value contains a URL', () {
      expect(
        extractFirstArticleUrl(['plain text', 'ftp://medium.com/story']),
        isNull,
      );
    });
  });
}
