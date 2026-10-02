import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef BookmarkFilePicker = Future<String?> Function();

const bookmarkBackupChannel = MethodChannel('freedium/bookmark_backup');
final bookmarkFilePickerProvider = Provider<BookmarkFilePicker>(
  (ref) =>
      () => bookmarkBackupChannel.invokeMethod<String>('openBackup'),
);
