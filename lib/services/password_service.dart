import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class PasswordService {
  /// Sends OTP email and stores OTP in Firestore
  static Future<String?> sendPasswordReset(String email) async {
    try {
      // Generate random 6-digit OTP
      final otp = (100000 + Random().nextInt(900000)).toString();

      // Save OTP to Firestore with timestamp
      await FirebaseFirestore.instance.collection('password_resets').doc(email).set({
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final url = Uri.parse('https://instachef-backend.vercel.app/api/send-reset-email');

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      )
          .timeout(
        const Duration(seconds: 10), // Timeout to avoid infinite waiting
        onTimeout: () => throw Exception('Request timed out.'),
      );

      // Print backend response for debugging
      print('Backend status code: ${response.statusCode}');
      print('Backend response body: ${response.body}');

      if (response.statusCode == 200) {
        print("OTP sent successfully: $otp");
        return otp;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      print('Error in sendPasswordReset: $e');
      return null;
    }
  }
}
