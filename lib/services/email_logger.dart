import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORTANT: Matches the App ID visible in your Firestore console.
const String _APP_ID = '1:250338435801:android:ddd8de8871e9db841c54c8';

/// Logs a successful email send event to Firestore for admin dashboard tracking.
///
/// This function is crucial for making the 'Monthly Email Sends' graph real-time.
/// Call this immediately after your external email service confirms a successful send.
Future<void> logEmailSendEvent({
  required String recipientEmail,
  required String eventType, // e.g., 'post_share', 'password_reset'
  String? resourceId, // Optional tracking ID (e.g., Cloudinary ID/URL)
}) async {
  try {
    // Target Path: artifacts/instachef_app_id/admin_data/logs/email_sends
    await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(_APP_ID)
        .collection('admin_data') // Dedicated collection for admin logs
        .doc('logs')
        .collection('email_sends') // Final collection where log entries are stored
        .add({
      // Data fields
      'sentAt': FieldValue.serverTimestamp(), // Critical for dashboard aggregation
      'recipient': recipientEmail,
      'eventType': eventType,
      'resourceId': resourceId,
      'success': true,
    });
    print('Logged email send event successfully.');
  } catch (e) {
    print('Error logging email send event to Firestore: $e');
  }
}