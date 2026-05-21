import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/utils/recipe_scaler_utils.dart';
import 'package:instachef/utils/unit_converter.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';
  final PageController _pageController = PageController();
  
  // 🍽️ Scaling state
  late int _currentServings;
  bool _isMetric = true;
  String _authorProfileImage = '';

  @override
  void initState() {
    super.initState();
    _currentServings = widget.recipe.defaultServings;
    _fetchAuthorProfile();
  }

  Future<void> _fetchAuthorProfile() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.recipe.userId)
          .get();
      
      if (mounted && userDoc.exists) {
        setState(() {
          _authorProfileImage = userDoc.data()?['profileImageUrl'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching author profile: $e');
    }
  }


  Future<void> _toggleSaveRecipe() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save recipes.')),
      );
      return;
    }

    final userUid = user!.uid;
    final recipeId = widget.recipe.id;

    final userSavedRef = FirebaseFirestore.instance
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
      if (widget.recipe.savedBy.contains(userUid)) {
        await userSavedRef.delete();
        await publicRecipeRef.update({
          'savedBy': FieldValue.arrayRemove([userUid]),
        });
        widget.recipe.savedBy.remove(userUid);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe Unsaved!')),
        );
      } else {
        await userSavedRef.set(widget.recipe.toMapForSavedRecipe());
        await publicRecipeRef.update({
          'savedBy': FieldValue.arrayUnion([userUid]),
        });
        widget.recipe.savedBy.add(userUid);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe Saved!')),
        );
      }
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save recipe: $e')),
      );
    }
  }

  Future<void> _deletePost() async {
    if (user == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: const Text('Are you sure you want to delete this recipe? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc(widget.recipe.id)
          .delete();

      // Clean up saved references
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      for (var userDoc in usersSnapshot.docs) {
        await userDoc.reference
            .collection('savedRecipes')
            .doc(widget.recipe.id)
            .delete();
      }

      if (mounted) {
        Navigator.pop(context); // Go back to profile/home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color.fromRGBO(15, 29, 37, 1);
    const orange = Color.fromRGBO(247, 158, 27, 1);
    final isOwner = widget.recipe.userId == user?.uid;

    return Scaffold(
      backgroundColor: darkBlue,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: darkBlue,
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              title: Text(
                widget.recipe.title,
                style: GoogleFonts.robotoSlab(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: PageView.builder(
                controller: _pageController,
                itemCount: widget.recipe.imageUrls.length,
                itemBuilder: (context, index) {
                  return CachedNetworkImage(
                    imageUrl: widget.recipe.imageUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 50, color: Colors.white),
                  );
                },
              ),
            ),
            actions: [
              // Delete Button (Owner Only)
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deletePost,
                  tooltip: 'Delete Recipe',
                ),
              IconButton(
                icon: Icon(
                  widget.recipe.savedBy.contains(user?.uid)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: widget.recipe.savedBy.contains(user?.uid)
                      ? orange
                      : Colors.white,
                ),
                onPressed: _toggleSaveRecipe,
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              // Page indicator for images
              if (widget.recipe.imageUrls.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: widget.recipe.imageUrls.length,
                      effect: const WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: orange,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: orange,
                          backgroundImage: _authorProfileImage.isNotEmpty
                              ? CachedNetworkImageProvider(_authorProfileImage)
                              : null,
                          child: _authorProfileImage.isEmpty
                              ? Text(
                                  widget.recipe.userName.isNotEmpty ? widget.recipe.userName[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.recipe.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 🔧 Cooking Tools Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(25, 45, 55, 1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: orange.withOpacity(0.3), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings, color: orange, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Cooking Tools',
                                style: GoogleFonts.playfairDisplay(
                                  color: orange,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Servings Slider
                          Row(
                            children: [
                              const Icon(Icons.restaurant, color: Colors.white70, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Servings:',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: orange),
                                onPressed: _currentServings > 1
                                    ? () => setState(() => _currentServings--)
                                    : null,
                              ),
                              Text(
                                _currentServings.toString(),
                                style: TextStyle(
                                  color: orange,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: orange),
                                onPressed: _currentServings < 20
                                    ? () => setState(() => _currentServings++)
                                    : null,
                              ),
                            ],
                          ),
                          
                          // Slider
                          Slider(
                            value: _currentServings.toDouble(),
                            min: 1,
                            max: 20,
                            divisions: 19,
                            activeColor: orange,
                            inactiveColor: Colors.grey[700],
                            onChanged: (value) {
                              setState(() => _currentServings = value.round());
                            },
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Unit Toggle
                          Row(
                            children: [
                              const Icon(Icons.straighten, color: Colors.white70, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Units:',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => setState(() => _isMetric = true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _isMetric ? orange : Colors.grey[800],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Metric'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => setState(() => _isMetric = false),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: !_isMetric ? orange : Colors.grey[800],
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Imperial'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ingredients Section
                    Text(
                      'Ingredients (for $_currentServings servings)',
                      style: GoogleFonts.playfairDisplay(
                        color: orange,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.recipe.ingredients.isEmpty)
                      const Text(
                        "No ingredients added.",
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      ...RecipeScaler.scaleIngredients(
                        widget.recipe.ingredients,
                        widget.recipe.defaultServings,
                        _currentServings,
                      ).map((ingredient) {
                        // Try to convert units if toggled
                        String displayIngredient = ingredient;
                        final parsed = IngredientParser.parse(ingredient);
                        
                        if (parsed.amount != null && parsed.unit != null) {
                          final converted = UnitConverter.convertIngredientText(
                            ingredient,
                            _isMetric,
                            parsed.amount!,
                            parsed.unit,
                            parsed.name,
                          );
                          if (converted != null) {
                            displayIngredient = converted;
                          }
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '• $displayIngredient',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),

                    // Steps Section
                    Text(
                      'Steps',
                      style: GoogleFonts.playfairDisplay(
                        color: orange,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.recipe.steps.isEmpty)
                      const Text(
                        "No steps available.",
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      ...widget.recipe.steps.asMap().entries.map((entry) {
                        int index = entry.key;
                        String step = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: orange,
                                child: Text(
                                  (index + 1).toString(),
                                  style: const TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 24),

                    // Tags Section
                    if (widget.recipe.tags.isNotEmpty) ...[
                      Text(
                        'Tags',
                        style: GoogleFonts.playfairDisplay(
                          color: orange,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: widget.recipe.tags.map((tag) {
                          return Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.grey.shade700,
                            shape: const StadiumBorder(),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
