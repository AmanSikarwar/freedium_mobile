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
