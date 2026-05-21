/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MySearchScreen extends StatefulWidget {
  const MySearchScreen({super.key});

  @override
  State<MySearchScreen> createState() => _MySearchScreenState();
}

class _MySearchScreenState extends State<MySearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Placeholder list for recent searches
  final List<String> _recentSearches = [
    'Pasta',
    'Chicken Tikka Masala',
    'Pizza',
    'Salad',
  ];

  void _performSearch(String query) {
    // This is where you would implement your search logic.
    // For now, we'll just print the query.
    print('Searching for: $query');
    // You could also navigate to a results screen or update the UI here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 29, 37, 1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onSubmitted: _performSearch,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search for recipes...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recent Searches Section
            Text(
              'Recent Searches',
              style: GoogleFonts.cookie(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _recentSearches.map((search) {
                return Chip(
                  label: Text(search, style: const TextStyle(color: Color.fromRGBO(15, 29, 37, 1))),
                  backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                  onDeleted: () {
                    setState(() {
                      _recentSearches.remove(search);
                    });
                  },
                  deleteIconColor: Colors.white,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color.fromRGBO(247, 158, 27, 1)),
            const SizedBox(height: 20),

            // Placeholder for search results
            Expanded(
              child: Center(
                child: Text(
                  'Search results will appear here...',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySearchScreen extends StatefulWidget {
  const MySearchScreen({super.key});

  @override
  State<MySearchScreen> createState() => _MySearchScreenState();
}

class _MySearchScreenState extends State<MySearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // ✅ This list is now dynamic and will be populated from SharedPreferences
  List<String> _recentSearches = [];

  List<Recipe> _allRecipes = [];
  List<Recipe> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // ✅ Load recent searches when the screen initializes
    _loadRecentSearches();
    _fetchAllRecipes();
  }

  // ✅ Method to load recent searches from local storage
  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  // ✅ Method to save recent searches to local storage
  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('recentSearches', _recentSearches);
  }

  Future<void> _fetchAllRecipes() async {
    try {
      const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';
      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .get();

      if (mounted) {
        setState(() {
          _allRecipes = snapshot.docs
              .map((doc) => Recipe.fromFirestore(doc.data()))
              .toList();
          _isLoading = false;
          _searchResults = List.from(_allRecipes);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recipes: $e')),
        );
      }
    }
  }

  void _performSearch(String query) {
    final normalizedQuery = query.toLowerCase();

    if (normalizedQuery.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
      // ✅ Save the updated list
      _saveRecentSearches();
    }

    if (normalizedQuery.isEmpty) {
      setState(() {
        _searchResults = List.from(_allRecipes);
      });
    } else {
      setState(() {
        _searchResults = _allRecipes.where((recipe) {
          final titleMatch = recipe.title.toLowerCase().contains(normalizedQuery);
          final ingredientsMatch = recipe.ingredients
              .any((ingredient) => ingredient.toLowerCase().contains(normalizedQuery));
          final tagsMatch = recipe.tags
              .any((tag) => tag.toLowerCase().contains(normalizedQuery));

          return titleMatch || ingredientsMatch || tagsMatch;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color.fromRGBO(15, 29, 37, 1);
    const orange = Color.fromRGBO(247, 158, 27, 1);

    return Scaffold(
      backgroundColor: darkBlue,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _performSearch,
              onSubmitted: _performSearch,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search for recipes...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (_searchController.text.isEmpty && _recentSearches.isNotEmpty) ...[
              Text(
                'Recent Searches',
                style: GoogleFonts.cookie(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _recentSearches.map((search) {
                  return Chip(
                    label: Text(search, style: const TextStyle(color: darkBlue)),
                    backgroundColor: orange,
                    onDeleted: () {
                      setState(() {
                        _recentSearches.remove(search);
                      });
                      // ✅ Save the updated list after deletion
                      _saveRecentSearches();
                    },
                    deleteIconColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Divider(color: orange),
              const SizedBox(height: 20),
            ],

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? Center(
                child: Text(
                  'No results found for "${_searchController.text}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              )
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final recipe = _searchResults[index];
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySearchScreen extends StatefulWidget {
  const MySearchScreen({super.key});

  @override
  State<MySearchScreen> createState() => _MySearchScreenState();
}

class _MySearchScreenState extends State<MySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  List<Recipe> _allRecipes = [];
  List<Recipe> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _fetchAllRecipes();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('recentSearches', _recentSearches);
  }

  Future<void> _fetchAllRecipes() async {
    try {
      const String appId = 'YOUR_APP_ID';
      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .get();

      if (mounted) {
        setState(() {
          _allRecipes = snapshot.docs
              .map((doc) => Recipe.fromFirestore(doc.data()))
              .toList();
          _isLoading = false;
          _searchResults = List.from(_allRecipes);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load recipes: $e')),
        );
      }
    }
  }

  void _performSearch(String query) {
    final normalizedQuery = query.toLowerCase().trim();

    // Only save to recent searches if the query is not empty
    if (normalizedQuery.isNotEmpty) {
      // Check if the query is already in the list to prevent duplicates
      final isAlreadyInList = _recentSearches.any((search) => search.toLowerCase() == normalizedQuery);

      if (!isAlreadyInList) {
        setState(() {
          _recentSearches.insert(0, query.trim());
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        });
        _saveRecentSearches();
      }
    }

    // Filter recipes based on the search query
    if (normalizedQuery.isEmpty) {
      setState(() {
        _searchResults = List.from(_allRecipes);
      });
    } else {
      setState(() {
        _searchResults = _allRecipes.where((recipe) {
          final titleMatch = recipe.title.toLowerCase().contains(normalizedQuery);
          final ingredientsMatch = recipe.ingredients
              .any((ingredient) => ingredient.toLowerCase().contains(normalizedQuery));
          final tagsMatch = recipe.tags
              .any((tag) => tag.toLowerCase().contains(normalizedQuery));

          return titleMatch || ingredientsMatch || tagsMatch;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color.fromRGBO(15, 29, 37, 1);
    const orange = Color.fromRGBO(247, 158, 27, 1);

    return Scaffold(
      backgroundColor: darkBlue,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onSubmitted: _performSearch,
              onChanged: (value) {
                // Perform search logic on every keystroke to update results in real-time
                _performSearch(value);
              },
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search for recipes...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recent Searches Section (only shown when search bar is empty)
            if (_searchController.text.isEmpty && _recentSearches.isNotEmpty) ...[
              Text(
                'Recent Searches',
                style: GoogleFonts.cookie(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _recentSearches.map((search) {
                  return Chip(
                    label: Text(search, style: const TextStyle(color: darkBlue)),
                    backgroundColor: orange,
                    onDeleted: () {
                      setState(() {
                        _recentSearches.remove(search);
                      });
                      _saveRecentSearches();
                    },
                    deleteIconColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Divider(color: orange),
              const SizedBox(height: 20),
            ],

            // Search Results Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? Center(
                child: Text(
                  'No results found for "${_searchController.text}"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              )
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final recipe = _searchResults[index];
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instachef/screens/recipe_model.dart';
import 'package:instachef/screens/RecipeDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class MySearchScreen extends StatefulWidget {
  const MySearchScreen({super.key});

  @override
  State<MySearchScreen> createState() => _MySearchScreenState();
}

class _MySearchScreenState extends State<MySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (query.trim().isEmpty) return;

    if (_searchHistory.contains(query)) {
      _searchHistory.remove(query);
    }
    _searchHistory.insert(0, query);

    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }

    await prefs.setStringList('searchHistory', _searchHistory);
  }

  Future<void> _deleteSearchHistoryItem(String query) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(query);
    });
    await prefs.setStringList('searchHistory', _searchHistory);
  }

  Future<void> _clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.clear();
    });
    await prefs.remove('searchHistory');
  }

  Future<List<Recipe>> _searchRecipes(String query) async {
    if (query.isEmpty) return [];

    try {
      const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';
      final normalizedQuery = query.toLowerCase().trim();

      // Fetch all recipes first
      final snapshot = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .get();

      List<Recipe> recipes = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Ensure username is always available
        String? userName = data['userName'];
        if ((userName == null || userName.isEmpty) && data['userId'] != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(data['userId'])
              .get();
          userName = userDoc.data()?['username'] ?? 'Unknown';
          data['userName'] = userName;
        }

        final recipe = Recipe.fromFirestore(data);

        // Client-side filtering: match title, tags, ingredients, or keywords
        final titleMatch = recipe.title.toLowerCase().contains(normalizedQuery);
        final tagMatch = recipe.tags.any(
            (tag) => tag.toLowerCase().contains(normalizedQuery));
        final ingredientMatch = recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(normalizedQuery));
        final keywordMatch = recipe.keywords.any(
            (keyword) => keyword.toLowerCase().contains(normalizedQuery));

        if (titleMatch || tagMatch || ingredientMatch || keywordMatch) {
          recipes.add(recipe);
        }
      }

      return recipes;
    } catch (e) {
      debugPrint("Error fetching recipes: $e");
      return [];
    }
  }

  void _onSearch() {
    setState(() {
      _searchTerm = _searchController.text.trim();
    });
    _saveSearchHistory(_searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF0F1D25);
    const orange = Color(0xFFF79E1B);

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: Text(
          "Search Recipes",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search recipes...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, color: orange),
                  onPressed: _onSearch,
                ),
              ],
            ),
          ),

          // 📜 Search history
          if (_searchTerm.isEmpty)
            Expanded(
              child: Column(
                children: [
                   if (_searchHistory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Searches",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: _clearSearchHistory,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                            child: const Text("Clear All"),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: _searchHistory.isEmpty
                        ? const Center(
                            child: Text(
                              "No recent searches",
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchHistory.length,
                            itemBuilder: (context, index) {
                              final query = _searchHistory[index];
                              return ListTile(
                                leading: const Icon(Icons.history, color: Colors.white54),
                                title: Text(query, style: GoogleFonts.poppins(color: Colors.white)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white30, size: 20),
                                  onPressed: () => _deleteSearchHistoryItem(query),
                                ),
                                onTap: () {
                                  _searchController.text = query;
                                  _onSearch();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: FutureBuilder<List<Recipe>>(
                future: _searchRecipes(_searchTerm),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Shimmer.fromColors(
                       baseColor: Colors.grey[800]!,
                       highlightColor: Colors.grey[700]!,
                       child: ListView.builder(
                         itemCount: 5,
                         itemBuilder: (_, __) => Card(
                           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           child: const SizedBox(height: 80),
                         ),
                       ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matching recipes found.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final recipes = snapshot.data!;
                  return ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return Card(
                        color: Colors.grey[850],
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: recipe.imageUrls.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: recipe.imageUrls.first,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Icon(Icons.fastfood, size: 40, color: orange),
                          title: Text(
                            recipe.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            "By ${recipe.userName}",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                          },
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
  }
}
