import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freedium_mobile/core/utils/url.dart' show isHttpUri;
import 'package:url_launcher/url_launcher.dart' as url_launcher;

part 'external_url_launcher.g.dart';

typedef ExternalUrlLauncher = Future<bool> Function(String? value);

@Riverpod(keepAlive: true)
ExternalUrlLauncher externalUrlLauncher(Ref ref) => launchExternalHttpUrl;

Uri? parseExternalHttpUrl(String? value) {
  final url = value?.trim();
  if (url == null || url.isEmpty) return null;

  final uri = Uri.tryParse(url);
  return isHttpUri(uri) ? uri : null;
}

Future<bool> launchExternalHttpUrl(String? value) async {
  final uri = parseExternalHttpUrl(value);
  if (uri == null) return false;

  try {
    final launched = await url_launcher.launchUrl(
      uri,
      mode: url_launcher.LaunchMode.externalApplication,
    );
    if (!launched) {
      debugPrint('Could not launch URL: $uri');
    }
    return launched;
  } catch (e) {
    debugPrint('Failed to launch URL "$uri": $e');
    return false;
  }
}
