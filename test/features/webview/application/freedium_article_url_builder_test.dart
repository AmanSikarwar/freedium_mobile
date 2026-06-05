import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/features/webview/application/freedium_article_url_builder.dart';

void main() {
  group('buildFreediumArticleUri', () {
    test('builds article URL for root mirror', () {
      expect(
        buildFreediumArticleUri(
          mirrorUrl: 'https://freedium.cfd',
          articleUrl: 'https://medium.com/example/story',
        ).toString(),
        'https://freedium.cfd/https://medium.com/example/story',
      );
    });

    test('builds article URL for root mirror with trailing slash', () {
      expect(
        buildFreediumArticleUri(
          mirrorUrl: 'https://freedium.cfd/',
          articleUrl: 'https://medium.com/example/story',
        ).toString(),
        'https://freedium.cfd/https://medium.com/example/story',
      );
    });

    test('preserves mirror path prefix', () {
      expect(
        buildFreediumArticleUri(
          mirrorUrl: 'https://mirror.example/base',
          articleUrl: 'https://medium.com/example/story',
        ).toString(),
        'https://mirror.example/base/https://medium.com/example/story',
      );
    });

    test('preserves mirror path prefix without duplicate slash', () {
      expect(
        buildFreediumArticleUri(
          mirrorUrl: 'https://mirror.example/base///',
          articleUrl: 'https://medium.com/example/story',
        ).toString(),
        'https://mirror.example/base/https://medium.com/example/story',
      );
    });

    test('drops mirror query and fragment when building article URL', () {
      expect(
        buildFreediumArticleUri(
          mirrorUrl: 'https://mirror.example/base?ref=home#top',
          articleUrl: 'https://medium.com/example/story',
        ).toString(),
        'https://mirror.example/base/https://medium.com/example/story',
      );
    });

    test('encodes article query and fragment inside mirror path', () {
      expect(
        buildFreediumArticleUri(
          mirrorUrl: 'https://freedium.cfd',
          articleUrl: 'https://medium.com/example/story?sk=abc#intro',
        ).toString(),
        'https://freedium.cfd/https://medium.com/example/story%3Fsk=abc%23intro',
      );
    });

    test('extracts original article URL from root mirror URL', () {
      const articleUrl = 'https://medium.com/example/story?sk=abc#intro';
      final freediumUrl = buildFreediumArticleUri(
        mirrorUrl: 'https://freedium.cfd',
        articleUrl: articleUrl,
      ).toString();

      expect(
        extractOriginalArticleUrlFromFreediumUri(
          mirrorUrl: 'https://freedium.cfd',
          freediumUrl: freediumUrl,
        ),
        articleUrl,
      );
    });

    test(
      'extracts original article URL from root mirror URL with trailing slash',
      () {
        const articleUrl = 'https://medium.com/example/story?sk=abc#intro';
        final freediumUrl = buildFreediumArticleUri(
          mirrorUrl: 'https://freedium.cfd/',
          articleUrl: articleUrl,
        ).toString();

        expect(
          extractOriginalArticleUrlFromFreediumUri(
            mirrorUrl: 'https://freedium.cfd/',
            freediumUrl: freediumUrl,
          ),
          articleUrl,
        );
      },
    );

    test('extracts original article URL from path-prefixed mirror URL', () {
      const articleUrl = 'https://medium.com/example/story?sk=abc#intro';
      final freediumUrl = buildFreediumArticleUri(
        mirrorUrl: 'https://mirror.example/base',
        articleUrl: articleUrl,
      ).toString();

      expect(
        extractOriginalArticleUrlFromFreediumUri(
          mirrorUrl: 'https://mirror.example/base',
          freediumUrl: freediumUrl,
        ),
        articleUrl,
      );
    });

    test(
      'extracts original article URL when query and fragment are unencoded',
      () {
        expect(
          extractOriginalArticleUrlFromFreediumUri(
            mirrorUrl: 'https://freedium.cfd',
            freediumUrl:
                'https://freedium.cfd/https://medium.com/example/story?sk=abc#intro',
          ),
          'https://medium.com/example/story?sk=abc#intro',
        );
      },
    );

    test(
      'extracts path-prefixed original URL with unencoded query and fragment',
      () {
        expect(
          extractOriginalArticleUrlFromFreediumUri(
            mirrorUrl: 'https://mirror.example/base',
            freediumUrl:
                'https://mirror.example/base/https://medium.com/example/story?sk=abc#intro',
          ),
          'https://medium.com/example/story?sk=abc#intro',
        );
      },
    );
  });
}
