/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPostsScreen extends StatefulWidget {
  const AdminPostsScreen({super.key});

  @override
  State<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends State<AdminPostsScreen> {
  bool _isAdmin = false;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final String appId = '1:250338435801:android:ddd8de8871e9db841c54c8'; // Replace with your actual appId

  @override
  void initState() {
    super.initState();
    checkAdmin();
  }

  Future<void> checkAdmin() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        _isAdmin = userDoc.exists && (userDoc.data()?['isAdmin'] == true);
      });
    } catch (e) {
      debugPrint('Error checking admin: $e');
      setState(() => _isAdmin = false);
    }
  }

  Future<void> deletePost(BuildContext context, String postId) async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can delete posts')),
      );
      return;
    }

    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to permanently delete this post and remove it from all users\' saved lists?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmDelete != true) return;

    try {
      final postRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc(postId);

      final postDoc = await postRef.get();
      if (!postDoc.exists) return;

      final postData = postDoc.data() as Map<String, dynamic>;
      final savedByUsers = (postData['savedBy'] as List<dynamic>?)?.cast<String>() ?? [];

      // Remove post from all users' saved lists
      final batch = FirebaseFirestore.instance.batch();
      for (final userId in savedByUsers) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
        batch.update(userRef, {'savedPosts': FieldValue.arrayRemove([postId])});
      }
      await batch.commit();

      // Delete the post
      await postRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted and removed from all saved lists.')),
      );
    } catch (e) {
      debugPrint('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete post.')),
      );
    }
  }

  Future<void> toggleApprove(String postId, bool approved) async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can approve/unapprove posts')),
      );
      return;
    }

    try {
      final postRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc(postId);

      await postRef.update({'approved': !approved});
    } catch (e) {
      debugPrint('Error toggling approval: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update approval status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text('Access Denied', style: TextStyle(color: Colors.red, fontSize: 20)),
        ),
      );
    }

    final postsStream = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .snapshots();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      appBar: AppBar(
        title: Text('Manage Posts', style: GoogleFonts.cookie(fontSize: 30, color: Colors.white)),
        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: postsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No posts found.', style: TextStyle(color: Colors.white, fontSize: 18)),
            );
          }

          final posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final postData = post.data() as Map<String, dynamic>;
              final approved = postData['approved'] ?? false;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: postData.containsKey('imageUrl') &&
                      postData['imageUrl'] != null &&
                      postData['imageUrl'] != ''
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(postData['imageUrl']),
                    backgroundColor: Colors.transparent,
                  )
                      : const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.image, color: Colors.white),
                  ),
                  title: Text(postData['title'] ?? 'No Title', style: GoogleFonts.cookie(fontSize: 20)),
                  subtitle: Text(postData['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          approved ? Icons.check_box : Icons.check_box_outline_blank,
                          color: approved ? Colors.green : Colors.grey,
                        ),
                        onPressed: () => toggleApprove(post.id, approved),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deletePost(context, post.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


 */
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPostsScreen extends StatefulWidget {
  const AdminPostsScreen({super.key});

  @override
  State<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends State<AdminPostsScreen> {
  bool _isAdmin = false;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';

  @override
  void initState() {
    super.initState();
    checkAdmin();
  }

  Future<void> checkAdmin() async {
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        _isAdmin = userDoc.exists && (userDoc.data()?['isAdmin'] == true);
      });
    } catch (e) {
      debugPrint('Error checking admin: $e');
      setState(() => _isAdmin = false);
    }
  }

  Future<void> deletePost(BuildContext context, String postId) async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can delete posts')),
      );
      return;
    }

    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to permanently delete this post and remove it from all users\' saved lists?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmDelete != true) return;

    try {
      final postRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc(postId);

      final postDoc = await postRef.get();
      if (!postDoc.exists) return;

      final postData = postDoc.data() as Map<String, dynamic>;
      final savedByUsers = (postData['savedBy'] as List<dynamic>?)?.cast<String>() ?? [];

      final batch = FirebaseFirestore.instance.batch();
      for (final userId in savedByUsers) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
        batch.update(userRef, {'savedPosts': FieldValue.arrayRemove([postId])});
      }
      await batch.commit();

      await postRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted and removed from all saved lists.')),
      );
    } catch (e) {
      debugPrint('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete post.')),
      );
    }
  }

  Future<void> toggleApprove(String postId, bool approved) async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can approve/unapprove posts')),
      );
      return;
    }

    try {
      final postRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc(postId);

      await postRef.update({'approved': !approved});
    } catch (e) {
      debugPrint('Error toggling approval: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update approval status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text('Access Denied', style: TextStyle(color: Colors.red, fontSize: 20)),
        ),
      );
    }

    final postsStream = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .snapshots();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      appBar: AppBar(
        title: Text('Manage Posts', style: GoogleFonts.cookie(fontSize: 30, color: Colors.white)),
        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: postsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No posts found.', style: TextStyle(color: Colors.white, fontSize: 18)),
            );
          }

          final posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostCard(
                postDoc: post,
                onDelete: () => deletePost(context, post.id),
                onToggleApprove: (approved) => toggleApprove(post.id, approved),
                appId: appId,
              );
            },
          );
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot postDoc;
  final VoidCallback onDelete;
  final Function(bool approved) onToggleApprove;
  final String appId;

  const PostCard({
    required this.postDoc,
    required this.onDelete,
    required this.onToggleApprove,
    required this.appId,
    super.key,
  });

  /// Robust likes count parser:
  int parseLikesCount(Map<String, dynamic> postData) {
    final likesField = postData['likes'];
    if (likesField == null) return 0;

    if (likesField is int) return likesField;
    if (likesField is List) return likesField.length;
    if (likesField is Map) return likesField.keys.length;
    // fallback
    try {
      return (likesField as dynamic).length as int;
    } catch (_) {
      return 0;
    }
  }

  /// Determine userId present in post fields (common keys).
  String? findAuthorId(Map<String, dynamic> postData) {
    if (postData.containsKey('userId')) return postData['userId']?.toString();
    if (postData.containsKey('authorId')) return postData['authorId']?.toString();
    if (postData.containsKey('uid')) return postData['uid']?.toString();
    return null;
  }

  /// Loads username & comment count. Comments may be either an array in doc
  /// or a subcollection 'comments'.
  Future<Map<String, dynamic>> loadMeta() async {
    final postData = (postDoc.data() as Map<String, dynamic>);
    String username = postData['username']?.toString() ?? 'Unknown User';
    int likes = parseLikesCount(postData);

    // If post contains an explicit numeric likesCount field, prefer that
    if (postData.containsKey('likesCount') && postData['likesCount'] is int) {
      likes = postData['likesCount'] as int;
    }

    // Try to fetch username from users collection if we have an author id
    final authorId = findAuthorId(postData);
    if (authorId != null) {
      try {
        final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(authorId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            // common username fields
            username = (userData['username'] ?? userData['displayName'] ?? userData['name'] ?? username).toString();
          }
        }
      } catch (e) {
        debugPrint('Failed to load user $authorId: $e');
      }
    }

    // comment count: prefer subcollection count if exists, otherwise array length
    int commentsCount = 0;
    if (postData.containsKey('comments')) {
      final commentsField = postData['comments'];
      if (commentsField is int) {
        commentsCount = commentsField;
      } else if (commentsField is List) {
        commentsCount = commentsField.length;
      } else if (commentsField is Map) {
        commentsCount = commentsField.keys.length;
      }
    }

    // Check subcollection 'comments' (common pattern). We'll query it and count docs.
    try {
      final commentsColl = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc(postDoc.id)
          .collection('comments');

      final commentsSnapshot = await commentsColl.limit(1).get();
      if (commentsSnapshot.docs.isNotEmpty) {
        // If subcollection exists, fetch full count (careful: potentially costly)
        // We'll try a fast method: count via get().size (ok for moderate sizes)
        final full = await commentsColl.get();
        commentsCount = full.size;
      }
    } catch (e) {
      // ignore errors, keep previous commentsCount
      debugPrint('Error checking comments subcollection: $e');
    }

    return {
      'username': username,
      'likes': likes,
      'comments': commentsCount,
    };
  }

  @override
  Widget build(BuildContext context) {
    final postData = postDoc.data() as Map<String, dynamic>;
    final approved = postData['approved'] ?? false;
    final title = postData['title'] ?? 'No Title';
    final description = postData['description'] ?? '';
    final imageUrl = postData['imageUrl'] ?? '';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: (imageUrl != null && imageUrl != '')
                ? CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.transparent,
            )
                : const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.image, color: Colors.white),
            ),
            title: Text(title, style: GoogleFonts.cookie(fontSize: 22)),
            subtitle: Text(description,
                maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    approved ? Icons.check_box : Icons.check_box_outline_blank,
                    color: approved ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => onToggleApprove(approved),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<Map<String, dynamic>>(
            future: loadMeta(),
            builder: (context, metaSnap) {
              if (metaSnap.connectionState == ConnectionState.waiting) {
                // show placeholders while loading
                return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('👤 Loading...', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  Row(children: const [
                    Icon(Icons.favorite, size: 18),
                    SizedBox(width: 6),
                    Text('...'),
                    SizedBox(width: 16),
                    Icon(Icons.comment, size: 18),
                    SizedBox(width: 6),
                    Text('...'),
                  ])
                ]);
              }

              final meta = metaSnap.data ?? {'username': 'Unknown User', 'likes': 0, 'comments': 0};
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('👤 ${meta['username']}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  Row(
                    children: [
                      Row(children: [
                        const Icon(Icons.favorite, color: Colors.pink, size: 18),
                        const SizedBox(width: 4),
                        Text('${meta['likes']}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      ]),
                      const SizedBox(width: 16),
                      Row(children: [
                        const Icon(Icons.comment, color: Colors.blueAccent, size: 18),
                        const SizedBox(width: 4),
                        Text('${meta['comments']}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      ]),
                    ],
                  ),
                ],
              );
            },
          ),
        ]),
      ),
    );
  }
}

 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPostsScreen extends StatefulWidget {
  const AdminPostsScreen({super.key});

  @override
  State<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends State<AdminPostsScreen> {
  bool _isAdmin = false;
  final currentUser = FirebaseAuth.instance.currentUser!;
  final String appId = '1:250338435801:android:ddd8de8871e9db841c54c8'; // your appId

  @override
  void initState() {
    super.initState();
    checkAdmin();
  }

  Future<void> checkAdmin() async {
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      setState(() {
        _isAdmin = userDoc.exists && (userDoc.data()?['isAdmin'] == true);
      });
    } catch (e) {
      debugPrint('Error checking admin: $e');
      setState(() => _isAdmin = false);
    }
  }

  Future<void> deletePost(BuildContext context, String postId) async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can delete posts')),
      );
      return;
    }

    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to permanently delete this post and remove it from all users\' saved lists?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmDelete != true) return;

    try {
      final postRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc(postId);

      final postDoc = await postRef.get();
      if (!postDoc.exists) return;

      final postData = postDoc.data() as Map<String, dynamic>;
      final savedByUsers = (postData['savedBy'] as List<dynamic>?)?.cast<String>() ?? [];

      final batch = FirebaseFirestore.instance.batch();
      for (final userId in savedByUsers) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
        batch.update(userRef, {'savedPosts': FieldValue.arrayRemove([postId])});
      }
      await batch.commit();

      await postRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted and removed from all saved lists.')),
      );
    } catch (e) {
      debugPrint('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete post.')),
      );
    }
  }

  Future<void> toggleApprove(String postId, bool approved) async {
    if (!_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can approve/unapprove posts')),
      );
      return;
    }

    try {
      final postRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc(postId);
      await postRef.update({'approved': !approved});
    } catch (e) {
      debugPrint('Error toggling approval: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update approval status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text('Access Denied', style: TextStyle(color: Colors.red, fontSize: 20)),
        ),
      );
    }

    final postsStream = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .snapshots();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      appBar: AppBar(
        title: Text('Manage Posts', style: GoogleFonts.cookie(fontSize: 30, color: Colors.white)),
        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: postsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No posts found.', style: TextStyle(color: Colors.white, fontSize: 18)),
            );
          }

          final posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final postData = post.data() as Map<String, dynamic>;
              final approved = postData['approved'] ?? false;

              return FutureBuilder<Map<String, dynamic>>(
                future: _getPostMeta(post.id, postData),
                builder: (context, metaSnap) {
                  if (!metaSnap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: LinearProgressIndicator(),
                    );
                  }

                  final meta = metaSnap.data!;
                  final username = meta['username'];
                  final likes = meta['likes'];
                  final comments = meta['comments'];

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      leading: postData['imageUrl'] != null && postData['imageUrl'] != ''
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(postData['imageUrl']),
                        backgroundColor: Colors.transparent,
                      )
                          : const CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.image, color: Colors.white),
                      ),
                      title: Text(postData['title'] ?? 'No Title',
                          style: GoogleFonts.cookie(fontSize: 20)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("By: $username"),
                          const SizedBox(height: 4),
                          Text(postData['description'] ?? '',
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.favorite, color: Colors.red, size: 18),
                              Text(' $likes'),
                              const SizedBox(width: 10),
                              const Icon(Icons.comment, color: Colors.grey, size: 18),
                              Text(' $comments'),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              approved ? Icons.check_box : Icons.check_box_outline_blank,
                              color: approved ? Colors.green : Colors.grey,
                            ),
                            onPressed: () => toggleApprove(post.id, approved),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deletePost(context, post.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// --- Fetch username, likes, comments safely ---
  Future<Map<String, dynamic>> _getPostMeta(String postId, Map<String, dynamic> postData) async {
    String username = 'Unknown User';
    int likesCount = 0;
    int commentsCount = 0;

    // 🔹 Username
    try {
      final authorId = postData['authorId'] ?? postData['uid'] ?? postData['userId'];
      if (authorId != null) {
        final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(authorId.toString()).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          username = data?['username'] ?? data?['displayName'] ?? data?['name'] ?? 'Unknown User';
        }
      }
    } catch (e) {
      debugPrint('Username fetch failed: $e');
    }

    // 🔹 Likes Count (list / map / int / subcollection)
    likesCount = await _getLikesCountSafe(postId, postData);

    // 🔹 Comments Count
    try {
      if (postData['comments'] is List) {
        commentsCount = (postData['comments'] as List).length;
      } else if (postData['comments'] is int) {
        commentsCount = postData['comments'];
      } else {
        final commentsColl = FirebaseFirestore.instance
            .collection('artifacts')
            .doc(appId)
            .collection('public')
            .doc('recipes')
            .collection('all')
            .doc(postId)
            .collection('comments');

        final snap = await commentsColl.get();
        commentsCount = snap.size;
      }
    } catch (e) {
      debugPrint('Comments count error: $e');
    }

    return {
      'username': username,
      'likes': likesCount,
      'comments': commentsCount,
    };
  }

  /// --- Robust likes count handler ---
  Future<int> _getLikesCountSafe(String postId, Map<String, dynamic> postData) async {
    final possibleFields = ['likes', 'likedBy', 'likedUsers', 'liked', 'likesCount', 'likeCount'];

    for (final field in possibleFields) {
      if (!postData.containsKey(field)) continue;
      final data = postData[field];
      if (data == null) continue;

      if (data is int) return data;
      if (data is List) return data.length;
      if (data is Map) return data.keys.length;
    }

    // Check if likes are in a subcollection
    try {
      final likesColl = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc(postId)
          .collection('likes');

      final likesSnap = await likesColl.get();
      return likesSnap.size;
    } catch (e) {
      debugPrint('Likes count error: $e');
      return 0;
    }
  }
}
