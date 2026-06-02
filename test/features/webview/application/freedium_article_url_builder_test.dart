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
          mirrorUrl: 'https://mirror.example/base/',
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
  });
}
