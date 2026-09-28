import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mirror_probe.freezed.dart';

/// Result of a mirror reachability probe, surfaced by `testMirror`.
@freezed
abstract class MirrorProbeResult with _$MirrorProbeResult {
  const factory MirrorProbeResult({
    required bool isReachable,
    int? statusCode,
    String? error,
  }) = _MirrorProbeResult;
}

bool isMirrorSuccessStatus(int statusCode) =>
    statusCode >= 200 && statusCode < 400;

Future<MirrorProbeResult> sendMirrorProbeRequest(
  HttpClient client,
  Uri uri,
  Duration timeout, {
  required bool useGet,
}) async {
  try {
    final request = useGet
        ? await client.getUrl(uri).timeout(timeout)
        : await client.headUrl(uri).timeout(timeout);

    if (useGet) {
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-0');
    }

    final response = await request.close().timeout(timeout);
    final statusCode = response.statusCode;
    final isReachable = isMirrorSuccessStatus(statusCode);

    return MirrorProbeResult(
      isReachable: isReachable,
      statusCode: statusCode,
      error: isReachable ? null : 'HTTP $statusCode',
    );
  } catch (e) {
    return MirrorProbeResult(isReachable: false, error: e.toString());
  }
}

Future<MirrorProbeResult> probeMirrorUrl(
  HttpClient client,
  Uri uri,
  Duration timeout,
) async {
  final headResult = await sendMirrorProbeRequest(
    client,
    uri,
    timeout,
    useGet: false,
  );

  if (headResult.isReachable) {
    return headResult;
  }

  final shouldFallbackToGet =
      headResult.statusCode == null || headResult.statusCode! >= 400;

  if (!shouldFallbackToGet) {
    return headResult;
  }

  final getResult = await sendMirrorProbeRequest(
    client,
    uri,
    timeout,
    useGet: true,
  );

  if (getResult.isReachable) {
    return getResult;
  }

  if (getResult.statusCode != null || getResult.error != null) {
    return getResult;
  }

  return headResult;
}
