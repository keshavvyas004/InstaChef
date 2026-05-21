// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_core/firebase_core.dart';
// // // import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
// // // import 'package:google_fonts/google_fonts.dart';
// // //
// // // import 'package:instachef/screens/login_screen.dart';
// // // import 'package:instachef/screens/home_screen.dart'; // Your main screen after login
// // // import 'package:instachef/screens/search_screen.dart';
// // // import 'package:instachef/screens/post_screen.dart';
// // // import 'package:instachef/screens/profile_screen.dart';
// // // import 'package:instachef/screens/signup_screen_1.dart';
// // // import 'package:instachef/screens/signup_screen_2.dart';
// // // import 'package:instachef/screens/signup_screen_3.dart';
// // //
// // // Future<void> main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //   await Firebase.initializeApp();
// // //   print("Firebase is initialized");
// // //   runApp(const MyApp());
// // // }
// // //
// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       debugShowCheckedModeBanner: false,
// // //       title: 'InstaChef',
// // //       theme: ThemeData(canvasColor: const Color.fromRGBO(15, 29, 37, 1)),
// // //       // The `home` property now points to the AuthWrapper
// // //       home: const AuthWrapper(),
// // //       routes: {
// // //         'login': (context) => const MyLogin(),
// // //         'home': (context) => const MainNavigationScreen(),
// // //         'register_1': (context) => const SignUp1(),
// // //         'register_2': (context) => const SignUp2(),
// // //         'register_3': (context) => const SignUp3(),
// // //       },
// // //     );
// // //   }
// // // }
// // //
// // // // This new widget manages the authentication state
// // // class AuthWrapper extends StatelessWidget {
// // //   const AuthWrapper({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // The StreamBuilder listens to changes in Firebase Authentication state
// // //     return StreamBuilder<User?>(
// // //       stream: FirebaseAuth.instance.authStateChanges(),
// // //       builder: (context, snapshot) {
// // //         // If the snapshot has data, a user is logged in
// // //         if (snapshot.hasData) {
// // //           // You can navigate to your main app screen here
// // //           return const MainNavigationScreen();
// // //         } else {
// // //           // No user is logged in, show the login screen
// // //           return const MyLogin();
// // //         }
// // //       },
// // //     );
// // //   }
// // // }
// // //
// // // class MainNavigationScreen extends StatefulWidget {
// // //   const MainNavigationScreen({super.key});
// // //
// // //   @override
// // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // }
// // //
// // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // //   int _selectedIndex = 0;
// // //
// // //   static const List<Widget> _widgetOptions = <Widget>[
// // //     HomeScreen(),
// // //     MySearchScreen(),
// // //     RecipePostScreen(),
// // //     ProfileScreen(),
// // //   ];
// // //
// // //   void _onItemTapped(int index) {
// // //     setState(() {
// // //       _selectedIndex = index;
// // //     });
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         toolbarHeight: 60,
// // //         backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
// // //         title: Text(
// // //           'InstaChef',
// // //           style: GoogleFonts.cookie(
// // //             color: Colors.white,
// // //             fontWeight: FontWeight.bold,
// // //             letterSpacing: 0.5,
// // //             fontSize: 40,
// // //           ),
// // //         ),
// // //         automaticallyImplyLeading: false,
// // //       ),
// // //       body: Center(
// // //         child: IndexedStack(index: _selectedIndex, children: _widgetOptions),
// // //       ),
// // //       bottomNavigationBar: Theme(
// // //         data: Theme.of(context).copyWith(
// // //           splashFactory: NoSplash.splashFactory,
// // //           highlightColor: Colors.transparent,
// // //           hoverColor: Colors.transparent,
// // //         ),
// // //         child: BottomNavigationBar(
// // //           backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
// // //           selectedItemColor: const Color.fromRGBO(247, 158, 27, 1),
// // //           unselectedItemColor: Colors.white,
// // //           items: const <BottomNavigationBarItem>[
// // //             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
// // //             BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
// // //             BottomNavigationBarItem(
// // //               icon: Icon(Icons.add_box_outlined),
// // //               label: 'Post',
// // //             ),
// // //             BottomNavigationBarItem(
// // //               icon: Icon(Icons.person_outline),
// // //               label: 'Profile',
// // //             ),
// // //           ],
// // //           currentIndex: _selectedIndex,
// // //           onTap: _onItemTapped,
// // //           type: BottomNavigationBarType.fixed,
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // /*
// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:google_fonts/google_fonts.dart';
// //
// // import 'package:instachef/screens/login_screen.dart';
// // import 'package:instachef/screens/home_screen.dart';
// // import 'package:instachef/screens/search_screen.dart';
// // import 'package:instachef/screens/post_screen.dart';
// // import 'package:instachef/screens/profile_screen.dart';
// // import 'package:instachef/screens/signup_screen_1.dart';
// // import 'package:instachef/screens/signup_screen_2.dart';
// // import 'package:instachef/screens/signup_screen_3.dart';
// //
// // import 'firebase_options.dart';
// //
// // // The main entry point for the application.
// // void main() async {
// //   // Ensures that the Flutter widget binding is initialized.
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   // Initialize Firebase for the app.
// //   await Firebase.initializeApp(
// //     options: DefaultFirebaseOptions.currentPlatform,
// //   );
// //
// //   // Run the app.
// //   runApp(const MyApp());
// // }
// //
// // // Main application widget.
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'InstaChef',
// //       theme: ThemeData(canvasColor: const Color.fromRGBO(15, 29, 37, 1)),
// //
// //       // The `home` property now points to the AuthWrapper
// //       home: const AuthWrapper(),
// //
// //       // Define the named routes for navigation.
// //       routes: {
// //         // Corrected class names to match your other files
// //         'login': (context) => const MyLogin(),
// //         'home': (context) => const MainNavigationScreen(),
// //         'register_1': (context) => const SignUp1(),
// //         'register_2': (context) => const SignUp2(),
// //         'register_3': (context) => const SignUp3(),
// //       },
// //     );
// //   }
// // }
// //
// // // This new widget manages the authentication state
// // class AuthWrapper extends StatelessWidget {
// //   const AuthWrapper({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     // The StreamBuilder listens to changes in Firebase Authentication state
// //     return StreamBuilder<User?>(
// //       stream: FirebaseAuth.instance.authStateChanges(),
// //       builder: (context, snapshot) {
// //         // If the snapshot has data, a user is logged in
// //         if (snapshot.hasData) {
// //           // You can navigate to your main app screen here
// //           return const MainNavigationScreen();
// //         } else {
// //           // No user is logged in, show the login screen
// //           // Corrected class name
// //           return const MyLogin();
// //         }
// //       },
// //     );
// //   }
// // }
// //
// // class MainNavigationScreen extends StatefulWidget {
// //   const MainNavigationScreen({super.key});
// //
// //   @override
// //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // }
// //
// // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// //   int _selectedIndex = 0;
// //
// //   static const List<Widget> _widgetOptions = <Widget>[
// //     HomeScreen(),
// //     MySearchScreen(),
// //     RecipePostScreen(),
// //     ProfileScreen(),
// //   ];
// //
// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         toolbarHeight: 60,
// //         backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
// //         title: Text(
// //           'InstaChef',
// //           style: GoogleFonts.cookie(
// //             color: Colors.white,
// //             fontWeight: FontWeight.bold,
// //             letterSpacing: 0.5,
// //             fontSize: 40,
// //           ),
// //         ),
// //         automaticallyImplyLeading: false,
// //       ),
// //       body: Center(
// //         child: IndexedStack(index: _selectedIndex, children: _widgetOptions),
// //       ),
// //       bottomNavigationBar: Theme(
// //         data: Theme.of(context).copyWith(
// //           splashFactory: NoSplash.splashFactory,
// //           highlightColor: Colors.transparent,
// //           hoverColor: Colors.transparent,
// //         ),
// //         child: BottomNavigationBar(
// //           backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
// //           selectedItemColor: const Color.fromRGBO(247, 158, 27, 1),
// //           unselectedItemColor: Colors.white,
// //           items: const <BottomNavigationBarItem>[
// //             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
// //             BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.add_box_outlined),
// //               label: 'Post',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.person_outline),
// //               label: 'Profile',
// //             ),
// //           ],
// //           currentIndex: _selectedIndex,
// //           onTap: _onItemTapped,
// //           type: BottomNavigationBarType.fixed,
// //         ),
// //       ),
// //     );
// //   }
// // }
// //  */
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_core/firebase_core.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // // import 'package:instachef/screens/login_screen.dart';
// // // import 'package:instachef/screens/home_screen.dart';
// // // import 'package:instachef/screens/search_screen.dart';
// // // import 'package:instachef/screens/post_screen.dart';
// // // import 'package:instachef/screens/profile_screen.dart';
// // // import 'package:instachef/screens/signup_screen_1.dart';
// // // import 'package:instachef/screens/signup_screen_2.dart';
// // // import 'package:instachef/screens/signup_screen_3.dart';
// // // import 'package:instachef/admin/AdminDashBoardScreen.dart';
// // // import 'package:instachef/screens/ai_recipe_generator.dart';
// //
// // // import 'firebase_options.dart';
// //
// // // // The main entry point for the application.
// // // void main() async {
// // //   // Ensures that the Flutter widget binding is initialized.
// // //   WidgetsFlutterBinding.ensureInitialized();
// //
// // //   // Initialize Firebase for the app.
// // //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// //
// // //   // Run the app.
// // //   runApp(const MyApp());
// // // }
// //
// // // // Main application widget.
// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});
// //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       debugShowCheckedModeBanner: false,
// // //       title: 'InstaChef',
// // //       theme: ThemeData(canvasColor: const Color.fromRGBO(15, 29, 37, 1)),
// //
// // //       // The `home` property now points to the AuthWrapper
// // //       home: const AuthWrapper(),
// //
// // //       // Define the named routes for navigation.
// // //       routes: {
// // //         // Corrected class names to match your other files
// // //         'login': (context) => const MyLogin(),
// // //         'home': (context) => const MainNavigationScreen(),
// // //         'register_1': (context) => const SignUp1(),
// // //         'register_2': (context) => const SignUp2(),
// // //         'register_3': (context) => const SignUp3(),
// // //       },
// // //     );
// // //   }
// // // }
// //
// // // // This new widget manages the authentication state
// // // class AuthWrapper extends StatelessWidget {
// // //   const AuthWrapper({super.key});
// //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // The StreamBuilder listens to changes in Firebase Authentication state
// // //     return StreamBuilder<User?>(
// // //       stream: FirebaseAuth.instance.authStateChanges(),
// // //       builder: (context, snapshot) {
// // //         // If the snapshot has data, a user is logged in
// // //         if (snapshot.hasData) {
// // //           // You can navigate to your main app screen here
// // //           return const MainNavigationScreen();
// // //         } else {
// // //           // No user is logged in, show the login screen
// // //           // Corrected class name
// // //           return const MyLogin();
// // //         }
// // //       },
// // //     );
// // //   }
// // // }
// //
// // // class MainNavigationScreen extends StatefulWidget {
// // //   const MainNavigationScreen({super.key});
// //
// // //   @override
// // //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // // }
// //
// // // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// // //   int _selectedIndex = 0;
// // //   bool _isAdmin = false;
// //
// // //   static const List<Widget> _widgetOptions = <Widget>[
// // //     HomeScreen(),
// // //     MySearchScreen(),
// // //     RecipePostScreen(),
// // //     AiRecipeGeneratorPage(),
// // //     ProfileScreen(),
// // //   ];
// //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _checkAdminStatus();
// // //   }
// //
// // //   void _checkAdminStatus() async {
// // //     final user = FirebaseAuth.instance.currentUser;
// // //     if (user != null) {
// // //       final userDoc = await FirebaseFirestore.instance
// // //           .collection('users')
// // //           .doc(user.uid)
// // //           .get();
// // //       if (userDoc.exists) {
// // //         final data = userDoc.data();
// // //         if (data != null && data['isAdmin'] == true) {
// // //           if (mounted) {
// // //             setState(() {
// // //               _isAdmin = true;
// // //             });
// // //           }
// // //         }
// // //       }
// // //     }
// // //   }
// //
// // //   void _onItemTapped(int index) {
// // //     setState(() {
// // //       _selectedIndex = index;
// // //     });
// // //   }
// //
// // //   void _goToAdminDashboard() {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
// // //     );
// // //   }
// //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         toolbarHeight: 60,
// // //         backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
// // //         title: Text(
// // //           'InstaChef',
// // //           style: GoogleFonts.cookie(
// // //             color: Colors.white,
// // //             fontWeight: FontWeight.bold,
// // //             letterSpacing: 0.5,
// // //             fontSize: 40,
// // //           ),
// // //         ),
// // //         automaticallyImplyLeading: false,
// // //         actions: _isAdmin
// // //             ? [
// // //                 IconButton(
// // //                   icon: const Icon(
// // //                     Icons.admin_panel_settings,
// // //                     color: Color.fromRGBO(247, 158, 27, 1),
// // //                   ),
// // //                   onPressed: _goToAdminDashboard,
// // //                 ),
// // //               ]
// // //             : null,
// // //       ),
// // //       body: Center(
// // //         child: IndexedStack(index: _selectedIndex, children: _widgetOptions),
// // //       ),
// // //       bottomNavigationBar: Theme(
// // //         data: Theme.of(context).copyWith(
// // //           splashFactory: NoSplash.splashFactory,
// // //           highlightColor: Colors.transparent,
// // //           hoverColor: Colors.transparent,
// // //         ),
// // //         child: BottomNavigationBar(
// // //           backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
// // //           selectedItemColor: const Color.fromRGBO(247, 158, 27, 1),
// // //           unselectedItemColor: Colors.white,
// // //           items: const <BottomNavigationBarItem>[
// // //             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
// // //             BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
// // //             BottomNavigationBarItem(
// // //               icon: Icon(Icons.add_box_outlined),
// // //               label: 'Post',
// // //             ),
// // //             BottomNavigationBarItem(
// // //               icon: Icon(Icons.auto_awesome),
// // //               label: 'AI Chef',
// // //             ),
// // //             BottomNavigationBarItem(
// // //               icon: Icon(Icons.person_outline),
// // //               label: 'Profile',
// // //             ),
// // //           ],
// // //           currentIndex: _selectedIndex,
// // //           onTap: _onItemTapped,
// // //           type: BottomNavigationBarType.fixed,
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // import 'package:instachef/screens/login_screen.dart';
// // import 'package:instachef/screens/home_screen.dart';
// // import 'package:instachef/screens/search_screen.dart';
// // import 'package:instachef/screens/post_screen.dart';
// // import 'package:instachef/screens/profile_screen.dart';
// // import 'package:instachef/screens/signup_screen_1.dart';
// // import 'package:instachef/screens/signup_screen_2.dart';
// // import 'package:instachef/screens/signup_screen_3.dart';
// // import 'package:instachef/admin/AdminDashBoardScreen.dart';
// // import 'package:instachef/screens/ai_recipe_generator.dart';
// //
// // import 'firebase_options.dart';
// //
// // // Entry point
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// //   runApp(const MyApp());
// // }
// //
// // // Main app widget
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       title: 'InstaChef',
// //       theme: ThemeData(canvasColor: const Color.fromRGBO(15, 29, 37, 1)),
// //       home: const AuthWrapper(),
// //       routes: {
// //         'login': (context) => const MyLogin(),
// //         'home': (context) => const MainNavigationScreen(),
// //         'register_1': (context) => const SignUp1(),
// //         'register_2': (context) => const SignUp2(),
// //         'register_3': (context) => const SignUp3(),
// //       },
// //     );
// //   }
// // }
// //
// // // AuthWrapper: decides whether to show login or main navigation
// // class AuthWrapper extends StatelessWidget {
// //   const AuthWrapper({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return StreamBuilder<User?>(
// //       stream: FirebaseAuth.instance.authStateChanges(),
// //       builder: (context, snapshot) {
// //         // Show loader while waiting for Firebase to check auth state
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Scaffold(
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }
// //
// //         if (snapshot.hasData) {
// //           // User is logged in
// //           return const MainNavigationScreen();
// //         } else {
// //           // No user logged in
// //           return const MyLogin();
// //         }
// //       },
// //     );
// //   }
// // }
// //
// // // Bottom navigation main screen
// // class MainNavigationScreen extends StatefulWidget {
// //   const MainNavigationScreen({super.key});
// //
// //   @override
// //   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// // }
// //
// // class _MainNavigationScreenState extends State<MainNavigationScreen> {
// //   int _selectedIndex = 0;
// //   bool _isAdmin = false;
// //
// //   static const List<Widget> _widgetOptions = <Widget>[
// //     HomeScreen(),
// //     MySearchScreen(),
// //     RecipePostScreen(),
// //     AiRecipeGeneratorPage(),
// //     ProfileScreen(),
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkAdminStatus();
// //   }
// //
// //   Future<void> _checkAdminStatus() async {
// //     final user = FirebaseAuth.instance.currentUser;
// //     if (user != null) {
// //       final userDoc = await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(user.uid)
// //           .get();
// //       if (userDoc.exists) {
// //         final data = userDoc.data();
// //         if (data != null && data['isAdmin'] == true) {
// //           if (mounted) {
// //             setState(() {
// //               _isAdmin = true;
// //             });
// //           }
// //         }
// //       }
// //     }
// //   }
// //
// //   void _onItemTapped(int index) {
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //   }
// //
// //   void _goToAdminDashboard() {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         toolbarHeight: 60,
// //         backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
// //         title: Text(
// //           'InstaChef',
// //           style: GoogleFonts.cookie(
// //             color: Colors.white,
// //             fontWeight: FontWeight.bold,
// //             letterSpacing: 0.5,
// //             fontSize: 40,
// //           ),
// //         ),
// //         automaticallyImplyLeading: false,
// //         actions: _isAdmin
// //             ? [
// //                 IconButton(
// //                   icon: const Icon(
// //                     Icons.admin_panel_settings,
// //                     color: Color.fromRGBO(247, 158, 27, 1),
// //                   ),
// //                   onPressed: _goToAdminDashboard,
// //                 ),
// //               ]
// //             : null,
// //       ),
// //       body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
// //       bottomNavigationBar: Theme(
// //         data: Theme.of(context).copyWith(
// //           splashFactory: NoSplash.splashFactory,
// //           highlightColor: Colors.transparent,
// //           hoverColor: Colors.transparent,
// //         ),
// //         child: BottomNavigationBar(
// //           backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
// //           selectedItemColor: const Color.fromRGBO(247, 158, 27, 1),
// //           unselectedItemColor: Colors.white,
// //           items: const [
// //             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
// //             BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.add_box_outlined),
// //               label: 'Post',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.auto_awesome),
// //               label: 'AI Chef',
// //             ),
// //             BottomNavigationBarItem(
// //               icon: Icon(Icons.person_outline),
// //               label: 'Profile',
// //             ),
// //           ],
// //           currentIndex: _selectedIndex,
// //           onTap: _onItemTapped,
// //           type: BottomNavigationBarType.fixed,
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'package:instachef/screens/login_screen.dart';
// import 'package:instachef/screens/home_screen.dart';
// import 'package:instachef/screens/search_screen.dart';
// import 'package:instachef/screens/post_screen.dart';
// import 'package:instachef/screens/profile_screen.dart';
// import 'package:instachef/screens/signup_screen_1.dart';
// import 'package:instachef/screens/signup_screen_2.dart';
// import 'package:instachef/screens/signup_screen_3.dart';
// import 'package:instachef/admin/AdminDashBoardScreen.dart';
// import 'package:instachef/screens/ai_recipe_generator.dart';
//
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'InstaChef',
//       theme: ThemeData(canvasColor: const Color.fromRGBO(15, 29, 37, 1)),
//       home: const AuthWrapper(),
//       routes: {
//         'login': (context) => const MyLogin(),
//         'home': (context) => const MainNavigationScreen(),
//         'register_1': (context) => const SignUp1(),
//         'register_2': (context) => const SignUp2(),
//         'register_3': (context) => const SignUp3(),
//       },
//     );
//   }
// }
//
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // 🟡 While Firebase checks login state
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(color: Color(0xFFF79E1B)),
//             ),
//           );
//         }
//
//         // 🟢 Logged in user
//         if (snapshot.hasData) {
//           return const MainNavigationScreen();
//         }
//
//         // 🔴 Not logged in
//         return const MyLogin();
//       },
//     );
//   }
// }
//
// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});
//
//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }
//
// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _selectedIndex = 0;
//   bool _isAdmin = false;
//
//   static const List<Widget> _widgetOptions = <Widget>[
//     HomeScreen(),
//     MySearchScreen(),
//     RecipePostScreen(),
//     AiRecipeGeneratorPage(),
//     ProfileScreen(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _checkAdminStatus();
//   }
//
//   Future<void> _checkAdminStatus() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//         if (userDoc.exists && userDoc.data()?['isAdmin'] == true) {
//           if (mounted) {
//             setState(() => _isAdmin = true);
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("Error checking admin status: $e");
//     }
//   }
//
//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }
//
//   void _goToAdminDashboard() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 60,
//         backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
//         title: Text(
//           'InstaChef',
//           style: GoogleFonts.cookie(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 40,
//           ),
//         ),
//         automaticallyImplyLeading: false,
//         actions: _isAdmin
//             ? [
//           IconButton(
//             icon: const Icon(
//               Icons.admin_panel_settings,
//               color: Color(0xFFF79E1B),
//             ),
//             onPressed: _goToAdminDashboard,
//           ),
//         ]
//             : null,
//       ),
//       body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
//       bottomNavigationBar: Theme(
//         data: Theme.of(context).copyWith(
//           splashFactory: NoSplash.splashFactory,
//           highlightColor: Colors.transparent,
//           hoverColor: Colors.transparent,
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
//           selectedItemColor: const Color(0xFFF79E1B),
//           unselectedItemColor: Colors.white,
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//             BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.add_box_outlined), label: 'Post'),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.auto_awesome), label: 'AI Chef'),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.person_outline), label: 'Profile'),
//           ],
//           currentIndex: _selectedIndex,
//           onTap: _onItemTapped,
//           type: BottomNavigationBarType.fixed,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:instachef/screens/login_screen.dart';
import 'package:instachef/screens/home_screen.dart';
import 'package:instachef/screens/search_screen.dart';
import 'package:instachef/screens/post_screen.dart';
import 'package:instachef/screens/profile_screen.dart';
import 'package:instachef/screens/signup_screen_1.dart';
import 'package:instachef/screens/signup_screen_2.dart';
import 'package:instachef/screens/signup_screen_3.dart';
import 'package:instachef/admin/AdminDashBoardScreen.dart';
import 'package:instachef/screens/ai_recipe_generator.dart';
import 'package:instachef/screens/message_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:instachef/services/notification_service.dart';
import 'package:instachef/services/presence_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InstaChef',
      theme: ThemeData(
        canvasColor: const Color.fromRGBO(15, 29, 37, 1),
      ),
      // 🧠 AuthWrapper automatically chooses between login or main screen
      home: const AuthWrapper(),
      routes: {
        'login': (context) => const MyLogin(),
        'home': (context) => const MainNavigationScreen(),
        'register_1': (context) => const SignUp1(),
        'register_2': (context) => const SignUp2(),
        'register_3': (context) => const SignUp3(),
        'messages': (context) => const MessageScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔸 While Firebase checks auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF79E1B)),
            ),
          );
        }

        // 🟢 Logged in user → Go to main navigation
        if (snapshot.hasData) {
          return const MainNavigationScreen();
        }

        // 🔴 Not logged in → Go to login screen
        return const MyLogin();
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isAdmin = false;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    MySearchScreen(),
    RecipePostScreen(),
    AiRecipeGeneratorPage(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAdminStatus();
    _initializeNotifications();
    PresenceService.setOnline();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PresenceService.setOffline();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      PresenceService.setOnline();
    } else if (state == AppLifecycleState.paused ||
               state == AppLifecycleState.detached) {
      PresenceService.setOffline();
    }
  }

  Future<void> _initializeNotifications() async {
    await NotificationService().initialize();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data()?['isAdmin'] == true) {
          if (mounted) {
            setState(() => _isAdmin = true);
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking admin status: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _goToAdminDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
        title: Text(
          'InstaChef',
          style: GoogleFonts.cookie(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          // Messages button (like Instagram) - Only on Home Screen (index 0)
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
              tooltip: 'Messages',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MessageScreen()),
                );
              },
            ),
          // Admin button (only for admins)
          if (_isAdmin)
            IconButton(
              icon: const Icon(
                Icons.admin_panel_settings,
                color: Color(0xFFF79E1B),
              ),
              onPressed: _goToAdminDashboard,
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
          selectedItemColor: const Color(0xFFF79E1B),
          unselectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'AI Chef',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
