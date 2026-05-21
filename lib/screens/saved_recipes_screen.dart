/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'recipe_data.dart';
import 'RecipeDetailScreen.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedRecipes = RecipeData.recipes.where((r) => r.isSaved).toList();
    final Map<int, PageController> _controllers = {};

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Saved Recipes",
          style: GoogleFonts.cookie(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      ),
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: savedRecipes.isEmpty
          ? const Center(
              child: Text(
                "No saved recipes yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];

                // Assign a PageController per recipe
                _controllers[index] =
                    _controllers[index] ?? PageController(initialPage: 0);

                return Card(
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ✅ Title before image
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 8.0,
                          ),
                          child: Center(
                            child: Text(
                              recipe.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.robotoSlab(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromRGBO(15, 29, 37, 1),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // ✅ Recipe image carousel
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 300,
                            child: PageView.builder(
                              controller: _controllers[index],
                              physics: const BouncingScrollPhysics(),
                              itemCount: recipe.images.length,
                              itemBuilder: (context, imgIndex) {
                                return Image.file(
                                  File(recipe.images[imgIndex].path),
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: 300,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(15, 29, 37, 1),
        body: Center(
          child: Text(
            'Please log in to view saved recipes.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      appBar: AppBar(
        title: const Text(
          'Saved Recipes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ Correct Firestore path to fetch saved recipes
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('savedRecipes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You have no saved recipes yet.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final savedRecipes = snapshot.data!.docs.map((doc) {
            return Recipe.fromFirestore(doc.data() as Map<String, dynamic>);
          }).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: savedRecipes.length,
            itemBuilder: (context, index) {
              final recipe = savedRecipes[index];
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
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                    image: recipe.imageUrls.isNotEmpty
                        ? DecorationImage(
                      image: CachedNetworkImageProvider(recipe.imageUrls.first),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: recipe.imageUrls.isEmpty
                      ? Center(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  Future<List<Recipe>> _getSavedRecipes(String userId) async {
    // Step 1: Get saved recipe IDs
    final savedSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedRecipes')
        .get();

    List<String> savedRecipeIds =
    savedSnapshot.docs.map((doc) => doc.id).toList();

    if (savedRecipeIds.isEmpty) return [];

    // Step 2: Fetch full recipe documents based on saved IDs
    final recipeDocs = await FirebaseFirestore.instance
        .collection('artifacts')
        .doc('1:250338435801:android:ddd8de8871e9db841c54c8')
        .collection('public')
        .doc('recipes')
        .collection('all')
        .where(FieldPath.documentId, whereIn: savedRecipeIds)
        .get();

    return recipeDocs.docs
        .map((doc) => Recipe.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(15, 29, 37, 1),
        body: Center(
          child: Text(
            'Please log in to view saved recipes.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      appBar: AppBar(
        title: const Text(
          'Saved Recipes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _getSavedRecipes(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You have no saved recipes yet.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final savedRecipes = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: savedRecipes.length,
            itemBuilder: (context, index) {
              final recipe = savedRecipes[index];
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
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                    image: recipe.imageUrls.isNotEmpty
                        ? DecorationImage(
                      image: CachedNetworkImageProvider(
                          recipe.imageUrls.first),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: recipe.imageUrls.isEmpty
                      ? Center(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
