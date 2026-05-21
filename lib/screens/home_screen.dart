/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'recipe_model.dart';
import 'recipe_data.dart';
import 'RecipeDetailScreen.dart';
import 'saved_recipes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _commentController = TextEditingController();

  // Store page controllers for each recipe
  final Map<int, PageController> _controllers = {};

  PageController _getController(int index) {
    return _controllers.putIfAbsent(index, () => PageController());
  }

  void _toggleLike(Recipe recipe) {
    setState(() {
      recipe.isLiked = !recipe.isLiked;
      recipe.likeCount += recipe.isLiked ? 1 : -1;
    });
  }

  void _toggleSave(Recipe recipe) {
    setState(() {
      recipe.isSaved = !recipe.isSaved;
    });
  }

  void _addComment(Recipe recipe, String comment) {
    if (comment.trim().isEmpty) return;
    setState(() {
      recipe.comments.add(comment.trim());
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = RecipeData.recipes;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: recipes.isEmpty
          ? const Center(
              child: Text(
                "No recipes yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final controller = _getController(index);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Title above image (centered)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: Text(
                            recipe.title,
                            style: GoogleFonts.cookie(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromRGBO(15, 29, 37, 1),
                            ),
                          ),
                        ),
                      ),

                      // ✅ Recipe Images with PageView
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 300,
                          child: PageView.builder(
                            controller: controller,
                            physics: const BouncingScrollPhysics(),
                            itemCount: recipe.images.length,
                            itemBuilder: (context, imgIndex) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          RecipeDetailScreen(recipe: recipe),
                                    ),
                                  );
                                },
                                child: Image.file(
                                  recipe.images[imgIndex],
                                  fit: BoxFit.contain, // ✅ full image visible
                                  width: double.infinity,
                                  height: 300,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // ✅ Dots Indicator
                      if (recipe.images.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: controller,
                              count: recipe.images.length,
                              effect: const WormEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                activeDotColor: Colors.black,
                                dotColor: Colors.grey,
                              ),
                            ),
                          ),
                        ),

                      // ✅ Like + Comment + Save Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            // Like
                            IconButton(
                              icon: Icon(
                                recipe.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: recipe.isLiked
                                    ? Colors.red
                                    : Colors.black,
                              ),
                              onPressed: () => _toggleLike(recipe),
                            ),
                            Text("${recipe.likeCount}"),
                            const SizedBox(width: 16),

                            // Comment
                            IconButton(
                              icon: const Icon(
                                Icons.comment,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (_) => _buildCommentSheet(recipe),
                                );
                              },
                            ),
                            Text("${recipe.comments.length}"),
                            const SizedBox(width: 16),

                            // Save
                            IconButton(
                              icon: Icon(
                                recipe.isSaved
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: recipe.isSaved
                                    ? Colors.blue
                                    : Colors.black,
                              ),
                              onPressed: () => _toggleSave(recipe),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ✅ Bottom sheet for comments
  Widget _buildCommentSheet(Recipe recipe) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Comments",
              style: GoogleFonts.cookie(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(15, 29, 37, 1),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: recipe.comments.length,
                itemBuilder: (context, index) =>
                    ListTile(title: Text(recipe.comments[index])),
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _addComment(recipe, _commentController.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'recipe_model.dart';
import 'recipe_data.dart';
import 'RecipeDetailScreen.dart';
import 'saved_recipes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _commentController = TextEditingController();

  // Store page controllers for each recipe
  final Map<int, PageController> _controllers = {};

  PageController _getController(int index) {
    return _controllers.putIfAbsent(index, () => PageController());
  }

  void _toggleLike(Recipe recipe) {
    setState(() {
      recipe.isLiked = !recipe.isLiked;
      recipe.likeCount += recipe.isLiked ? 1 : -1;
    });
  }

  void _toggleSave(Recipe recipe) {
    setState(() {
      recipe.isSaved = !recipe.isSaved;
    });
  }

  void _addComment(Recipe recipe, String comment) {
    if (comment.trim().isEmpty) return;
    setState(() {
      recipe.comments.add(comment.trim());
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = RecipeData.recipes;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: recipes.isEmpty
          ? const Center(
        child: Text(
          "No recipes yet",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          final controller = _getController(index);

          return Card(
            margin: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: Text(
                      recipe.title,
                      style: GoogleFonts.cookie(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromRGBO(15, 29, 37, 1),
                      ),
                    ),
                  ),
                ),

                // Recipe Images
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: PageView.builder(
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      itemCount: recipe.images.length,
                      itemBuilder: (context, imgIndex) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                          },
                          child: Image.file(
                            recipe.images[imgIndex],  // ✅ Correct usage
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: 300,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Dots Indicator
                if (recipe.images.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: recipe.images.length,
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Colors.black,
                          dotColor: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                // Like + Comment + Save Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          recipe.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                          recipe.isLiked ? Colors.red : Colors.black,
                        ),
                        onPressed: () => _toggleLike(recipe),
                      ),
                      Text("${recipe.likeCount}"),
                      const SizedBox(width: 16),

                      IconButton(
                        icon: const Icon(
                          Icons.comment,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) =>
                                _buildCommentSheet(recipe),
                          );
                        },
                      ),
                      Text("${recipe.comments.length}"),
                      const SizedBox(width: 16),

                      IconButton(
                        icon: Icon(
                          recipe.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color:
                          recipe.isSaved ? Colors.blue : Colors.black,
                        ),
                        onPressed: () => _toggleSave(recipe),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentSheet(Recipe recipe) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Comments",
              style: GoogleFonts.cookie(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(15, 29, 37, 1),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: recipe.comments.length,
                itemBuilder: (context, index) =>
                    ListTile(title: Text(recipe.comments[index])),
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () =>
                      _addComment(recipe, _commentController.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/

/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart'; // Added import
import 'recipe_model.dart';
import 'RecipeDetailScreen.dart';
import 'saved_recipes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, PageController> _controllers = {};

  PageController _getController(String recipeId) {
    return _controllers.putIfAbsent(recipeId, () => PageController());
  }

  void _toggleLike(Recipe recipe) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      recipe.isLiked = !recipe.isLiked;
      recipe.likeCount += recipe.isLiked ? 1 : -1;
    });

    await FirebaseFirestore.instance
        .collection('artifacts')
        .doc('1:250338435801:android:ddd8de8871e9db841c54c8')
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id)
        .update({
      'likeCount': recipe.likeCount,
    });
  }

  void _toggleSave(Recipe recipe) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    recipe.isSaved = !recipe.isSaved;

    final savedDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_recipes')
        .doc(recipe.id);

    if (recipe.isSaved) {
      await savedDocRef.set({'recipeId': recipe.id});
    } else {
      await savedDocRef.delete();
    }

    setState(() {}); // Force rebuild to reflect save state
  }

  Future<void> _addComment(Recipe recipe, String commentText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || commentText.trim().isEmpty) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final username = userDoc.data()?['username'] ?? 'Anonymous';

    final newComment = {
      'text': commentText.trim(),
      'username': username,
      'timestamp': FieldValue.serverTimestamp(),
    };

    recipe.comments.add('${username}: ${commentText.trim()}');

    await FirebaseFirestore.instance
        .collection('artifacts')
        .doc('1:250338435801:android:ddd8de8871e9db841c54c8')
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id)
        .update({
      'comments': FieldValue.arrayUnion([newComment]),
    });

    _commentController.clear();
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('artifacts')
            .doc('1:250338435801:android:ddd8de8871e9db841c54c8')
            .collection('public')
            .doc('recipes')
            .collection('all')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No recipes yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final recipes = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Recipe.fromFirestore(data);
          }).toList();

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final controller = _getController(recipe.id);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(recipe.userId)
                    .get(),
                builder: (context, userSnapshot) {
                  String postUsername = 'Unknown User';
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    postUsername = userData['username'] ?? 'Unknown User';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            postUsername,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // ... rest of the card content ...
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Text(
                              recipe.title,
                              style: GoogleFonts.cookie(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromRGBO(15, 29, 37, 1),
                              ),
                            ),
                          ),
                        ),
                        // ... images and buttons ...
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 300,
                            child: PageView.builder(
                              controller: controller,
                              physics: const BouncingScrollPhysics(),
                              itemCount: recipe.imageUrls.length,
                              itemBuilder: (context, imgIndex) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RecipeDetailScreen(recipe: recipe),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    recipe.imageUrls[imgIndex],
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: 300,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (recipe.imageUrls.length > 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: SmoothPageIndicator(
                                controller: controller,
                                count: recipe.imageUrls.length,
                                effect: const WormEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  activeDotColor: Colors.black,
                                  dotColor: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  recipe.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: recipe.isLiked ? Colors.red : Colors.black,
                                ),
                                onPressed: () => _toggleLike(recipe),
                              ),
                              Text("${recipe.likeCount}"),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.comment,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (_) =>
                                        _buildCommentSheet(recipe),
                                  );
                                },
                              ),
                              Text("${recipe.comments.length}"),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: Icon(
                                  recipe.isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: recipe.isSaved ? Colors.blue : Colors.black,
                                ),
                                onPressed: () => _toggleSave(recipe),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCommentSheet(Recipe recipe) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Comments",
              style: GoogleFonts.cookie(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(15, 29, 37, 1),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: recipe.comments.length,
                itemBuilder: (context, index) =>
                    ListTile(title: Text(recipe.comments[index])),
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _addComment(recipe, _commentController.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'package:instachef/screens/saved_recipes_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:instachef/widgets/recipe_image_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, PageController> _controllers = {};
  final user = FirebaseAuth.instance.currentUser;
  final String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';

  PageController _getController(String recipeId) {
    return _controllers.putIfAbsent(recipeId, () => PageController());
  }

  void _toggleLike(Recipe recipe) async {
    if (user == null) return;
    final recipeRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id);

    if (recipe.likedBy.contains(user!.uid)) {
      recipe.likedBy.remove(user!.uid);
      recipe.likeCount--;
    } else {
      recipe.likedBy.add(user!.uid);
      recipe.likeCount++;
    }

    await recipeRef.update({
      'likedBy': recipe.likedBy,
      'likeCount': recipe.likeCount,
    });
    setState(() {});
  }

  void _toggleSave(Recipe recipe) async {
    if (user == null) return;
    final savedDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('savedRecipes')
        .doc(recipe.id);

    if (recipe.savedBy.contains(user!.uid)) {
      recipe.savedBy.remove(user!.uid);
      await savedDocRef.delete();
    } else {
      recipe.savedBy.add(user!.uid);
      // ✅ FIX: use toMapForSavedRecipe() instead of toMap()
      await savedDocRef.set(recipe.toMapForSavedRecipe());
    }
    setState(() {});
  }

  Future<void> _addComment(Recipe recipe, String commentText) async {
    if (user == null || commentText.trim().isEmpty) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final username = userDoc.data()?['username'] ?? 'Anonymous';

    final newComment = {
      'text': commentText.trim(),
      'username': username,
      'userId': user!.uid,
      // 'timestamp': DateTime.now().toUtc().toString(),
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id)
        .update({
      'comments': FieldValue.arrayUnion([newComment]),
    });

    _commentController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('Please log in.'));
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('artifacts')
            .doc(appId)
            .collection('public')
            .doc('recipes')
            .collection('all')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No recipes yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final recipes = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Recipe.fromFirestore(data);
          }).toList();

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final controller = _getController(recipe.id);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(recipe.userId)
                    .get(),
                builder: (context, userSnapshot) {
                  String postUsername = 'Unknown User';
                  String postProfileImage = '';
                  
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                    postUsername = userData['username'] ?? 'Unknown User';
                    postProfileImage = userData['profileImageUrl'] ?? '';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                                  backgroundImage: postProfileImage.isNotEmpty
                                      ? CachedNetworkImageProvider(postProfileImage)
                                      : null,
                                  child: postProfileImage.isEmpty
                                      ? (postUsername.isNotEmpty
                                          ? Text(
                                              postUsername[0].toUpperCase(),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            )
                                          : const Icon(Icons.person, color: Colors.white, size: 20))
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  postUsername,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Text(
                              recipe.title,
                              style: GoogleFonts.cookie(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromRGBO(15, 29, 37, 1),
                              ),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 300,
                            child: PageView.builder(
                              controller: controller,
                              physics: const BouncingScrollPhysics(),
                              itemCount: recipe.imageUrls.length,
                              itemBuilder: (context, imgIndex) {
                                return RecipeImageItem(
                                  imageUrl: recipe.imageUrls[imgIndex],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RecipeDetailScreen(recipe: recipe),
                                      ),
                                    );
                                  },
                                  onDoubleTap: () => _toggleLike(recipe),
                                  isLiked: recipe.likedBy.contains(user!.uid),
                                );
                              },
                            ),
                          ),
                        ),
                        if (recipe.imageUrls.length > 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: SmoothPageIndicator(
                                controller: controller,
                                count: recipe.imageUrls.length,
                                effect: const WormEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  activeDotColor: Colors.black,
                                  dotColor: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  recipe.likedBy.contains(user!.uid)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: recipe.likedBy.contains(user!.uid)
                                      ? Colors.red
                                      : Colors.black,
                                ),
                                onPressed: () => _toggleLike(recipe),
                              ),
                              Text("${recipe.likeCount}"),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.comment,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (_) => _buildCommentSheet(recipe),
                                  );
                                },
                              ),
                              Text("${recipe.comments.length}"),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: Icon(
                                  recipe.savedBy.contains(user!.uid)
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: recipe.savedBy.contains(user!.uid)
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                                onPressed: () => _toggleSave(recipe),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCommentSheet(Recipe recipe) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Comments",
              style: GoogleFonts.cookie(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(15, 29, 37, 1),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: recipe.comments.length,
                itemBuilder: (context, index) {
                  final commentData = recipe.comments[index] as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      commentData['username'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(commentData['text'] ?? ''),
                  );
                },
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _addComment(recipe, _commentController.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, PageController> _controllers = {};
  final user = FirebaseAuth.instance.currentUser;
  final String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';

  PageController _getController(String recipeId) {
    return _controllers.putIfAbsent(recipeId, () => PageController());
  }

  void _toggleLike(Recipe recipe) async {
    if (user == null) return;
    final recipeRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id);

    if (recipe.likedBy.contains(user!.uid)) {
      recipe.likedBy.remove(user!.uid);
      recipe.likeCount--;
    } else {
      recipe.likedBy.add(user!.uid);
      recipe.likeCount++;
    }

    await recipeRef.update({
      'likedBy': recipe.likedBy,
      'likeCount': recipe.likeCount,
    });
    setState(() {});
  }

  void _toggleSave(Recipe recipe) async {
    if (user == null) return;
    final savedDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('savedRecipes')
        .doc(recipe.id);

    if (recipe.savedBy.contains(user!.uid)) {
      recipe.savedBy.remove(user!.uid);
      await savedDocRef.delete();
    } else {
      recipe.savedBy.add(user!.uid);
      // ✅ FIX: use toMapForSavedRecipe() instead of toMap()
      await savedDocRef.set(recipe.toMapForSavedRecipe());
    }
    setState(() {});
  }

  Future<void> _addComment(Recipe recipe, String commentText) async {
    if (user == null || commentText.trim().isEmpty) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final username = userDoc.data()?['username'] ?? 'Anonymous';

    final newComment = {
      'text': commentText.trim(),
      'username': username,
      'userId': user!.uid,
      'timestamp': DateTime.now().toUtc().toString(), // ✅ FIXED: no FieldValue.serverTimestamp()
    };

    await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id)
        .update({
      'comments': FieldValue.arrayUnion([newComment]),
    });

    _commentController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('Please log in.'));
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('artifacts')
            .doc(appId)
            .collection('public')
            .doc('recipes')
            .collection('all')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No recipes yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final recipes = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Recipe.fromFirestore(data);
          }).toList();

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final controller = _getController(recipe.id);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(recipe.userId)
                    .get(),
                builder: (context, userSnapshot) {
                  String postUsername = 'Unknown User';
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    postUsername = userData['username'] ?? 'Unknown User';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            postUsername,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Text(
                              recipe.title,
                              style: GoogleFonts.cookie(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromRGBO(15, 29, 37, 1),
                              ),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 300,
                            child: PageView.builder(
                              controller: controller,
                              physics: const BouncingScrollPhysics(),
                              itemCount: recipe.imageUrls.length,
                              itemBuilder: (context, imgIndex) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RecipeDetailScreen(recipe: recipe),
                                      ),
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: recipe.imageUrls[imgIndex],
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: 300,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (recipe.imageUrls.length > 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: SmoothPageIndicator(
                                controller: controller,
                                count: recipe.imageUrls.length,
                                effect: const WormEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  activeDotColor: Colors.black,
                                  dotColor: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  recipe.likedBy.contains(user!.uid)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: recipe.likedBy.contains(user!.uid) ? Colors.red : Colors.black,
                                ),
                                onPressed: () => _toggleLike(recipe),
                              ),
                              Text("${recipe.likeCount}"),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.comment,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (_) => _buildCommentSheet(recipe),
                                  );
                                },
                              ),
                              Text("${recipe.comments.length}"),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: Icon(
                                  recipe.savedBy.contains(user!.uid)
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: recipe.savedBy.contains(user!.uid) ? Colors.blue : Colors.black,
                                ),
                                onPressed: () => _toggleSave(recipe),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
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

  Widget _buildCommentSheet(Recipe recipe) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Comments",
              style: GoogleFonts.cookie(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(15, 29, 37, 1),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: recipe.comments.length,
                itemBuilder: (context, index) {
                  final commentData = recipe.comments[index] as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      commentData['username'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(commentData['text'] ?? ''),
                  );
                },
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _addComment(recipe, _commentController.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'package:instachef/screens/public_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, PageController> _controllers = {};
  final user = FirebaseAuth.instance.currentUser;
  final String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';

  PageController _getController(String recipeId) {
    return _controllers.putIfAbsent(recipeId, () => PageController());
  }

  void _toggleLike(Recipe recipe) async {
    if (user == null) return;
    final recipeRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id);

    if (recipe.likedBy.contains(user!.uid)) {
      recipe.likedBy.remove(user!.uid);
      recipe.likeCount--;
    } else {
      recipe.likedBy.add(user!.uid);
      recipe.likeCount++;
    }

    await recipeRef.update({
      'likedBy': recipe.likedBy,
      'likeCount': recipe.likeCount,
    });
    setState(() {});
  }

  void _toggleSave(Recipe recipe) async {
    if (user == null) return;
    final userUid = user!.uid;
    final recipeId = recipe.id;

    final savedDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('savedRecipes')
        .doc(recipeId);

    final publicRecipeRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipeId);

    try {
      if (recipe.savedBy.contains(userUid)) {
        // Unsave the recipe
        await savedDocRef.delete();
        await publicRecipeRef.update({
          'savedBy': FieldValue.arrayRemove([userUid]),
        });
        recipe.savedBy.remove(userUid);
      } else {
        // Save the recipe
        await savedDocRef.set(recipe.toMapForSavedRecipe());
        await publicRecipeRef.update({
          'savedBy': FieldValue.arrayUnion([userUid]),
        });
        recipe.savedBy.add(userUid);
      }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            recipe.savedBy.contains(userUid) ? 'Recipe Saved!' : 'Recipe Unsaved!',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save recipe: $e')),
      );
    }
  }

  Future<void> _addComment(Recipe recipe, String commentText) async {
    if (user == null || commentText.trim().isEmpty) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final username = userDoc.data()?['username'] ?? 'Anonymous';

    final newComment = {
      'text': commentText.trim(),
      'username': username,
      'userId': user!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    final recipeRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id);

    await recipeRef.update({
      'comments': FieldValue.arrayUnion([newComment]),
    });

    _commentController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('Please log in.'));
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('artifacts')
            .doc(appId)
            .collection('public')
            .doc('recipes')
            .collection('all')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No recipes yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final recipes = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Recipe.fromFirestore(data);
          }).toList();

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final controller = _getController(recipe.id);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(recipe.userId)
                    .get(),
                builder: (context, userSnapshot) {
                  String postUsername = 'Unknown User';
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    postUsername = userData['username'] ?? 'Unknown User';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            postUsername,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Text(
                              recipe.title,
                              style: GoogleFonts.cookie(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromRGBO(15, 29, 37, 1),
                              ),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 300,
                            child: PageView.builder(
                              controller: controller,
                              physics: const BouncingScrollPhysics(),
                              itemCount: recipe.imageUrls.length,
                              itemBuilder: (context, imgIndex) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            RecipeDetailScreen(recipe: recipe),
                                      ),
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: recipe.imageUrls[imgIndex],
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: 300,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (recipe.imageUrls.length > 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: SmoothPageIndicator(
                                controller: controller,
                                count: recipe.imageUrls.length,
                                effect: const WormEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  activeDotColor: Colors.black,
                                  dotColor: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  recipe.likedBy.contains(user!.uid)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: recipe.likedBy.contains(user!.uid) ? Colors.red : Colors.black,
                                ),
                                onPressed: () => _toggleLike(recipe),
                              ),
                              Text("${recipe.likeCount}"),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.comment,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (_) => _buildCommentSheet(recipe),
                                  );
                                },
                              ),
                              Text("${recipe.comments.length}"),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: Icon(
                                  recipe.savedBy.contains(user!.uid)
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: recipe.savedBy.contains(user!.uid) ? Colors.blue : Colors.black,
                                ),
                                onPressed: () => _toggleSave(recipe),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
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

  Widget _buildCommentSheet(Recipe recipe) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Comments",
              style: GoogleFonts.cookie(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(15, 29, 37, 1),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: recipe.comments.length,
                itemBuilder: (context, index) {
                  final commentData = recipe.comments[index] as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      commentData['username'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(commentData['text'] ?? ''),
                  );
                },
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _addComment(recipe, _commentController.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instachef/screens/public_profile_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'package:instachef/screens/message_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:instachef/widgets/recipe_image_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _commentController = TextEditingController();
  final Map<String, PageController> _controllers = {};
  final user = FirebaseAuth.instance.currentUser;
  final String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';

  PageController _getController(String recipeId) {
    return _controllers.putIfAbsent(recipeId, () => PageController());
  }

  // ----------------- LIKE TOGGLE -----------------
  Future<void> _toggleLike(Recipe recipe) async {
    if (user == null) return;
    final recipeRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id);

    final isLiked = recipe.likedBy.contains(user!.uid);

    await recipeRef.update({
      'likedBy': isLiked
          ? FieldValue.arrayRemove([user!.uid])
          : FieldValue.arrayUnion([user!.uid]),
      'likeCount': FieldValue.increment(isLiked ? -1 : 1),
    });
  }

  // ----------------- SAVE TOGGLE -----------------
  Future<void> _toggleSave(Recipe recipe) async {
    if (user == null) return;

    final userUid = user!.uid;
    final savedDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('savedRecipes')
        .doc(recipe.id);

    final recipeRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id);

    final isSaved = recipe.savedBy.contains(userUid);

    try {
      if (isSaved) {
        await savedDocRef.delete();
        await recipeRef.update({
          'savedBy': FieldValue.arrayRemove([userUid]),
        });
      } else {
        await savedDocRef.set(recipe.toMapForSavedRecipe());
        await recipeRef.update({
          'savedBy': FieldValue.arrayUnion([userUid]),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved ? 'Recipe Unsaved!' : 'Recipe Saved!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ----------------- ADD COMMENT -----------------
  Future<void> _addComment(Recipe recipe, String commentText) async {
    if (user == null || commentText.trim().isEmpty) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final username = userDoc.data()?['username'] ?? 'Anonymous';
    final newComment = {
      'text': commentText.trim(),
      'username': username,
      'userId': user!.uid,
      'timestamp': DateTime.now().toIso8601String(), // ✅ use DateTime, not FieldValue
    };

    final recipeRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id);

    await recipeRef.update({
      'comments': FieldValue.arrayUnion([newComment]),
    });

    _commentController.clear();
  }

  // ----------------- SHARE RECIPE -----------------
  void _showShareRecipeSheet(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Share "${recipe.title}"',
                style: GoogleFonts.cookie(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Option 1: Go to Messages
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color.fromRGBO(247, 158, 27, 1),
                  child: Icon(Icons.message, color: Colors.white),
                ),
                title: const Text('Send via Chat', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Choose a user to share with', style: TextStyle(color: Colors.white54)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MessageScreen(recipeToShare: recipe)),
                  );
                },
              ),
              const Divider(color: Colors.white24),
              // Option 2: Share on other platforms (WhatsApp, Instagram, etc.)
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color.fromRGBO(247, 158, 27, 1),
                  child: Icon(Icons.share, color: Colors.white),
                ),
                title: const Text('Share on Other Platforms', style: TextStyle(color: Colors.white)),
                subtitle: const Text('WhatsApp, Instagram, etc.', style: TextStyle(color: Colors.white54)),
                onTap: () {
                  Navigator.pop(context);
                  // Create a shareable text with recipe details
                  final shareText = '''
🍳 ${recipe.title}

📝 Ingredients:
${recipe.ingredients.join('\n')}

👨‍🍳 Instructions:
${recipe.steps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

${recipe.imageUrls.isNotEmpty ? '📷 Check out the recipe image!' : ''}

Shared from InstaChef 🔥
                  '''.trim();

                  Share.share(
                    shareText,
                    subject: 'Check out this recipe: ${recipe.title}',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ----------------- UI BUILD -----------------
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('Please log in.'));
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('artifacts')
            .doc(appId)
            .collection('public')
            .doc('recipes')
            .collection('all')
            .orderBy('id')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No recipes yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final recipes = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Recipe.fromFirestore(data);
          }).toList();

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final controller = _getController(recipe.id);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(recipe.userId)
                    .get(),
                builder: (context, userSnapshot) {
                  String postUsername = 'Unknown User';
                  String postProfileImage = '';
                  
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                    postUsername = userData['username'] ?? 'Unknown User';
                    postProfileImage = userData['profileImageUrl'] ?? '';
                  }

                  return Card(
                    margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username with Profile Photo
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: GestureDetector(
                            onTap: () {
                              if (recipe.userId != user!.uid) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PublicProfileScreen(userId: recipe.userId),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                                  backgroundImage: postProfileImage.isNotEmpty
                                      ? CachedNetworkImageProvider(postProfileImage)
                                      : null,
                                  child: postProfileImage.isEmpty
                                      ? (postUsername.isNotEmpty
                                          ? Text(
                                              postUsername[0].toUpperCase(),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            )
                                          : const Icon(Icons.person, color: Colors.white, size: 20))
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  postUsername,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Title
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              recipe.title,
                              style: GoogleFonts.cookie(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromRGBO(15, 29, 37, 1),
                              ),
                            ),
                          ),
                        ),

                        // Image Carousel
                        ClipRRect(
                          borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                          child: SizedBox(
                            width: double.infinity,
                            height: 300,
                            child: PageView.builder(
                              controller: controller,
                              physics: const BouncingScrollPhysics(),
                              itemCount: recipe.imageUrls.length,
                              itemBuilder: (context, imgIndex) {
                                return RecipeImageItem(
                                  imageUrl: recipe.imageUrls[imgIndex],
                                  isLiked: recipe.likedBy.contains(user!.uid),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RecipeDetailScreen(recipe: recipe),
                                      ),
                                    );
                                  },
                                  onDoubleTap: () => _toggleLike(recipe),
                                );
                              },
                            ),
                          ),
                        ),

                        // Page indicator
                        if (recipe.imageUrls.length > 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Center(
                              child: SmoothPageIndicator(
                                controller: controller,
                                count: recipe.imageUrls.length,
                                effect: const WormEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  activeDotColor: Colors.black,
                                  dotColor: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                        // Like / Comment / Send buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  recipe.likedBy.contains(user!.uid)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: recipe.likedBy.contains(user!.uid)
                                      ? Colors.red
                                      : Colors.black,
                                ),
                                onPressed: () => _toggleLike(recipe),
                              ),
                              Text("${recipe.likeCount}"),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.comment, color: Colors.black),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    builder: (_) => _buildCommentSheet(recipe),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              // Send/Share button (next to comment)
                              IconButton(
                                icon: const Icon(Icons.send, color: Color.fromRGBO(247, 158, 27, 1)),
                                tooltip: 'Share recipe',
                                onPressed: () => _showShareRecipeSheet(recipe),
                              ),
                              const Spacer(),
                              // Save icon at bottom right
                              IconButton(
                                icon: Icon(
                                  recipe.savedBy.contains(user!.uid)
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: recipe.savedBy.contains(user!.uid)
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                                onPressed: () => _toggleSave(recipe),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ).animate()
                   .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                   .slideY(begin: 0.1, end: 0, duration: 300.ms);
                },
              );
            },
          );
        },
      ),
    );
  }

  // ----------------- COMMENTS BOTTOM SHEET -----------------
  Widget _buildCommentSheet(Recipe recipe) {
    final recipeRef = FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('recipes')
        .collection('all')
        .doc(recipe.id);

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        
        return Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Comments",
                    style: GoogleFonts.cookie(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(15, 29, 37, 1),
                    ),
                  ),
                ),

                // Comments list
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: recipeRef.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      final comments = (data['comments'] ?? []) as List;

                      if (comments.isEmpty) {
                        return const Center(child: Text("No comments yet"));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index] as Map<String, dynamic>;
                          return ListTile(
                            title: Text(
                              comment['username'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            subtitle: Text(
                              comment['text'] ?? '',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Comment Input Field
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    cursorColor: const Color.fromRGBO(247, 158, 27, 1),
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color.fromRGBO(247, 158, 27, 1), width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: Color.fromRGBO(247, 158, 27, 1)),
                        onPressed: () async {
                          final text = _commentController.text;
                          if (text.trim().isEmpty) return;
                          
                          await _addComment(recipe, text);
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comment posted!')),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
