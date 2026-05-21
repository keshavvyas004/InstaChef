/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin_users_screen.dart';
import 'admin_posts_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isAdmin = false;
  bool _loading = true;
  Map<String, int> _data = {
    'users': 0,
    'posts': 0,
    'likes': 0,
    'saves': 0,
  };

  final String appId = 'yourAppId'; // Replace with your actual appId

  @override
  void initState() {
    super.initState();
    checkAdminAndFetchData();
  }

  Future<void> checkAdminAndFetchData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && (userDoc.data()?['isAdmin'] == true)) {
        _isAdmin = true;
        await fetchData();
      }
    } catch (e) {
      debugPrint('Error checking admin: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> fetchData() async {
    try {
      final usersSnapshot = FirebaseFirestore.instance.collection('users').get();
      final recipesSnapshot = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .get();

      final results = await Future.wait([usersSnapshot, recipesSnapshot]);

      final userDocs = results[0].docs;
      final recipeDocs = results[1].docs;

      int totalUsers = userDocs.length;
      int totalPosts = recipeDocs.length;
      int totalLikes = 0;
      int totalSaves = 0;

      for (var post in recipeDocs) {
        totalLikes += (post.data()['likes'] as List<dynamic>?)?.length ?? 0;
        totalSaves += (post.data()['savedBy'] as List<dynamic>?)?.length ?? 0;
      }

      _data = {
        'users': totalUsers,
        'posts': totalPosts,
        'likes': totalLikes,
        'saves': totalSaves,
      };
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Access Denied',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.cookie(
            fontSize: 35,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Analytics Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                analyticsCard('Users', _data['users']!, Colors.orange),
                analyticsCard('Posts', _data['posts']!, Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                analyticsCard('Likes', _data['likes']!, Colors.red),
                analyticsCard('Saves', _data['saves']!, Colors.green),
              ],
            ),
            const SizedBox(height: 40),

            // Pie Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: _data['users']!.toDouble(),
                      color: Colors.orange,
                      title: 'Users',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: _data['posts']!.toDouble(),
                      color: Colors.blue,
                      title: 'Posts',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: _data['likes']!.toDouble(),
                      color: Colors.red,
                      title: 'Likes',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: _data['saves']!.toDouble(),
                      color: Colors.green,
                      title: 'Saves',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Manage Users Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              icon: const Icon(Icons.person, color: Colors.white),
              label: Text(
                'Manage Users',
                style: GoogleFonts.cookie(fontSize: 30, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUsersScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Manage Posts Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              icon: const Icon(Icons.post_add, color: Colors.white),
              label: Text(
                'Manage Posts',
                style: GoogleFonts.cookie(fontSize: 30, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminPostsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget analyticsCard(String title, int count, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.cookie(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: GoogleFonts.cookie(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_users_screen.dart';
import 'admin_posts_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isAdmin = false;
  bool _loading = true;
  Map<String, int> _data = {
    'users': 0,
    'posts': 0,
  };

  final String appId = 'yourAppId'; // Replace with your actual appId

  @override
  void initState() {
    super.initState();
    checkAdminAndFetchData();
  }

  Future<void> checkAdminAndFetchData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && (userDoc.data()?['isAdmin'] == true)) {
        _isAdmin = true;
        await fetchData();
      }
    } catch (e) {
      debugPrint('Error checking admin: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> fetchData() async {
    try {
      final usersSnapshot = FirebaseFirestore.instance.collection('users').get();
      final recipesSnapshot = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .get();

      final results = await Future.wait([usersSnapshot, recipesSnapshot]);

      final userDocs = results[0].docs;
      final recipeDocs = results[1].docs;

      int totalUsers = userDocs.length;
      int totalPosts = recipeDocs.length;

      _data = {
        'users': totalUsers,
        'posts': totalPosts,
      };
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Access Denied',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.cookie(
            fontSize: 35,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Analytics Cards (Users & Posts only)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                analyticsCard('Users', _data['users']!, Colors.orange),
                analyticsCard('Posts', _data['posts']!, Colors.blue),
              ],
            ),
            const SizedBox(height: 40),

            // Manage Users Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              icon: const Icon(Icons.person, color: Colors.white),
              label: Text(
                'Manage Users',
                style: GoogleFonts.cookie(fontSize: 30, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUsersScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Manage Posts Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: const Size(double.infinity, 60),
              ),
              icon: const Icon(Icons.post_add, color: Colors.white),
              label: Text(
                'Manage Posts',
                style: GoogleFonts.cookie(fontSize: 30, color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminPostsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget analyticsCard(String title, int count, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.cookie(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: GoogleFonts.cookie(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

 */
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_users_screen.dart'; // Ensure this file exists
import 'admin_posts_screen.dart'; // Ensure this file exists
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

// IMPORTANT: Fixed to your actual application ID: instachef_app_id
const String _APP_ID = '1:250338435801:android:ddd8de8871e9db841c54c8';
const Color _darkBgColor = Color.fromRGBO(15, 29, 37, 1);
const Color _primaryColor = Color.fromRGBO(247, 158, 27, 1);

// Data model for chart points over time (Simplified structure)
class MonthData {
  final String monthLabel;
  final int count;

  MonthData(this.monthLabel, this.count);
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isAdmin = false;
  bool _loading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, int> _totalData = {'users': 0, 'posts': 0};
  List<MonthData> _signUpData = [];
  List<MonthData> _activeUserData = [];
  // Removed: List<MonthData> _emailSendData = [];

  // Generates month labels for the last 6 months (e.g., 10/24, 11/24, 12/24...)
  final List<String> monthLabels = List.generate(6, (index) {
    final now = DateTime.now();
    // Start 5 months ago (index 0) up to the current month (index 5)
    final date = DateTime(now.year, now.month - 5 + index, 1);
    return '${date.month}/${date.year % 100}';
  });

  @override
  void initState() {
    super.initState();
    checkAdminAndFetchData();
  }

  Future<void> checkAdminAndFetchData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists && (userDoc.data()?['isAdmin'] == true)) {
        _isAdmin = true;
        await fetchData();
      }
    } catch (e) {
      debugPrint('Error checking admin or fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // --- Data Aggregation Logic Helpers ---

  /// Aggregates documents by the month of their timestamp field.
  List<MonthData> _aggregateDataByMonth(List<QueryDocumentSnapshot> docs, String timeStampField) {
    // Map of month labels (e.g., '10/24') to their 0-5 index
    final now = DateTime.now();
    final monthStarts = <String, int>{};
    for (int i = 0; i < 6; i++) {
      final start = DateTime(now.year, now.month - 5 + i, 1);
      final label = '${start.month}/${start.year % 100}';
      monthStarts[label] = i;
    }

    final Map<int, int> monthlyCounts = {for (var i = 0; i < 6; i++) i: 0};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data[timeStampField] as Timestamp?;

      if (timestamp != null) {
        final date = timestamp.toDate();
        final label = '${date.month}/${date.year % 100}';

        if (monthStarts.containsKey(label)) {
          final monthIndex = monthStarts[label]!;
          monthlyCounts[monthIndex] = monthlyCounts[monthIndex]! + 1;
        }
      }
    }

    return monthlyCounts.entries.map((e) => MonthData(
      monthLabels[e.key],
      e.value,
    )).toList();
  }

  List<MonthData> _aggregateSignUps(List<QueryDocumentSnapshot> userDocs) {
    return _aggregateDataByMonth(userDocs, 'createdAt');
  }

  List<MonthData> _aggregateActiveUsers(List<QueryDocumentSnapshot> userDocs) {
    return _aggregateDataByMonth(userDocs, 'lastActive');
  }

  // Removed: _aggregateEmailSends helper function

  // --- Core Data Fetching ---

  Future<void> fetchData() async {
    try {
      // 1. Fetch all users for totals and aggregation
      final usersSnapshot = await _firestore.collection('users').get();
      final userDocs = usersSnapshot.docs;

      // 2. Fetch all posts for totals
      final postsSnapshot = await _firestore
          .collection('artifacts')
          .doc(_APP_ID)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .get();
      final postDocs = postsSnapshot.docs;

      _totalData = {
        'users': userDocs.length,
        'posts': postDocs.length,
      };

      // 3. Aggregate Sign-up and Active User data
      _signUpData = _aggregateSignUps(userDocs);
      _activeUserData = _aggregateActiveUsers(userDocs);

      // Removed: Fetch and aggregation logic for email logs (Steps 4 & 5)

    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
    if (mounted) {
      setState(() {});
    }
  }

  // --- UI and Chart Builders ---

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) Navigator.pop(context);
  }


  Widget _buildLineChartCard({
    required String title,
    required List<MonthData> data,
    required Color lineColor,
  }) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    // Map MonthData to FlSpot using index as X-axis
    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
    }).toList();

    // Calculate chart limits and intervals
    final maxY = data.map((d) => d.count).fold(0, (a, b) => a > b ? a : b).toDouble() * 1.2;
    final interval = maxY > 200 ? 50.0 : maxY > 50 ? 10.0 : 5.0;
    final cleanMaxY = (maxY / interval).ceil() * interval;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(24, 46, 61, 1),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cookie(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 2.5,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 5, // 6 months, index 0 to 5
                minY: 0,
                maxY: cleanMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            // Use the month label from the aggregated data
                            child: Text(data[index].monthLabel, style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value % interval == 0) {
                          return Text(value.toInt().toString(), style: GoogleFonts.inter(color: Colors.white70, fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget analyticsCard(String title, int count, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.cookie(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: GoogleFonts.cookie(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _darkBgColor,
        body: Center(child: CircularProgressIndicator(color: _primaryColor)),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        backgroundColor: _darkBgColor,
        body: Center(
          child: Text(
            'Access Denied',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _darkBgColor,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.cookie(
            fontSize: 35,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _darkBgColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Analytics Cards (Users & Posts totals)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  analyticsCard('Total Users', _totalData['users']!, Colors.orange),
                  analyticsCard('Total Posts', _totalData['posts']!, Colors.blue),
                ],
              ),
              const SizedBox(height: 40),

              // --- Line Chart 1: Monthly Sign-ups ---
              _buildLineChartCard(
                title: 'Monthly Sign-ups (Last 6 Months)',
                data: _signUpData,
                lineColor: Colors.deepOrangeAccent,
              ),

              // --- Line Chart 2: Monthly Active Users ---
              _buildLineChartCard(
                title: 'Monthly Active Users (Last 6 Months)',
                data: _activeUserData,
                lineColor: Colors.lightGreenAccent,
              ),

              // Removed: Line Chart 3 (Monthly Email Sends)

              const SizedBox(height: 20),

              // Management Buttons
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 60),
                ),
                icon: const Icon(Icons.person, color: Colors.white),
                label: Text(
                  'Manage Users',
                  style: GoogleFonts.cookie(fontSize: 30, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminUsersScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 60),
                ),
                icon: const Icon(Icons.post_add, color: Colors.white),
                label: Text(
                  'Manage Posts',
                  style: GoogleFonts.cookie(fontSize: 30, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminPostsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}