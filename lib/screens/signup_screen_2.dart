/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp2 extends StatefulWidget {
  const SignUp2({super.key});

  @override
  State<SignUp2> createState() => _SignUp2State();
}

class _SignUp2State extends State<SignUp2> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _seePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    // Check if passwords match
    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
      }
      return;
    }

    // Show a loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // Create a new user with Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Get the current user
      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed.");
      }

      // Retrieve the data passed from the previous screen
      final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': args['name'],
        'dateOfBirth': args['dob'],
        'phoneNumber': args['phone'],
      });

      // Dismiss the loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to the next page on success
      if (mounted) {
        Navigator.pushReplacementNamed(context, 'register_3');
      }
    } on FirebaseAuthException catch (e) {
      // Dismiss the loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }

      // Show the error message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // Dismiss the loading dialog for any other errors
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        title: Text(
          'InstaChef',
          style: GoogleFonts.cookie(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 40,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02,
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(15, 29, 37, 1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    Text(
                      'Sign Up',
                      style: GoogleFonts.cookie(
                        color: const Color.fromRGBO(255, 255, 255, 1),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIconColor: Color.fromRGBO(0, 0, 0, 1),
                        suffixIconColor: Color.fromRGBO(0, 0, 0, 1),
                        fillColor: Color.fromRGBO(255, 255, 255, 1),
                        filled: true,
                        border: OutlineInputBorder(),
                        hintText: "Email:",
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: passwordController,
                      obscureText: _seePassword,
                      decoration: InputDecoration(
                        prefixIconColor: const Color.fromRGBO(0, 0, 0, 1),
                        suffixIconColor: const Color.fromRGBO(0, 0, 0, 1),
                        fillColor: const Color.fromRGBO(255, 255, 255, 1),
                        filled: true,
                        border: const OutlineInputBorder(),
                        hintText: "Password:",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _seePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _seePassword = !_seePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: _seePassword,
                      decoration: InputDecoration(
                        prefixIconColor: const Color.fromRGBO(0, 0, 0, 1),
                        suffixIconColor: const Color.fromRGBO(0, 0, 0, 1),
                        fillColor: const Color.fromRGBO(255, 255, 255, 1),
                        filled: true,
                        border: const OutlineInputBorder(),
                        hintText: "Confirm Password:",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _seePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _seePassword = !_seePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 40),
                        backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        signUp();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Next',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              fontSize: 30,
                            ),
                          ),
                          SizedBox(width: 20),
                          Icon(
                            Icons.arrow_forward,
                            size: 35,
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 40),
                        backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, 'register_1');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.arrow_back,
                            size: 35,
                            color: Color.fromRGBO(255, 255, 255, 1),
                          ),
                          SizedBox(width: 20),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instachef/services/email_service.dart';
import 'package:instachef/widgets/onboarding_progress_bar.dart';

class SignUp2 extends StatefulWidget {
  const SignUp2({super.key});

  @override
  State<SignUp2> createState() => _SignUp2State();
}

class _SignUp2State extends State<SignUp2> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final EmailService _emailService = EmailService();

  bool _seePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    // Check if passwords match
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
      }
      return;
    }

    // Show a loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // Create a new user with Firebase Authentication
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Get the current user
      final User? user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed.");
      }

      // Retrieve the data passed from the previous screen
      final Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      // Save user data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': args['name'],
        'dateOfBirth': args['dob'],
        'phoneNumber': args['phone'],
      });

      // Check if the welcome email was sent successfully
      final bool emailSent = await _emailService.sendWelcomeEmail(
        user.email!,
        args['name'],
      );

      if (!emailSent) {
        // Show a warning if the email failed to send
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created, but failed to send welcome email.',
              ),
            ),
          );
        }
      }

      // Dismiss the loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to the next page on success
      if (mounted) {
        Navigator.pushReplacementNamed(context, 'register_3');
      }
    } on FirebaseAuthException catch (e) {
      // Dismiss the loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }

      // Show the error message to the user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      // Dismiss the loading dialog for any other errors
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
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
                // App Logo and Title
                // App Logo and Title
                const SizedBox(height: 20),
                Image.asset('images/logo.png', height: 100, width: 100),
                const SizedBox(height: 16),
                Text(
                  'InstaChef',
                  style: GoogleFonts.cookie(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 10),
                const OnboardingProgressBar(currentStep: 2, totalSteps: 3),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Sign Up',
                        style: GoogleFonts.cookie(
                          color: const Color.fromRGBO(15, 29, 37, 1),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontSize: 40,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          prefixIconColor: Color.fromRGBO(0, 0, 0, 1),
                          suffixIconColor: Color.fromRGBO(0, 0, 0, 1),
                          fillColor: Color.fromRGBO(255, 255, 255, 1),
                          filled: true,
                          border: OutlineInputBorder(),
                          hintText: "Email:",
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: passwordController,
                        obscureText: _seePassword,
                        decoration: InputDecoration(
                          prefixIconColor: const Color.fromRGBO(0, 0, 0, 1),
                          suffixIconColor: const Color.fromRGBO(0, 0, 0, 1),
                          fillColor: const Color.fromRGBO(255, 255, 255, 1),
                          filled: true,
                          border: const OutlineInputBorder(),
                          hintText: "Password:",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _seePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _seePassword = !_seePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: _seePassword,
                        decoration: InputDecoration(
                          prefixIconColor: const Color.fromRGBO(0, 0, 0, 1),
                          suffixIconColor: const Color.fromRGBO(0, 0, 0, 1),
                          fillColor: const Color.fromRGBO(255, 255, 255, 1),
                          filled: true,
                          border: const OutlineInputBorder(),
                          hintText: "Confirm Password:",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _seePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _seePassword = !_seePassword;
                              });
                            },
                          ),
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
                        onPressed: () {
                          signUp();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Next',
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 30,
                              ),
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.arrow_forward,
                              size: 35,
                              color: Color.fromRGBO(255, 255, 255, 1),
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
                          Navigator.pushReplacementNamed(context, 'register_1');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.arrow_back,
                              size: 35,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            SizedBox(width: 20),
                            Text(
                              'Back',
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16), // Reduced from 20
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
