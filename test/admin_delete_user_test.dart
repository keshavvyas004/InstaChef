// ============================================================
//  Admin Delete User — Unit Tests
//  Run with:  flutter test test/admin_delete_user_test.dart
// ============================================================
//
//  What is tested
//  ─────────────────────────────────────────────────────────────
//  1. deleteUser_success
//     Backend returns HTTP 200 AND Firestore doc is deleted
//     → expect: firestoreDeleted == true, result == 'deleted'
//
//  2. deleteUser_backendFailure_firestoreStillDeleted
//     Backend returns HTTP 500 (auth removal failed)
//     → expect: Firestore doc is still deleted (partial success)
//
//  3. deleteUser_backendTimeout_firestoreStillDeleted
//     Backend call throws a timeout exception
//     → expect: Firestore doc is still deleted, error captured
//
//  4. deleteUser_nonAdmin_blocked
//     isAdmin == false
//     → expect: neither HTTP nor Firestore is called
// ============================================================

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// ── Thin delete logic extracted from AdminUsersScreen ────────────────────────
// This mirrors *exactly* what _deleteUser does so we can test it in isolation
// without needing Firebase plugins initialised.

class DeleteResult {
  final bool firestoreDeleted;
  final String? authError;
  final String? firestoreError;

  DeleteResult({
    required this.firestoreDeleted,
    this.authError,
    this.firestoreError,
  });

  /// Replicates the snackbar message logic from the screen
  String get userFacingMessage {
    if (firestoreError != null) return 'Failed to delete Firestore record: $firestoreError';
    if (authError != null)      return 'Removed from app. Auth cleanup pending. ($authError)';
    return 'User deleted successfully';
  }

  bool get wasSuccessful => firestoreDeleted && authError == null;
}

/// Pure-logic version of _deleteUser (extracted for testability).
/// [httpClient]      – injectable HTTP client (use MockClient in tests)
/// [firestoreDelete] – injectable Firestore delete function
/// [isAdmin]         – guards the operation
/// [idToken]         – auth token to send
Future<DeleteResult> deleteUserLogic({
  required bool isAdmin,
  required String uid,
  required String idToken,
  required http.Client httpClient,
  required Future<void> Function(String uid) firestoreDelete,
}) async {
  // Guard: only admins may delete
  if (!isAdmin) {
    return DeleteResult(
      firestoreDeleted: false,
      authError: 'Permission denied: not an admin',
    );
  }

  String? authError;

  // Step 1 – Backend (Firebase Auth removal)
  try {
    final res = await httpClient.post(
      Uri.parse('https://instachef-backend.vercel.app/api/delete-user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({'uid': uid}),
    ).timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      authError = 'Backend: ${res.statusCode} ${res.body}';
    }
  } catch (e) {
    authError = e.toString();
  }

  // Step 2 – Firestore document removal (always attempted)
  try {
    await firestoreDelete(uid);
    return DeleteResult(firestoreDeleted: true, authError: authError);
  } catch (e) {
    return DeleteResult(
      firestoreDeleted: false,
      authError: authError,
      firestoreError: e.toString(),
    );
  }
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  const testUid   = 'user_abc_123';
  const testToken = 'fake-id-token';

  // Helper – tracks whether firestoreDelete was invoked and for which uid
  String? deletedUid;
  Future<void> fakeFirestoreDelete(String uid) async {
    deletedUid = uid;
  }

  setUp(() {
    deletedUid = null; // reset between tests
  });

  // ── 1. Happy path ──────────────────────────────────────────────────────────
  test('deleteUser_success — HTTP 200 + Firestore deleted', () async {
    final mockClient = MockClient((request) async {
      // Verify the request is well-formed
      expect(request.url.toString(),
          contains('instachef-backend.vercel.app/api/delete-user'));
      expect(request.headers['Authorization'], 'Bearer $testToken');
      expect(jsonDecode(request.body)['uid'], testUid);

      return http.Response('{"message":"deleted"}', 200);
    });

    final result = await deleteUserLogic(
      isAdmin: true,
      uid: testUid,
      idToken: testToken,
      httpClient: mockClient,
      firestoreDelete: fakeFirestoreDelete,
    );

    print('\n[TEST 1] ✅ Happy path');
    print('  firestoreDeleted : ${result.firestoreDeleted}');
    print('  authError        : ${result.authError}');
    print('  message          : ${result.userFacingMessage}');

    expect(result.firestoreDeleted, isTrue,
        reason: 'Firestore doc should be deleted on success');
    expect(result.authError, isNull,
        reason: 'No auth error expected on HTTP 200');
    expect(deletedUid, equals(testUid),
        reason: 'firestoreDelete must be called with the correct uid');
    expect(result.userFacingMessage, equals('User deleted successfully'));
    expect(result.wasSuccessful, isTrue);
  });

  // ── 2. Backend failure — Firestore still deleted ───────────────────────────
  test('deleteUser_backendFailure — HTTP 500 but Firestore still deleted', () async {
    final mockClient = MockClient((_) async =>
        http.Response('{"error":"unauthorized"}', 500));

    final result = await deleteUserLogic(
      isAdmin: true,
      uid: testUid,
      idToken: testToken,
      httpClient: mockClient,
      firestoreDelete: fakeFirestoreDelete,
    );

    print('\n[TEST 2] ⚠️  Backend failure');
    print('  firestoreDeleted : ${result.firestoreDeleted}');
    print('  authError        : ${result.authError}');
    print('  message          : ${result.userFacingMessage}');

    expect(result.firestoreDeleted, isTrue,
        reason: 'Firestore must be deleted even if backend fails');
    expect(result.authError, contains('500'),
        reason: 'authError should capture the backend status code');
    expect(deletedUid, equals(testUid));
    expect(result.wasSuccessful, isFalse,
        reason: 'Partial success — auth not removed but doc is gone');
    expect(result.userFacingMessage, contains('Auth cleanup pending'));
  });

  // ── 3. Backend timeout — Firestore still deleted ───────────────────────────
  test('deleteUser_backendTimeout — exception but Firestore still deleted', () async {
    final mockClient = MockClient((_) async =>
        throw Exception('Connection timed out'));

    final result = await deleteUserLogic(
      isAdmin: true,
      uid: testUid,
      idToken: testToken,
      httpClient: mockClient,
      firestoreDelete: fakeFirestoreDelete,
    );

    print('\n[TEST 3] ⏱  Backend timeout');
    print('  firestoreDeleted : ${result.firestoreDeleted}');
    print('  authError        : ${result.authError}');
    print('  message          : ${result.userFacingMessage}');

    expect(result.firestoreDeleted, isTrue);
    expect(result.authError, isNotNull,
        reason: 'Exception should be captured as authError');
    expect(result.authError, contains('timed out'));
    expect(deletedUid, equals(testUid));
  });

  // ── 4. Non-admin blocked ───────────────────────────────────────────────────
  test('deleteUser_nonAdmin — blocked, no HTTP or Firestore call', () async {
    bool httpCalled = false;
    final mockClient = MockClient((_) async {
      httpCalled = true; // should never reach here
      return http.Response('ok', 200);
    });

    final result = await deleteUserLogic(
      isAdmin: false, // ← not an admin
      uid: testUid,
      idToken: testToken,
      httpClient: mockClient,
      firestoreDelete: (uid) async {
        fail('firestoreDelete must NOT be called for non-admin');
      },
    );

    print('\n[TEST 4] 🔒 Non-admin guard');
    print('  firestoreDeleted : ${result.firestoreDeleted}');
    print('  authError        : ${result.authError}');

    expect(result.firestoreDeleted, isFalse);
    expect(result.authError, contains('Permission denied'));
    expect(httpCalled, isFalse, reason: 'HTTP must NOT be called for non-admin');
    expect(deletedUid, isNull, reason: 'Firestore must NOT be touched for non-admin');
  });

  // ── 5. Correct uid is sent to backend ─────────────────────────────────────
  test('deleteUser_correctUidSentToBackend', () async {
    String? capturedUid;

    final mockClient = MockClient((request) async {
      capturedUid = jsonDecode(request.body)['uid'] as String?;
      return http.Response('{"message":"deleted"}', 200);
    });

    await deleteUserLogic(
      isAdmin: true,
      uid: 'specific_uid_999',
      idToken: testToken,
      httpClient: mockClient,
      firestoreDelete: fakeFirestoreDelete,
    );

    print('\n[TEST 5] 🎯 Correct UID to backend');
    print('  uid sent: $capturedUid');

    expect(capturedUid, equals('specific_uid_999'),
        reason: 'Backend must receive the exact uid being deleted');
  });
}
