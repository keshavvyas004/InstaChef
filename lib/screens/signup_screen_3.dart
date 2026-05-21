// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:typed_data';
//
// class SignUp3 extends StatefulWidget {
//   const SignUp3({super.key});
//
//   @override
//   State<SignUp3> createState() => _SignUp3State();
// }
//
// class _SignUp3State extends State<SignUp3> {
//   File? _profileImage;
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _usernameController = TextEditingController();
//
//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 50,
//       );
//       if (pickedFile != null) {
//         // Create a File object from the path
//         File imageFile = File(pickedFile.path);
//
//         // Check if the file exists before setting it
//         bool fileExists = await imageFile.exists();
//         if (fileExists) {
//           setState(() {
//             _profileImage = imageFile;
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to read image file from path.')),
//           );
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to pick image: $e')),
//       );
//     }
//   }
//
//   Future<void> _saveUserData() async {
//     // Basic validation checks
//     if (_usernameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a username.')),
//       );
//       return;
//     }
//
//     // Check if the file exists and is not null before proceeding
//     if (_profileImage == null || !await _profileImage!.exists()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a valid profile image.')),
//       );
//       return;
//     }
//
//     // Show a loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );
//
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         throw Exception("User is not logged in.");
//       }
//
//       String? imageUrl;
//
//       // Read the image file as bytes
//       Uint8List imageData = await _profileImage!.readAsBytes();
//
//       // Upload image data to Firebase Storage
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('user_profiles')
//           .child('${user.uid}.jpg');
//
//       // Use putData to upload the byte stream directly
//       await storageRef.putData(imageData);
//       imageUrl = await storageRef.getDownloadURL();
//
//       // Save user data to Cloud Firestore
//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'username': _usernameController.text.trim(),
//         'profileImageUrl': imageUrl,
//         'email': user.email,
//         'uid': user.uid,
//       });
//
//       // Dismiss the loading dialog
//       if (mounted) {
//         Navigator.of(context).pop();
//       }
//
//       // Navigate to the home screen on success
//       if (mounted) {
//         Navigator.pushReplacementNamed(context, 'home');
//       }
//     } catch (e) {
//       // Dismiss the loading dialog and show an error
//       if (mounted) {
//         Navigator.of(context).pop();
//       }
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save user data: $e')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _usernameController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
//       appBar: AppBar(
//         toolbarHeight: 60,
//         backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
//         title: Text(
//           'InstaChef',
//           style: GoogleFonts.cookie(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 0.5,
//             fontSize: 40,
//           ),
//         ),
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.only(
//             top: MediaQuery.of(context).size.height * 0.1,
//             left: MediaQuery.of(context).size.width * 0.05,
//             right: MediaQuery.of(context).size.width * 0.05,
//           ),
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//               Container(
//                 padding: EdgeInsets.symmetric(
//                   vertical: MediaQuery.of(context).size.height * 0.02,
//                   horizontal: MediaQuery.of(context).size.width * 0.05,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color.fromRGBO(15, 29, 37, 1),
//                   borderRadius: BorderRadius.circular(40),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Sign Up',
//                       style: GoogleFonts.cookie(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 40,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//
//                     GestureDetector(
//                       onTap: _pickImage,
//                       child: Stack(
//                         children: [
//                           CircleAvatar(
//                             radius: 80,
//                             backgroundColor: Colors.white,
//                             backgroundImage: _profileImage != null
//                                 ? FileImage(_profileImage!)
//                                 : null,
//                             child: _profileImage == null
//                                 ? const Icon(
//                               Icons.camera_alt,
//                               size: 40,
//                               color: Colors.grey,
//                             )
//                                 : null,
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: CircleAvatar(
//                               radius: 15,
//                               backgroundColor: const Color.fromRGBO(
//                                 247,
//                                 158,
//                                 27,
//                                 1,
//                               ),
//                               child: const Icon(
//                                 Icons.edit,
//                                 size: 15,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 50),
//
//                     TextField(
//                       controller: _usernameController,
//                       decoration: const InputDecoration(
//                         prefixIcon: Icon(Icons.person),
//                         prefixIconColor: Colors.black,
//                         fillColor: Colors.white,
//                         filled: true,
//                         border: OutlineInputBorder(),
//                         hintText: "Username:",
//                       ),
//                     ),
//
//                     const SizedBox(height: 30),
//
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: const Size(200, 40),
//                         backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       onPressed: _saveUserData,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           Text(
//                             'Sign Up',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.5,
//                               fontSize: 30,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: const Size(200, 40),
//                         backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.pushReplacementNamed(context, 'register_2');
//                       },
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           Icon(Icons.arrow_back, size: 35, color: Colors.white),
//                           SizedBox(width: 20),
//                           Text(
//                             'Back',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.5,
//                               fontSize: 30,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:instachef/widgets/onboarding_progress_bar.dart';

class SignUp3 extends StatefulWidget {
  const SignUp3({super.key});

  @override
  State<SignUp3> createState() => _SignUp3State();
}

class _SignUp3State extends State<SignUp3> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _usernameController = TextEditingController();

  // --- CLOUDINARY CONFIGURATION ---
  final String _cloudName = 'da0i4vauf';
  // Updated with your Cloudinary upload preset
  final String _uploadPreset = 'flutter_profiles';
  // ---------------------------------

  Future<void> _requestPermissions() async {
    final status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission denied. Cannot access gallery.'),
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      await _requestPermissions();

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        bool fileExists = await imageFile.exists();
        if (fileExists) {
          setState(() {
            _profileImage = imageFile;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to read image file from path.'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _saveUserData() async {
    if (_usernameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a username.')),
        );
      }
      return;
    }

    if (_profileImage == null || !await _profileImage!.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a valid profile image.')),
        );
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not logged in.");
      }

      String? imageUrl;

      // --- CLOUDINARY UPLOAD LOGIC ---
      Uri uploadUrl = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      var request = http.MultipartRequest('POST', uploadUrl)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath('file', _profileImage!.path),
        );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        imageUrl = result['secure_url']; // Get the URL from the response
      } else {
        throw Exception(
          'Failed to upload image to Cloudinary: ${response.body}',
        );
      }
      // ---------------------------------

      // --- FIREBASE FIRESTORE LOGIC (UNMODIFIED) ---
      // Save the user data with the Cloudinary image URL
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': _usernameController.text.trim(),
        'profileImageUrl': imageUrl,
        'email': user.email,
        'uid': user.uid,
      });
      // ----------------------------------------------

      if (mounted) {
        Navigator.of(context).pop();
        Navigator.pushReplacementNamed(context, 'home');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save user data: $e')));
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('images/logo.png', height: 100, width: 100),
                const SizedBox(height: 16),
                Text(
                  'InstaChef',
                  style: GoogleFonts.cookie(
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 10),
                const OnboardingProgressBar(currentStep: 3, totalSteps: 3),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Sign Up',
                        style: GoogleFonts.cookie(
                          color: const Color.fromRGBO(15, 29, 37, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? const Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: const Color.fromRGBO(
                                  247,
                                  158,
                                  27,
                                  1,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          prefixIconColor: Colors.black,
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                          hintText: "Username:",
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 56),
                          backgroundColor: const Color.fromRGBO(
                            247,
                            158,
                            27,
                            1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _saveUserData,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.arrow_forward,
                              size: 35,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 56),
                          backgroundColor: const Color.fromRGBO(
                            247,
                            158,
                            27,
                            1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, 'register_2');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.arrow_back,
                              size: 35,
                              color: Colors.white,
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
