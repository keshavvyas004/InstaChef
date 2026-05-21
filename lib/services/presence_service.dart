import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to manage user online/offline presence status in Firestore.
/// 
/// Stores `isOnline` (bool) and `lastSeen` (timestamp) in the user document.
class PresenceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Set current user as online
  static Future<void> setOnline() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // User doc may not exist yet (new user) - safe to ignore
      print('PresenceService.setOnline error: $e');
    }
  }

  /// Set current user as offline with lastSeen timestamp
  static Future<void> setOffline() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('PresenceService.setOffline error: $e');
    }
  }

  /// Get formatted "last seen" text from a timestamp
  static String getLastSeenText(Timestamp? lastSeen) {
    if (lastSeen == null) return 'Offline';

    final now = DateTime.now();
    final lastSeenDate = lastSeen.toDate();
    final diff = now.difference(lastSeenDate);

    if (diff.inMinutes < 1) {
      return 'Active just now';
    } else if (diff.inMinutes < 60) {
      return 'Active ${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return 'Active ${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return 'Active ${diff.inDays}d ago';
    } else {
      return 'Offline';
    }
  }
}
