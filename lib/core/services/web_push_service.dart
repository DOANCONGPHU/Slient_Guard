import 'dart:async';
import 'dart:developer' as developer;
import 'dart:js_interop';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

const _vapidKey =
    'BGnKNnlcQZLGX74fb9aw99ULP-FHgViXdhM71RYBCqCv5qlNckQogVhR3XDJUpur5WU55IcrvjnXZjqRF2SEMmQ';
const _serviceWorkerReadyTimeout = Duration(seconds: 10);

Future<void> registerWebPushToken({
  required String firebaseIdToken,
  required String backendBaseUrl,
}) async {
  if (!kIsWeb) return;

  try {
    developer.log(
      '[FCM][Web] requesting browser notification permission.',
      name: 'WebPushService',
    );
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    developer.log(
      '[FCM][Web] browser notification permission: '
      '${settings.authorizationStatus}.',
      name: 'WebPushService',
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      developer.log(
        '[FCM][Web] web push registration stopped because permission is not '
        'authorized.',
        name: 'WebPushService',
      );
      return;
    }

    final serviceWorkerReady = await _waitForServiceWorkerReady();
    if (!serviceWorkerReady) return;

    developer.log(
      '[FCM][Web] requesting FCM token with VAPID key.',
      name: 'WebPushService',
    );
    final fcmToken = await FirebaseMessaging.instance.getToken(
      vapidKey: _vapidKey,
    );

    if (fcmToken == null || fcmToken.trim().isEmpty) {
      developer.log(
        '[FCM][Web] FCM token is empty; backend registration skipped.',
        name: 'WebPushService',
      );
      return;
    }

    developer.log(
      '[FCM][Web] FCM token obtained: ${_tokenDebugLabel(fcmToken)}.',
      name: 'WebPushService',
    );

    final uri = Uri.parse('$backendBaseUrl/api/users/device-token');
    developer.log(
      '[FCM][Web] sending token to backend: $uri.',
      name: 'WebPushService',
    );
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $firebaseIdToken',
      },
      body: '{"fcm_token": "$fcmToken"}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      developer.log(
        '[FCM][Web] token sent to backend successfully: '
        'status=${response.statusCode}.',
        name: 'WebPushService',
      );
      return;
    }

    developer.log(
      '[FCM][Web] failed to send token to backend: '
      'status=${response.statusCode}, body=${response.body}.',
      name: 'WebPushService',
    );
  } catch (error, stackTrace) {
    developer.log(
      '[FCM][Web] registerWebPushToken failed.',
      name: 'WebPushService',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Future<bool> _waitForServiceWorkerReady() async {
  try {
    developer.log(
      '[FCM][Web] waiting for service worker to become ready.',
      name: 'WebPushService',
    );
    await web.window.navigator.serviceWorker.ready.toDart.timeout(
      _serviceWorkerReadyTimeout,
    );
    developer.log('[FCM][Web] service worker ready.', name: 'WebPushService');
    return true;
  } on TimeoutException catch (error, stackTrace) {
    developer.log(
      '[FCM][Web] service worker was not ready within '
      '${_serviceWorkerReadyTimeout.inSeconds}s; token registration skipped.',
      name: 'WebPushService',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  } catch (error, stackTrace) {
    developer.log(
      '[FCM][Web] waiting for service worker readiness failed.',
      name: 'WebPushService',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

String _tokenDebugLabel(String token) {
  final value = token.trim();
  if (value.length <= 12) return 'length=${value.length}';
  return 'length=${value.length}, '
      'prefix=${value.substring(0, 6)}, suffix=${value.substring(value.length - 6)}';
}
