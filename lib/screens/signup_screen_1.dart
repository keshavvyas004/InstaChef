// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class SignUp1 extends StatefulWidget {
//   const SignUp1({super.key});
//
//   @override
//   State<SignUp1> createState() => _SignUp1State();
// }
//
// class _SignUp1State extends State<SignUp1> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _dobController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
//
//   void _navigateToSignUp2() {
//     if (_nameController.text.isEmpty || _dobController.text.isEmpty || _phoneController.text.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please fill in all fields.')),
//         );
//       }
//       return;
//     }
//
//     if (mounted) {
//       Navigator.pushReplacementNamed(
//         context,
//         'register_2',
//         arguments: {
//           'name': _nameController.text.trim(),
//           'dob': _dobController.text.trim(),
//           'phone': _phoneController.text.trim(),
//         },
//       );
//     }
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
//             color: const Color.fromARGB(255, 0, 0, 0),
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
//                 padding: EdgeInsets.only(
//                   top: MediaQuery.of(context).size.height * 0.02,
//                   left: MediaQuery.of(context).size.width * 0.02,
//                   right: MediaQuery.of(context).size.width * 0.02,
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
//                         color: const Color.fromRGBO(255, 255, 255, 1),
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                         fontSize: 40,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     TextField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(
//                         prefixIconColor: Color.fromRGBO(0, 0, 0, 1),
//                         suffixIconColor: Color.fromRGBO(0, 0, 0, 1),
//                         fillColor: Color.fromRGBO(255, 255, 255, 1),
//                         filled: true,
//                         border: OutlineInputBorder(),
//                         hintText: "Name:",
//                         prefixIcon: Icon(Icons.verified_user),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     TextField(
//                       controller: _dobController,
//                       decoration: const InputDecoration(
//                         prefixIconColor: Color.fromRGBO(0, 0, 0, 1),
//                         suffixIconColor: Color.fromRGBO(0, 0, 0, 1),
//                         fillColor: Color.fromRGBO(255, 255, 255, 1),
//                         filled: true,
//                         border: OutlineInputBorder(),
//                         hintText: "Date Of Birth:",
//                         prefixIcon: Icon(Icons.calendar_today),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     TextField(
//                       controller: _phoneController,
//                       decoration: const InputDecoration(
//                         prefixIconColor: Color.fromRGBO(0, 0, 0, 1),
//                         suffixIconColor: Color.fromRGBO(0, 0, 0, 1),
//                         fillColor: Color.fromRGBO(255, 255, 255, 1),
//                         filled: true,
//                         border: const OutlineInputBorder(),
//                         hintText: "Phone Number",
//                         prefixIcon: Icon(Icons.phone),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: const Size(200, 40),
//                         backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       onPressed: _navigateToSignUp2,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           Text(
//                             'Next',
//                             style: TextStyle(
//                               color: Color.fromRGBO(255, 255, 255, 1),
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.5,
//                               fontSize: 30,
//                             ),
//                           ),
//                           SizedBox(width: 20),
//                           Icon(
//                             Icons.arrow_forward,
//                             size: 35,
//                             color: Color.fromRGBO(255, 255, 255, 1),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         minimumSize: const Size(200, 40),
//                         backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.pushReplacementNamed(context, 'login');
//                       },
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           Icon(
//                             Icons.arrow_back,
//                             size: 35,
//                             color: Color.fromRGBO(255, 255, 255, 1),
//                           ),
//                           SizedBox(width: 20),
//                           Text(
//                             'Back',
//                             style: TextStyle(
//                               color: Color.fromRGBO(255, 255, 255, 1),
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
//

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:instachef/widgets/onboarding_progress_bar.dart';

class SignUp1 extends StatefulWidget {
  const SignUp1({super.key});

  @override
  State<SignUp1> createState() => _SignUp1State();
}

class _SignUp1State extends State<SignUp1> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedCountryCode = '+91'; // Default India

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18), // Default: 18 years ago
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _navigateToSignUp2() {
    final phone = _phoneController.text.trim();

    if (_nameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (phone.length != 10 || int.tryParse(phone) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number.')),
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      'register_2',
      arguments: {
        'name': _nameController.text.trim(),
        'dob': _dobController.text.trim(),
        'phone': '$_selectedCountryCode $phone',
      },
    );
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
                const OnboardingProgressBar(currentStep: 1, totalSteps: 3),
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
                      // Name Field
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          prefixIconColor: Color.fromRGBO(0, 0, 0, 1),
                          fillColor: Color.fromRGBO(255, 255, 255, 1),
                          border: OutlineInputBorder(),
                          hintText: "Name:",
                          prefixIcon: Icon(Icons.verified_user),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Date of Birth (Calendar picker)
                      TextField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: const InputDecoration(
                          prefixIconColor: Color.fromRGBO(0, 0, 0, 1),
                          fillColor: Color.fromRGBO(255, 255, 255, 1),
                          border: OutlineInputBorder(),
                          hintText: "Date of Birth:",
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Country code picker + phone field
                      Row(
                        children: [
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black54),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CountryCodePicker(
                              onChanged: (code) {
                                setState(() {
                                  _selectedCountryCode = code.dialCode ?? '+91';
                                });
                              },
                              initialSelection: 'IN',
                              favorite: const ['+91', 'IN'],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              textStyle: const TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: const InputDecoration(
                                counterText: "",
                                prefixIconColor: Color.fromRGBO(0, 0, 0, 1),
                                fillColor: Color.fromRGBO(255, 255, 255, 1),
                                border: OutlineInputBorder(),
                                hintText: "Phone Number",
                                prefixIcon: Icon(Icons.phone),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      // Next Button
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
                        onPressed: _navigateToSignUp2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Next',
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
                      // Back Button
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
                          Navigator.pushReplacementNamed(context, 'login');
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
