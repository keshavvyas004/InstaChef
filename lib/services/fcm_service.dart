import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class FCMService {
  static const String _serviceAccountPath = 'lib/assets/secrets/service_account.json';
  static const String _projectId = 'insta-1841b';
  static const String _fcmEndpoint = "https://fcm.googleapis.com/v1/projects/$_projectId/messages:send";

  /// Get OAuth2 Access Token using Service Account
  Future<String?> _getAccessToken() async {
    try {
      final jsonString = await rootBundle.loadString(_serviceAccountPath);
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(jsonString);
      
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await auth.clientViaServiceAccount(accountCredentials, scopes);
      
      // Access token is handled automatically by the client, but we need the string for raw HTTP
      final credentials = await client.credentials;
      client.close();
      
      return credentials.accessToken.data;
    } catch (e) {
      print("Error getting access token: $e");
      return null;
    }
  }

  /// Send Notification via FCM V1 API
  Future<bool> sendNotification({
    required String recipientToken,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      print("Failed to get access token");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': recipientToken,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data,
            'android': {
              'priority': 'HIGH',
              'notification': {
                 'sound': 'default',
                 'channel_id': 'messages_channel'
              }
            },
            'apns': {
              'payload': {
                'aps': {
                  'sound': 'default',
                  'badge': 1
                }
              }
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        print("FCM V1 Notification sent successfully");
        return true;
      } else {
        print("Failed to send FCM V1 Notification: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error sending FCM V1 Notification: $e");
      return false;
    }
  }
}
