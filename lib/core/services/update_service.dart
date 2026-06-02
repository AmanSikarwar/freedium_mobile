import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freedium_mobile/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

@immutable
class UpdateInfo {
  final String latestVersion;
  final String releaseUrl;
  final String releaseNotes;

  const UpdateInfo({
    required this.latestVersion,
    required this.releaseUrl,
    required this.releaseNotes,
  });
}

class UpdateService {
  final http.Client _client;

  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  static const String _repoOwner = 'AmanSikarwar';
  static const String _repoName = 'freedium_mobile';
  static const String _apiUrl =
      'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await _client.get(.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final tagName = data['tag_name'];
        final releaseUrl = data['html_url'];
        if (tagName is! String || releaseUrl is! String) {
          return null;
        }
        final normalizedReleaseUrl = _normalizeReleaseUrl(releaseUrl);
        if (normalizedReleaseUrl == null) {
          return null;
        }

        final latestVersionStr = tagName.trim().replaceFirst(
          RegExp('^v', caseSensitive: false),
          '',
        );
        const currentVersionStr = AppConstants.appVersion;

        final latestVersion = Version.parse(latestVersionStr);
        final currentVersion = Version.parse(currentVersionStr);

        if (latestVersion > currentVersion) {
          return UpdateInfo(
            latestVersion: 'v$latestVersionStr',
            releaseUrl: normalizedReleaseUrl,
            releaseNotes: data['body'] is String ? data['body'] as String : '',
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }
}

String? _normalizeReleaseUrl(String value) {
  final url = value.trim();
  final uri = Uri.tryParse(url);
  final scheme = uri?.scheme.toLowerCase();
  if (uri == null ||
      uri.host.isEmpty ||
      (scheme != 'http' && scheme != 'https')) {
    return null;
  }
  return url;
}

final updateServiceProvider = Provider((ref) => UpdateService());

final updateCheckProvider = FutureProvider<UpdateInfo?>((ref) async {
  final updateService = ref.watch(updateServiceProvider);
  return await updateService.checkForUpdate();
});
