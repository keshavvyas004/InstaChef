import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Call this whenever a user opens the app to log daily activity
Future<void> logDailyActiveUser() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return; // Exit if no user logged in

  final today = DateTime.now();
  final dateKey =
      '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

  final docRef = FirebaseFirestore.instance
      .collection('analytics_daily_active_users')
      .doc(dateKey);

  try {
    // Add user UID as a map key
    await docRef.set({
      'users.${user.uid}': true,
    }, SetOptions(merge: true));

    print('Daily active user logged for ${user.uid}');
  } catch (e) {
    print('Error logging daily active user: $e');
  }
}
