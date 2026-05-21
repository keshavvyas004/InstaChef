import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'RecipeDetailScreen.dart';
import 'recipe_model.dart';


class PublicProfileScreen extends StatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  String _profileImageUrl = 'https://placehold.co/120x120/0f1d25/ffffff?text=User';
  String _username = 'Loading...';

  bool _isLoading = true;
  bool _isFollowing = false;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkIfFollowing();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _username = data['username'] ?? 'No Username';
// removed _email field initialization
          _username = data['username'] ?? 'No Username';
          _profileImageUrl = data['profileImageUrl'] ?? _profileImageUrl;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkIfFollowing() async {
    if (_currentUserId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final followers = List<String>.from(data['followers'] ?? []);
        if (mounted) {
          setState(() {
            _isFollowing = followers.contains(_currentUserId);
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    if (_currentUserId.isEmpty) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(_currentUserId);

    try {
      if (_isFollowing) {
        // Unfollow
        await userRef.update({
          'followers': FieldValue.arrayRemove([_currentUserId])
        });
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([widget.userId])
        });
        setState(() => _isFollowing = false);
      } else {
        // Follow
        await userRef.update({
          'followers': FieldValue.arrayUnion([_currentUserId])
        });
        await currentUserRef.update({
          'following': FieldValue.arrayUnion([widget.userId])
        });
        setState(() => _isFollowing = true);
      }
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update follow status: $e')),
        );
      }
    }
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
                          future: FirebaseFirestore.instance.collection('users').doc(userIds[index]).get(),
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
                              title: Text(username, style: const TextStyle(color: Colors.white)),
                              trailing: type == 'Following' && userId == widget.userId
                                  ? TextButton(
                                      onPressed: () async {
                                        // Unfollow this user
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Unfollow'),
                                            content: Text('Unfollow $username?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                child: const Text('Unfollow'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          try {
                                            // Remove from following list
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(_currentUserId)
                                                .update({
                                              'following': FieldValue.arrayRemove([userIds[index]])
                                            });

                                            // Remove from their followers list
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userIds[index])
                                                .update({
                                              'followers': FieldValue.arrayRemove([_currentUserId])
                                            });

                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Unfollowed $username')),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Failed to unfollow: $e')),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      child: const Text('Unfollow', style: TextStyle(color: Colors.red)),
                                    )
                                  : null,
                              onTap: () {
                                Navigator.pop(context);
                                if (userIds[index] != _currentUserId) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PublicProfileScreen(userId: userIds[index]),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(15, 29, 37, 1),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      appBar: AppBar(
        title: Text(
          _username,
          style: GoogleFonts.robotoSlab(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
                        backgroundImage: CachedNetworkImageProvider(_profileImageUrl),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('artifacts')
                                  .doc(appId)
                                  .collection('public')
                                  .doc('recipes')
                                  .collection('all')
                                  .where('userId', isEqualTo: widget.userId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                final count = snapshot.data?.docs.length ?? 0;
                                return _buildStat(count, 'Posts');
                              },
                            ),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
                              builder: (context, snapshot) {
                                final data = snapshot.data?.data() as Map<String, dynamic>?;
                                final followers = (data?['followers'] as List?)?.length ?? 0;
                                return GestureDetector(
                                  onTap: () => _showFollowersList(context, widget.userId, 'Followers'),
                                  child: _buildStat(followers, 'Followers'),
                                );
                              },
                            ),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
                              builder: (context, snapshot) {
                                final data = snapshot.data?.data() as Map<String, dynamic>?;
                                final following = (data?['following'] as List?)?.length ?? 0;
                                return GestureDetector(
                                  onTap: () => _showFollowersList(context, widget.userId, 'Following'),
                                  child: _buildStat(following, 'Following'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  
                  if (widget.userId != _currentUserId)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _toggleFollow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing ? Colors.grey[800] : const Color.fromRGBO(247, 158, 27, 1),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_isFollowing ? 'Following' : 'Follow'),
                      ),
                    ),
                ],
              ),
            ),
          ),
           // Grid for Public Posts
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('artifacts')
                .doc(appId)
                .collection('public')
                .doc('recipes')
                .collection('all')
                .where('userId', isEqualTo: widget.userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              }
              final docs = snapshot.data!.docs;
              
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final recipe = Recipe.fromFirestore(data); // Using existing factory method

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          image: recipe.imageUrls.isNotEmpty
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(recipe.imageUrls.first),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: recipe.imageUrls.isEmpty
                             ? const Icon(Icons.restaurant, color: Colors.white)
                             : null,
                      ),
                    );
                  },
                  childCount: docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStat(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
