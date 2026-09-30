import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

String updateReleaseVersion(
  String pubspec,
  String versionName,
  String buildNumber,
) {
  final version = Version.parse(versionName);
  final build = int.tryParse(buildNumber);
  if (version.toString() != versionName ||
      version.build.isNotEmpty ||
      build == null ||
      build <= 0 ||
      build.toString() != buildNumber) {
    throw const FormatException(
      'Use a semantic version and positive build number',
    );
  }
  final versionLine = RegExp(r'^version:.*$', multiLine: true);
  if (!versionLine.hasMatch(pubspec)) {
    throw const FormatException('pubspec.yaml is missing its version');
  }
  return pubspec.replaceFirst(versionLine, 'version: $version+$build');
}

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln('Usage: set_release_version.dart VERSION BUILD_NUMBER');
    exitCode = 64;
    return;
  }
  final pubspec = File('pubspec.yaml');
  try {
    final updated = updateReleaseVersion(
      await pubspec.readAsString(),
      args[0],
      args[1],
    );
    await pubspec.writeAsString(updated);
  } on FormatException catch (error) {
    stderr.writeln('Invalid release: ${error.message}');
    exitCode = 64;
  }
}
