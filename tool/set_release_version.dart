import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

Version _parseReleaseVersion(String versionName) {
  final version = Version.parse(versionName);
  if (version.toString() != versionName || version.build.isNotEmpty) {
    throw const FormatException(
      'Use a semantic version without build metadata',
    );
  }
  return version;
}

bool isPrereleaseVersion(String versionName) =>
    _parseReleaseVersion(versionName).isPreRelease;

String updateReleaseVersion(
  String pubspec,
  String versionName,
  String buildNumber,
) {
  final version = _parseReleaseVersion(versionName);
  final build = int.tryParse(buildNumber);
  if (build == null || build <= 0 || build.toString() != buildNumber) {
    throw const FormatException('Use a positive build number');
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
    final isPrerelease = isPrereleaseVersion(args[0]);
    final updated = updateReleaseVersion(
      await pubspec.readAsString(),
      args[0],
      args[1],
    );
    await pubspec.writeAsString(updated);
    final githubOutput = Platform.environment['GITHUB_OUTPUT'];
    if (githubOutput != null) {
      await File(githubOutput)
          .writeAsString('prerelease=$isPrerelease\n', mode: FileMode.append);
    }
  } on FormatException catch (error) {
    stderr.writeln('Invalid release: ${error.message}');
    exitCode = 64;
  }
}
