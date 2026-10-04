"""Bundle the exact obfuscation maps for one Android release build."""

import hashlib
import os
import re
import sys
import zipfile
from pathlib import Path


SYMBOL_NAMES = (
    'app.android-arm.symbols',
    'app.android-arm64.symbols',
    'app.android-x64.symbols',
)
SYMBOL_DIRECTORY = Path('build/debug-info')
R8_MAPPING = Path('build/app/outputs/mapping/release/mapping.txt')
OUTPUT_DIRECTORY = Path('build/release-symbols')


def main():
    version = os.environ.get('RELEASE_VERSION', '')
    build_number = os.environ.get('RELEASE_BUILD_NUMBER', '')
    commit = os.environ.get('RELEASE_COMMIT', '')
    if not re.fullmatch(r'[0-9A-Za-z.+-]+', version):
        raise SystemExit('RELEASE_VERSION must be a validated version string')
    if not re.fullmatch(r'[1-9][0-9]*', build_number):
        raise SystemExit('RELEASE_BUILD_NUMBER must be a positive integer')
    if not re.fullmatch(r'[0-9a-f]{40}', commit):
        raise SystemExit('RELEASE_COMMIT must be a full Git commit SHA')

    files = [(SYMBOL_DIRECTORY / name, f'flutter/{name}') for name in SYMBOL_NAMES]
    files.append((R8_MAPPING, 'android/mapping.txt'))
    missing = [str(source) for source, _ in files if not source.is_file()]
    if missing:
        raise SystemExit(f'Missing release symbol files: {", ".join(missing)}')
    empty = [str(source) for source, _ in files if source.stat().st_size == 0]
    if empty:
        raise SystemExit(f'Empty release symbol files: {", ".join(empty)}')

    bundle_name = f'freedium-v{version}-build{build_number}-symbols'
    OUTPUT_DIRECTORY.mkdir(parents=True, exist_ok=True)
    archive = OUTPUT_DIRECTORY / f'{bundle_name}.zip'
    temporary_archive = archive.with_suffix('.zip.tmp')

    manifest = [
        'Freedium Android release symbols',
        f'Version: {version}',
        f'Build number: {build_number}',
        f'Source commit: {commit}',
        '',
        'Flutter/Dart symbols are under flutter/. Select the file matching the',
        'APK ABI when using `flutter symbolize`.',
        'Android Java/Kotlin R8 mapping is android/mapping.txt.',
        '',
        'SHA-256:',
    ]
    manifest.extend(
        f'  {hashlib.sha256(source.read_bytes()).hexdigest()}  {archive_name}'
        for source, archive_name in files
    )

    try:
        with zipfile.ZipFile(
            temporary_archive,
            mode='w',
            compression=zipfile.ZIP_DEFLATED,
        ) as bundle:
            for source, archive_name in files:
                bundle.write(source, f'{bundle_name}/{archive_name}')
            bundle.writestr(
                f'{bundle_name}/README.txt',
                '\n'.join(manifest) + '\n',
            )
        temporary_archive.replace(archive)
    finally:
        temporary_archive.unlink(missing_ok=True)

    print(f'Created {archive}')


if __name__ == '__main__':
    try:
        main()
    except OSError as error:
        print(f'Could not package release symbols: {error}', file=sys.stderr)
        raise SystemExit(1) from error
