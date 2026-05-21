/*import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // This is the public URL for your Vercel backend.
  // The '/api/send-email' part is crucial as it points to your serverless function.
  final String _backendUrl = 'https://instachef-backend.vercel.app/api/send-email';

  Future<bool> sendWelcomeEmail(String email, String name) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'name': name,
          'type': 'welcome',
        }),
      );
      if (response.statusCode == 200) {
        print('Welcome email sent successfully!');
        return true;
      } else {
        print('Failed to send welcome email: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending welcome email: $e');
      return false;
    }
  }

  Future<bool> sendLoginAlert(String email) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'type': 'login_alert',
        }),
      );
      if (response.statusCode == 200) {
        print('Login alert email sent successfully!');
        return true;
      } else {
        print('Failed to send login alert: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending login alert: $e');
      return false;
    }
  }
}

 */
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailService {
  // Public URL for your Vercel backend
  final String _backendUrl = 'https://instachef-backend.vercel.app/api/send-email';

  Future<bool> sendWelcomeEmail(String email, String name) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'name': name,
          'type': 'welcome',
        }),
      );
      if (response.statusCode == 200) {
        print('Welcome email sent successfully!');
        return true;
      } else {
        print('Failed to send welcome email: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending welcome email: $e');
      return false;
    }
  }

  Future<bool> sendLoginAlert(String email) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'type': 'login_alert',
        }),
      );
      if (response.statusCode == 200) {
        print('Login alert email sent successfully!');
        return true;
      } else {
        print('Failed to send login alert: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending login alert: $e');
      return false;
    }
  }

  /// 🔹 New: Send OTP for password reset
  Future<bool> sendPasswordResetOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
          'type': 'password_reset_otp',
        }),
      );
      if (response.statusCode == 200) {
        print('Password reset OTP sent successfully!');
        return true;
      } else {
        print('Failed to send OTP: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }
}
