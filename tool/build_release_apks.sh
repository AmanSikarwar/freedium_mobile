#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -gt 2 ]]; then
  echo "Usage: build_release_apks.sh [VERSION [BUILD_NUMBER]]" >&2
  exit 64
fi

version_line=$(sed -n 's/^version: //p' pubspec.yaml)
if [[ -z "$version_line" ]]; then
  echo "pubspec.yaml is missing its version" >&2
  exit 1
fi

app_version="${1:-${version_line%%+*}}"
build_number="${2:-}"
if [[ -z "$app_version" ]]; then
  echo "App version cannot be empty" >&2
  exit 64
fi

flutter_args=(
  build apk
  --release
  --split-per-abi
  --obfuscate
  --split-debug-info=build/debug-info
  -t lib/main.dart
  "--dart-define=APP_VERSION=$app_version"
)
if [[ -n "$build_number" ]]; then
  flutter_args+=("--build-number=$build_number")
fi

exec flutter "${flutter_args[@]}"
