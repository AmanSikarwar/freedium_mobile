import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:freedium_mobile/core/services/update_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('UpdateService', () {
    test('returns update details when latest release body is null', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.github.com/repos/AmanSikarwar/freedium_mobile/releases/latest',
        );

        return http.Response(
          jsonEncode({
            'tag_name': 'v0.11.0',
            'html_url':
                'https://github.com/AmanSikarwar/freedium_mobile/releases/tag/v0.11.0',
            'body': null,
          }),
          200,
        );
      });

      final updateInfo = await UpdateService(client: client).checkForUpdate();

      expect(updateInfo, isNotNull);
      expect(updateInfo!.latestVersion, 'v0.11.0');
      expect(
        updateInfo.releaseUrl,
        'https://github.com/AmanSikarwar/freedium_mobile/releases/tag/v0.11.0',
      );
      expect(updateInfo.releaseNotes, isEmpty);
    });

    test('normalizes release metadata from latest release payload', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'tag_name': ' V0.11.0 ',
            'html_url':
                ' https://github.com/AmanSikarwar/freedium_mobile/releases/tag/v0.11.0 ',
            'body': ['not a string'],
          }),
          200,
        );
      });

      final updateInfo = await UpdateService(client: client).checkForUpdate();

      expect(updateInfo, isNotNull);
      expect(updateInfo!.latestVersion, 'v0.11.0');
      expect(
        updateInfo.releaseUrl,
        'https://github.com/AmanSikarwar/freedium_mobile/releases/tag/v0.11.0',
      );
      expect(updateInfo.releaseNotes, isEmpty);
    });

    test('returns null when latest release URL is invalid', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'tag_name': 'v0.11.0',
            'html_url': 'not a url',
            'body': 'Release notes',
          }),
          200,
        );
      });

      final updateInfo = await UpdateService(client: client).checkForUpdate();

      expect(updateInfo, isNull);
    });

    test('returns null when latest release is not newer', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'tag_name': 'v0.10.0',
            'html_url':
                'https://github.com/AmanSikarwar/freedium_mobile/releases/tag/v0.10.0',
            'body': 'Current release',
          }),
          200,
        );
      });

      final updateInfo = await UpdateService(client: client).checkForUpdate();

      expect(updateInfo, isNull);
    });
  });
}
