import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<void> deleteUserFromVercel(String targetUid) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final idToken = await user.getIdToken();
  final url = Uri.parse('https://instachef-backend.vercel.app/api/delete-user');
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $idToken",
    },
    body: jsonEncode({"uid": targetUid}),
  );

  if (response.statusCode == 200) {
    print("✅ User deleted: ${response.body}");
  } else {
    print("❌ Failed: ${response.body}");
  }
}
