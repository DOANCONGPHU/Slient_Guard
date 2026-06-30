import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

const String _vapidKey = 'BGnKNnlcQZLGX74fb9aw99ULP-FHgViXdhM71RYBCqCv5qlNckQogVhR3XDJUpur5WU55IcrvjnXZjqRF2SEMmQ';

Future<void> registerWebPushToken({required String firebaseIdToken, required String backendBaseUrl}) async {
  if (kIsWeb) {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus != AuthorizationStatus.provisional) {
        developer.log('Web push permission not granted.');
        return;
      }

      final token = await FirebaseMessaging.instance.getToken(vapidKey: _vapidKey);
      
      if (token != null) {
        final uri = Uri.parse('$backendBaseUrl/api/users/device-token');
        final response = await http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $firebaseIdToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"fcm_token": token}),
        );
        if (response.statusCode != 200 && response.statusCode != 201) {
          developer.log('Failed to send token to backend: ${response.statusCode}');
        }
      }
    } catch (e, stackTrace) {
      developer.log('Error registering web push token', error: e, stackTrace: stackTrace);
    }
  }
}
