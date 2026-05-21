/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instachef/screens/login_screen.dart';
import 'recipe_data.dart';
import 'RecipeDetailScreen.dart';
import 'edit_profile_screen.dart';
import 'package:instachef/screens/saved_recipes_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _profileImageUrl =
      'https://placehold.co/120x120/0f1d25/ffffff?text=User';
  String _username = 'Loading...';
  String _email = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          if (mounted) {
            setState(() {
              _username = data['username'] ?? 'No Username';
              _email = data['email'] ?? 'No Email';
              _profileImageUrl =
                  data['profileImageUrl'] ?? _profileImageUrl;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Settings & Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const ProfileSectionTitle(title: 'Account'),
                const SizedBox(height: 8),
                ProfileOption(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
                const ProfileOption(
                  icon: Icons.notifications,
                  title: 'Notifications',
                ),
                const ProfileOption(
                  icon: Icons.lock,
                  title: 'Privacy Settings',
                ),

                const SizedBox(height: 24),
                const ProfileSectionTitle(title: 'Your Activity & Content'),
                const SizedBox(height: 8),
                ProfileOption(
                  icon: Icons.bookmark,
                  title: 'Saved Recipes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SavedRecipesScreen()),
                    );
                  },
                ),
                const ProfileOption(
                  icon: Icons.archive_outlined,
                  title: 'Archive',
                ),
                const ProfileOption(
                  icon: Icons.history,
                  title: 'Your Activity',
                ),
                const ProfileOption(
                  icon: Icons.alternate_email,
                  title: 'Tags and Mentions',
                ),
                const ProfileOption(
                  icon: Icons.favorite_border,
                  title: 'Favorites',
                ),
                const ProfileOption(
                  icon: Icons.people_alt_outlined,
                  title: 'Close Friends',
                ),
                const ProfileOption(
                  icon: Icons.block,
                  title: 'Blocked',
                ),

                const SizedBox(height: 24),
                const ProfileSectionTitle(title: 'General'),
                const SizedBox(height: 8),
                const ProfileOption(
                  icon: Icons.language,
                  title: 'Language and Translations',
                ),
                const ProfileOption(
                  icon: Icons.schedule_outlined,
                  title: 'Time Management',
                ),
                const ProfileOption(
                  icon: Icons.verified_user_outlined,
                  title: 'Account Status',
                ),
                const ProfileOption(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                ),
                const ProfileOption(
                  icon: Icons.info_outline,
                  title: 'About',
                ),

                ProfileOption(
                  icon: Icons.logout,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    // AuthWrapper will redirect user to login automatically
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              _username,
              style: GoogleFonts.robotoSlab(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _showMenu(context),
              ),
            ],
            floating: true,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProfileHeader(
                username: _username,
                email: _email,
                profileImageUrl: _profileImageUrl,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: StoryRow(),
            ),
          ),
          const PostsGrid(),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String profileImageUrl;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final recipes = RecipeData.recipes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(width: 40),
            ProfileStat(count: recipes.length, label: 'Posts'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            child: const Text('Edit Profile'),
          ),
        ),
      ],
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  final String title;

  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(24, 39, 51, 1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isDestructive ? null : const Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap ?? () {},
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final int count;
  final String label;

  const ProfileStat({
    super.key,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class StoryRow extends StatelessWidget {
  const StoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color.fromRGBO(15, 29, 37, 1),
                  backgroundImage: AssetImage('images/story.png'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Story ${index + 1}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PostsGrid extends StatelessWidget {
  const PostsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = RecipeData.recipes;

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final recipe = recipes[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(recipe: recipe),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                image: recipe.images.isNotEmpty
                    ? DecorationImage(
                  image: FileImage(recipe.images.first),
                  fit: BoxFit.cover,
                )
                    : const DecorationImage(
                  image: AssetImage('images/food.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
        childCount: recipes.length,
      ),
    );
  }
}

 */

/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instachef/screens/login_screen.dart';
import 'package:instachef/screens/edit_profile_screen.dart';
import 'package:instachef/screens/saved_recipes_screen.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _profileImageUrl =
      'https://placehold.co/120x120/0f1d25/ffffff?text=User';
  String _username = 'Loading...';
  String _email = 'Loading...';
  int _postCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchPostCount();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          if (mounted) {
            setState(() {
              _username = data['username'] ?? 'No Username';
              _email = data['email'] ?? 'No Email';
              _profileImageUrl =
                  data['profileImageUrl'] ?? _profileImageUrl;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPostCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        const String appId = 'insta-1841b';  // Or your actual app ID
        final snapshot = await FirebaseFirestore.instance
            .collection('artifacts/$appId/public/recipes')
            .where('userId', isEqualTo: user.uid)
            .get();

        if (mounted) {
          setState(() {
            _postCount = snapshot.docs.length;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load post count.')),
        );
      }
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Settings & Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ProfileOption(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
                ProfileOption(
                  icon: Icons.bookmark,
                  title: 'Saved Recipes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SavedRecipesScreen()),
                    );
                  },
                ),
                ProfileOption(
                  icon: Icons.logout,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              _username,
              style: GoogleFonts.robotoSlab(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _showMenu(context),
              ),
            ],
            floating: true,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProfileHeader(
                username: _username,
                email: _email,
                profileImageUrl: _profileImageUrl,
                postCount: _postCount,
              ),
            ),
          ),
          // You can add your Stories and Posts grid here as before
        ],
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(24, 39, 51, 1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isDestructive ? null : const Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap ?? () {},
      ),
    );
  }
}
*/
// profile_screen.dart
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Added import
import 'package:instachef/screens/login_screen.dart';
import 'package:instachef/screens/edit_profile_screen.dart';
import 'package:instachef/screens/saved_recipes_screen.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _profileImageUrl =
      'https://placehold.co/120x120/0f1d25/ffffff?text=User';
  String _username = 'Loading...';
  String _email = 'Loading...';
  int _postCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Combine both fetch methods for better flow
  Future<void> _fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        if (userDoc.exists) {
          final data = userDoc.data()!;
          setState(() {
            _username = data['username'] ?? 'No Username';
            _email = data['email'] ?? 'No Email';
            _profileImageUrl = data['profileImageUrl'] ?? _profileImageUrl;
          });
        }
      }

      // ⚠️ CORRECTED Firestore path for post count
      const String appId = 'insta-1841b'; // Replace with your actual app ID
      final postSnapshot = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (mounted) {
        setState(() {
          _postCount = postSnapshot.docs.length;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Settings & Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ProfileOption(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
                ProfileOption(
                  icon: Icons.bookmark,
                  title: 'Saved Recipes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SavedRecipesScreen()),
                    );
                  },
                ),
                ProfileOption(
                  icon: Icons.logout,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    // Handle navigation after logout (e.g., to login screen)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MyLogin()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              _username,
              style: GoogleFonts.robotoSlab(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _showMenu(context),
              ),
            ],
            floating: true,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProfileHeader(
                username: _username,
                email: _email,
                profileImageUrl: _profileImageUrl,
                postCount: _postCount,
              ),
            ),
          ),
          // You can add your Stories and Posts grid here as before
        ],
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(24, 39, 51, 1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isDestructive ? null : const Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap ?? () {},
      ),
    );
  }
}
 */
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instachef/screens/login_screen.dart';
import 'package:instachef/screens/edit_profile_screen.dart';
import 'package:instachef/screens/saved_recipes_screen.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ✅ Converted to a StatefulWidget to manage dynamic data
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ⚠️ These will now hold the fetched data
  String _profileImageUrl = 'https://placehold.co/120x120/0f1d25/ffffff?text=User';
  String _username = 'Loading...';
  String _email = 'Loading...';
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (mounted) {
        if (userDoc.exists) {
          final data = userDoc.data()!;
          setState(() {
            _username = data['username'] ?? _user!.displayName ?? 'No Username';
            _email = data['email'] ?? _user!.email ?? 'No Email';
            _profileImageUrl = data['profileImageUrl'] ?? _profileImageUrl;
          });
        } else {
          // 🔹 AUTO-CREATE PROFILE if missing
          final newUser = {
            'username': _user!.displayName ?? 'New User',
            'email': _user!.email ?? '',
            'profileImageUrl': _user!.photoURL ??
                'https://firebasestorage.googleapis.com/v0/b/insta-1841b.firebasestorage.app/o/profile_images%2Fdefault_profile.png?alt=media',
            'bio': 'Food lover & Chef',
            'followers': [],
            'following': [],
            'savedRecipes': [],
            'posts': 0,
            'createdAt': Timestamp.now(),
            'searchKeywords': [],
          };

          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .set(newUser);

          setState(() {
            _username = newUser['username'] as String;
            _email = newUser['email'] as String;
            _profileImageUrl = newUser['profileImageUrl'] as String;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Settings & Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const ProfileSectionTitle(title: 'Account'),
                const SizedBox(height: 8),
                ProfileOption(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
                const ProfileOption(icon: Icons.notifications, title: 'Notifications'),
                const ProfileOption(icon: Icons.lock, title: 'Privacy Settings'),
                const SizedBox(height: 24),
                const ProfileSectionTitle(title: 'Your Activity & Content'),
                const SizedBox(height: 8),
                ProfileOption(
                  icon: Icons.bookmark,
                  title: 'Saved Recipes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SavedRecipesScreen()),
                    );
                  },
                ),
                const ProfileOption(icon: Icons.archive_outlined, title: 'Archive'),
                const ProfileOption(icon: Icons.history, title: 'Your Activity'),
                const ProfileOption(icon: Icons.alternate_email, title: 'Tags and Mentions'),
                const ProfileOption(icon: Icons.favorite_border, title: 'Favorites'),
                const ProfileOption(icon: Icons.people_alt_outlined, title: 'Close Friends'),
                const ProfileOption(icon: Icons.block, title: 'Blocked'),
                const SizedBox(height: 24),
                const ProfileSectionTitle(title: 'General'),
                const SizedBox(height: 8),
                const ProfileOption(icon: Icons.language, title: 'Language and Translations'),
                const ProfileOption(icon: Icons.schedule_outlined, title: 'Time Management'),
                const ProfileOption(icon: Icons.verified_user_outlined, title: 'Account Status'),
                const ProfileOption(icon: Icons.help_outline, title: 'Help & Support'),
                const ProfileOption(icon: Icons.info_outline, title: 'About'),
                // ✅ Your requested logout code
                ProfileOption(
                  icon: Icons.logout,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MyLogin()),
                            (Route<dynamic> route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              _username,
              style: GoogleFonts.robotoSlab(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _showMenu(context),
              ),
            ],
            floating: true,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProfileHeader(
                username: _username,
                email: _email,
                profileImageUrl: _profileImageUrl,
                userId: _user!.uid,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: StoryRow(),
            ),
          ),
          PostsGrid(userId: _user!.uid),
        ],
      ),
    );
  }
}

// 🔹 Profile Header
class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String profileImageUrl;
  final String userId;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    required this.profileImageUrl,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (profileImageUrl.isEmpty) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.black,
                          iconTheme: const IconThemeData(color: Colors.white),
                        ),
                        body: Center(
                          child: Hero(
                            tag: 'profile_photo_$userId',
                            child: InteractiveViewer(
                              panEnabled: true,
                              minScale: 0.5,
                              maxScale: 4.0,
                              child: CachedNetworkImage(
                                imageUrl: profileImageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(50),
                child: Hero(
                  tag: 'profile_photo_$userId',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty
                        ? Text(username.isNotEmpty ? username[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 30))
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Posts count
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('artifacts')
                        .doc(appId)
                        .collection('public')
                        .doc('recipes')
                        .collection('all')
                        .where('userId', isEqualTo: userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return ProfileStat(count: count, label: 'Posts');
                    },
                  ),
                  // Followers count
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data() as Map<String, dynamic>?;
                      final followers = (data?['followers'] as List?)?.length ?? 0;
                      return GestureDetector(
                        onTap: () => _showFollowersList(context, userId, 'Followers'),
                        child: ProfileStat(count: followers, label: 'Followers'),
                      );
                    },
                  ),
                  // Following count
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data() as Map<String, dynamic>?;
                      final following = (data?['following'] as List?)?.length ?? 0;
                      return GestureDetector(
                        onTap: () => _showFollowersList(context, userId, 'Following'),
                        child: ProfileStat(count: following, label: 'Following'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
            ),
            child: const Text('Edit Profile'),
          ),
        ),
      ],
    );
  }

  void _showFollowersList(BuildContext context, String userId, String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final List<String> userIds = List<String>.from(
              type == 'Followers' ? (data?['followers'] ?? []) : (data?['following'] ?? []),
            );

            if (userIds.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No $type yet',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 400,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: userIds.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userIds[index])
                              .get(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return const ListTile(
                                leading: CircleAvatar(backgroundColor: Colors.grey),
                                title: Text('Loading...', style: TextStyle(color: Colors.white)),
                              );
                            }

                            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                            final username = userData?['username'] ?? 'Unknown';
                            final profileUrl = userData?['profileImageUrl'] ?? '';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                                backgroundImage: profileUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(profileUrl)
                                    : null,
                                child: profileUrl.isEmpty
                                    ? Text(
                                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                                        style: const TextStyle(color: Colors.white),
                                      )
                                    : null,
                              ),
                              title: Text(
                                username,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// 🔹 Profile Section Title
class ProfileSectionTitle extends StatelessWidget {
  final String title;
  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

// 🔹 Profile Option Tile
class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(24, 39, 51, 1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isDestructive ? null : const Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}

// 🔹 Profile Stat
class ProfileStat extends StatelessWidget {
  final int count;
  final String label;

  const ProfileStat({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}

// 🔹 Story Row
class StoryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color.fromRGBO(15, 29, 37, 1),
                  backgroundImage: AssetImage('images/story.png'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Story ${index + 1}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🔹 Posts Grid
class PostsGrid extends StatelessWidget {
  final String userId;
  const PostsGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Text(
                'No recipes posted yet.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final recipes = snapshot.data!.docs
            .map((doc) => Recipe.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final recipe = recipes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    image: recipe.imageUrls.isNotEmpty
                        ? DecorationImage(
                      image: CachedNetworkImageProvider(recipe.imageUrls.first),
                      fit: BoxFit.cover,
                    )
                        : const DecorationImage(
                      image: AssetImage('images/food.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
            childCount: recipes.length,
          ),
        );
      },
    );
  }
}*/
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instachef/screens/login_screen.dart';
import 'package:instachef/screens/edit_profile_screen.dart';
import 'package:instachef/screens/saved_recipes_screen.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _profileImageUrl = 'https://placehold.co/120x120/0f1d25/ffffff?text=User';
  String _username = 'Loading...';
  String _email = 'Loading...';
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (mounted && userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _username = data['username'] ?? _user!.displayName ?? 'No Username';
          _email = data['email'] ?? _user!.email ?? 'No Email';
          _profileImageUrl = data['profileImageUrl'] ?? _profileImageUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Settings & Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const ProfileSectionTitle(title: 'Account'),
                const SizedBox(height: 8),
                ProfileOption(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
                const ProfileOption(icon: Icons.notifications, title: 'Notifications'),
                const ProfileOption(icon: Icons.lock, title: 'Privacy Settings'),
                const SizedBox(height: 24),
                const ProfileSectionTitle(title: 'Your Activity & Content'),
                const SizedBox(height: 8),
                ProfileOption(
                  icon: Icons.bookmark,
                  title: 'Saved Recipes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SavedRecipesScreen()),
                    );
                  },
                ),
                const ProfileOption(icon: Icons.archive_outlined, title: 'Archive'),
                const ProfileOption(icon: Icons.history, title: 'Your Activity'),
                const ProfileOption(icon: Icons.alternate_email, title: 'Tags and Mentions'),
                const ProfileOption(icon: Icons.favorite_border, title: 'Favorites'),
                const ProfileOption(icon: Icons.people_alt_outlined, title: 'Close Friends'),
                const ProfileOption(icon: Icons.block, title: 'Blocked'),
                const SizedBox(height: 24),
                const ProfileSectionTitle(title: 'General'),
                const SizedBox(height: 8),
                const ProfileOption(icon: Icons.language, title: 'Language and Translations'),
                const ProfileOption(icon: Icons.schedule_outlined, title: 'Time Management'),
                const ProfileOption(icon: Icons.verified_user_outlined, title: 'Account Status'),
                const ProfileOption(icon: Icons.help_outline, title: 'Help & Support'),
                const ProfileOption(icon: Icons.info_outline, title: 'About'),
                // ✅ Correct logout option
                ProfileOption(
                  icon: Icons.logout,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MyLogin()),
                            (Route<dynamic> route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              _username,
              style: GoogleFonts.robotoSlab(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _showMenu(context),
              ),
            ],
            floating: true,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ProfileHeader(
                username: _username,
                email: _email,
                profileImageUrl: _profileImageUrl,
                userId: _user!.uid,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: StoryRow(),
            ),
          ),
          PostsGrid(userId: _user!.uid),
        ],
      ),
    );
  }
}

// 🔹 Profile Header
class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String profileImageUrl;
  final String userId;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    required this.profileImageUrl,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
              backgroundImage: CachedNetworkImageProvider(profileImageUrl),
            ),
            const SizedBox(width: 40),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('artifacts')
                  .doc(appId)
                  .collection('public')
                  .doc('recipes')
                  .collection('all')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return ProfileStat(count: count, label: 'Posts');
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
            ),
            child: const Text('Edit Profile'),
          ),
        ),
      ],
    );
  }
}

// 🔹 Profile Section Title
class ProfileSectionTitle extends StatelessWidget {
  final String title;
  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

// 🔹 Profile Option Tile
class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(24, 39, 51, 1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isDestructive ? null : const Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}

// 🔹 Profile Stat
class ProfileStat extends StatelessWidget {
  final int count;
  final String label;

  const ProfileStat({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}

// 🔹 Story Row
class StoryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color.fromRGBO(15, 29, 37, 1),
                  backgroundImage: AssetImage('images/story.png'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Story ${index + 1}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🔹 Posts Grid
class PostsGrid extends StatelessWidget {
  final String userId;
  const PostsGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Text(
                'No recipes posted yet.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final recipes = snapshot.data!.docs
            .map((doc) => Recipe.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final recipe = recipes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    image: recipe.imageUrls.isNotEmpty
                        ? DecorationImage(
                      image: CachedNetworkImageProvider(recipe.imageUrls.first),
                      fit: BoxFit.cover,
                    )
                        : const DecorationImage(
                      image: AssetImage('images/food.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
            childCount: recipes.length,
          ),
        );
      },
    );
  }
}

 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instachef/screens/login_screen.dart';
import 'package:instachef/screens/edit_profile_screen.dart';
import 'package:instachef/screens/saved_recipes_screen.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/screens/Privacy_Policy_Screen.dart'; // your new privacy screen
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/public_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _profileImageUrl =
      'https://placehold.co/120x120/0f1d25/ffffff?text=User';
  String _username = 'Loading...';
  String _email = 'Loading...';
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (mounted && userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _username = data['username'] ?? _user!.displayName ?? 'No Username';
          _email = data['email'] ?? _user!.email ?? 'No Email';
          _profileImageUrl = data['profileImageUrl'] ?? _profileImageUrl;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Settings & Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const ProfileSectionTitle(title: 'Account'),
                const SizedBox(height: 8),
                ProfileOption(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                ProfileOption(
                  icon: Icons.lock,
                  title: 'Privacy Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const ProfileSectionTitle(title: 'Your Activity & Content'),
                const SizedBox(height: 8),
                ProfileOption(
                  icon: Icons.bookmark,
                  title: 'Saved Recipes',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedRecipesScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const ProfileSectionTitle(title: 'General'),
                const SizedBox(height: 8),
                // Add other general options if needed
                ProfileOption(
                  icon: Icons.logout,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MyLogin()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(
                    _username,
                    style: GoogleFonts.robotoSlab(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => _showMenu(context),
                    ),
                  ],
                  floating: true,
                  elevation: 0,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ProfileHeader(
                      username: _username,
                      email: _email,
                      profileImageUrl: _profileImageUrl,
                      userId: _user!.uid,
                    ),
                  ),
                ),
                PostsGrid(userId: _user!.uid),
              ],
            ),
    );
  }
}

// 🔹 Profile Header
class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String profileImageUrl;
  final String userId;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    required this.profileImageUrl,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
              backgroundImage: CachedNetworkImageProvider(profileImageUrl),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Posts count
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('artifacts')
                        .doc(appId)
                        .collection('public')
                        .doc('recipes')
                        .collection('all')
                        .where('userId', isEqualTo: userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return ProfileStat(count: count, label: 'Posts');
                    },
                  ),
                  // Followers count
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final followers =
                          (data?['followers'] as List?)?.length ?? 0;
                      return GestureDetector(
                        onTap: () =>
                            _showFollowersList(context, userId, 'Followers'),
                        child: ProfileStat(
                          count: followers,
                          label: 'Followers',
                        ),
                      );
                    },
                  ),
                  // Following count
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final following =
                          (data?['following'] as List?)?.length ?? 0;
                      return GestureDetector(
                        onTap: () =>
                            _showFollowersList(context, userId, 'Following'),
                        child: ProfileStat(
                          count: following,
                          label: 'Following',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              foregroundColor: Colors.white,
            ),
            child: const Text('Edit Profile'),
          ),
        ),
      ],
    );
  }

  void _showFollowersList(BuildContext context, String userId, String type) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final List<String> userIds = List<String>.from(
              type == 'Followers'
                  ? (data?['followers'] ?? [])
                  : (data?['following'] ?? []),
            );

            if (userIds.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No $type yet',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 400,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: userIds.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userIds[index])
                              .get(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return const ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                ),
                                title: Text(
                                  'Loading...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }

                            final userData =
                                userSnapshot.data!.data()
                                    as Map<String, dynamic>?;
                            final username = userData?['username'] ?? 'Unknown';
                            final profileUrl =
                                userData?['profileImageUrl'] ?? '';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color.fromRGBO(
                                  247,
                                  158,
                                  27,
                                  1,
                                ),
                                backgroundImage: profileUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(profileUrl)
                                    : null,
                                child: profileUrl.isEmpty
                                    ? Text(
                                        username.isNotEmpty
                                            ? username[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                username,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: type == 'Following'
                                  ? TextButton(
                                      onPressed: () async {
                                        // Unfollow this user
                                        final confirmed =
                                            await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Unfollow'),
                                                content: Text(
                                                  'Unfollow $username?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                    ),
                                                    child: const Text(
                                                      'Unfollow',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );

                                        if (confirmed == true) {
                                          try {
                                            // Remove from following list
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUserId)
                                                .update({
                                                  'following':
                                                      FieldValue.arrayRemove([
                                                        userIds[index],
                                                      ]),
                                                });

                                            // Remove from their followers list
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userIds[index])
                                                .update({
                                                  'followers':
                                                      FieldValue.arrayRemove([
                                                        currentUserId,
                                                      ]),
                                                });

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Unfollowed $username',
                                                  ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Failed to unfollow: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      child: const Text(
                                        'Unfollow',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pop(context);
                                if (userIds[index] != currentUserId) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PublicProfileScreen(
                                        userId: userIds[index],
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// 🔹 Profile Section Title
class ProfileSectionTitle extends StatelessWidget {
  final String title;
  const ProfileSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

// 🔹 Profile Option Tile
class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(24, 39, 51, 1),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: isDestructive
            ? null
            : const Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}

// 🔹 Profile Stat
class ProfileStat extends StatelessWidget {
  final int count;
  final String label;

  const ProfileStat({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}

// 🔹 Posts Grid
class PostsGrid extends StatelessWidget {
  final String userId;
  const PostsGrid({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Text(
                'No recipes posted yet.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final recipes = snapshot.data!.docs
            .map(
              (doc) => Recipe.fromFirestore(doc.data() as Map<String, dynamic>),
            )
            .toList();

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final recipe = recipes[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
              },
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  image: recipe.imageUrls.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(
                            recipe.imageUrls.first,
                          ),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('images/food.png'),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            );
          }, childCount: recipes.length),
        );
      },
    );
  }
}
