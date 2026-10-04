# Android validation

Use a disposable emulator: the integration test clears Freedium's preferences
and bookmarks, then saves local fixture mirrors for the native intent checks.
The tests use loopback HTTP pages; no live Freedium service is required.

```sh
flutter pub get --enforce-lockfile
flutter test --no-pub --no-uninstall integration_test/reader_test.dart -d emulator-5554
flutter build apk --debug --no-pub
adb install -r build/app/outputs/flutter-apk/app-debug.apk
python3 tool/android_intent_smoke.py
```

The Flutter test uses the real Android WebView to check HTTP 503 failover,
theme and metadata JavaScript channels, reading progress persistence and
restoration, bookmarking and sharing after internal navigation, and back
navigation across a mirror switch. Only the update check and share sheet are
replaced with local test responses.

The Python check uses real Android SEND and VIEW intents on cold and warm
launches, inspects the displayed article through UI Automator, and sends an
Android back key. Run it after the Flutter test and reinstall the normal debug
APK as shown above; the integration APK has a test entry point. CI runs both
checks on an API 35 emulator and gates release verification on them.

## Release APK smoke

`tool/build_release_apks.sh [VERSION [BUILD_NUMBER]]` builds the obfuscated,
split-ABI release APKs using the release signing configuration in
`android/key.properties`. On an x86_64 API 35 emulator, install the produced
APK and run the release smoke check:

```sh
bash tool/build_release_apks.sh
adb install -r build/app/outputs/flutter-apk/app-x86_64-release.apk
python3 tool/android_release_smoke.py
```

The smoke script runs `pm clear` to cover the cold-launch onboarding path, so
use a disposable emulator; it removes Freedium's app data from that device. If
multiple Android devices are connected, select the target with `ANDROID_SERIAL`
before install and smoke so the `adb` commands target the same emulator. The
build helper reads the configured signing files without changing them; a
disposable checkout is only needed if you must create a temporary signing key.

The check opens HTTPS Medium URLs through cold SEND, warm VIEW, and warm SEND
intents, verifies that Freedium's reader screen is foreground, then checks Back
returns to Home. It intentionally does not assert live article content or
mirror availability. CI separately exercises mirror switching with local HTTP
fixtures. The release workflow builds and signs the APKs once, smoke-tests the
uploaded x86_64 APK, and publishes those same APK artifacts only after the
smoke job passes. The smoke job has no production signing secrets. It also
publishes a versioned symbol bundle with the APKs: Flutter/Dart symbols for all
three ABIs and Android's R8 `mapping.txt`. Keep that bundle with its release;
use the matching ABI symbol file with `flutter symbolize` and the R8 mapping
with Android Retrace when decoding crashes.

## Manual device checks

These checks still require a person with a device:

- Enable TalkBack. Navigate the home URL form, reader controls, folder picker,
  error recovery buttons, and restore preview. Check spoken labels, focus order,
  text scaling, and navigation back into the article.
- Export a backup to a document provider, then choose it with **Choose backup
  file**. Check the restore counts, cancel once, then restore. Existing bookmarks
  must remain. Repeat with an invalid file and a file over the 1 MiB limit.
- Open the native share sheet and verify another app receives the displayed
  article URL. Repeat after navigating to a second article inside the WebView.
