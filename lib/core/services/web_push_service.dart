import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const _vapidKey = 'BGnKNnlcQZLGX74fb9aw99ULP-FHgViXdhM71RYBCqCv5qlNckQogVhR3XDJUpur5WU55IcrvjnXZjqRF2SEMmQ'; // giữ nguyên key đã điền trước đó

Future<void> registerWebPushToken({
  required String firebaseIdToken,
  required String backendBaseUrl,
}) async {
  if (!kIsWeb) return;

  try {
    // Bước 1: Xin quyền notification
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      developer.log(
        'User denied notification permission',
        name: 'WebPushService',
      );
      return;
    }

    // Bước 2: Lấy FCM token với VAPID key
    final fcmToken = await FirebaseMessaging.instance.getToken(
      vapidKey: _vapidKey,
    );

    if (fcmToken == null) {
      developer.log('FCM token is null', name: 'WebPushService');
      return;
    }

    developer.log('FCM Web token: $fcmToken', name: 'WebPushService');

    // Bước 3: Gửi token lên backend
    final uri = Uri.parse('$backendBaseUrl/api/users/device-token');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $firebaseIdToken',
      },
      body: '{"fcm_token": "$fcmToken"}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      developer.log('FCM token sent to backend successfully', name: 'WebPushService');
      return;
    }

    developer.log(
      'Failed to send token to backend: ${response.statusCode}',
      name: 'WebPushService',
    );
  } catch (e, st) {
    developer.log(
      'registerWebPushToken error',
      name: 'WebPushService',
      error: e,
      stackTrace: st,
    );
  }
}
