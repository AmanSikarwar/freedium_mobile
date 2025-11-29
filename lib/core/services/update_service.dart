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
  static const String _repoOwner = 'AmanSikarwar';
  static const String _repoName = 'freedium_mobile';
  static const String _apiUrl =
      'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final latestVersionStr = (data['tag_name'] as String).replaceAll(
          'v',
          '',
        );
        const currentVersionStr = AppConstants.appVersion;

        final latestVersion = Version.parse(latestVersionStr);
        final currentVersion = Version.parse(currentVersionStr);

        if (latestVersion > currentVersion) {
          return UpdateInfo(
            latestVersion: 'v$latestVersionStr',
            releaseUrl: data['html_url'] as String,
            releaseNotes: data['body'] as String,
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

final updateServiceProvider = Provider((ref) => UpdateService());

final updateCheckProvider = FutureProvider<UpdateInfo?>((ref) async {
  final updateService = ref.watch(updateServiceProvider);
  return await updateService.checkForUpdate();
});
