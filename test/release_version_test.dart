import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/set_release_version.dart';

void main() {
  test('release versions are validated before updating the pubspec', () {
    const source = 'name: reader\nversion: 0.13.0+13\npublish_to: none\n';
    expect(
      updateReleaseVersion(source, '1.2.3', '14'),
      'name: reader\nversion: 1.2.3+14\npublish_to: none\n',
    );
    expect(
      updateReleaseVersion(source, '1.2.3-rc.1', '14'),
      contains('1.2.3-rc.1+14'),
    );
    for (final input in [
      '',
      'v1.2.3',
      '1.2',
      '1.2.3+4',
      '1.2.3\nversion: 9.9.9',
      '1.2.3"; touch injected #',
      r'$(touch injected)',
      r'`touch injected`',
    ]) {
      expect(
        () => updateReleaseVersion(source, input, '14'),
        throwsFormatException,
      );
    }
    for (final build in ['0', '-1', '01', 'x', '14; touch injected']) {
      expect(
        () => updateReleaseVersion(source, '1.2.3', build),
        throwsFormatException,
      );
    }
  });

  test('invalid CLI input leaves the pubspec untouched', () async {
    final directory = await Directory.systemTemp.createTemp(
      'freedium-release-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final pubspec = File('${directory.path}/pubspec.yaml');
    const source = 'version: 0.13.0+13\n';
    await pubspec.writeAsString(source);
    final result = await Process.run('dart', [
      File('tool/set_release_version.dart').absolute.path,
      '1.2.3; touch injected',
      '14',
    ], workingDirectory: directory.path);
    expect(result.exitCode, 64);
    expect(await pubspec.readAsString(), source);
    expect(File('${directory.path}/injected').existsSync(), isFalse);
  });
}
