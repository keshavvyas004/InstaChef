/*import 'dart:io';

class Recipe {
  String title;
  List<File> images;
  List<String> ingredients;
  List<String> steps;
  List<String> tags;
  int likeCount;
  bool isLiked;
  bool isSaved;
  List<String> comments;

  Recipe({
    required this.title,
    required this.images,
    required this.ingredients,
    required this.steps,
    required this.tags,
    this.likeCount = 0,
    this.isLiked = false,
    List<String>? comments,
    this.isSaved = false,
  }) : comments = comments ?? [];
}

import 'dart:io';

class Recipe {
  String id;
  String title;
  List<File> images;
  List<String> imageUrls;  // For storing uploaded Cloudinary URLs
  List<String> ingredients;
  List<String> steps;
  List<String> tags;
  int likeCount;
  bool isLiked;
  bool isSaved;
  List<String> comments;
  String userId;
  String userName;

  Recipe({
    required this.id,
    required this.title,
    required this.images,
    required this.imageUrls,
    required this.ingredients,
    required this.steps,
    required this.tags,
    required this.userId,
    required this.userName,
    this.likeCount = 0,
    this.isLiked = false,
    List<String>? comments,
    this.isSaved = false,
  }) : comments = comments ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrls': imageUrls,
      'ingredients': ingredients,
      'steps': steps,
      'tags': tags,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'isSaved': isSaved,
      'comments': comments,
      'userId': userId,
      'userName': userName,
    };
  }
}
*/
// recipe_model.dart
//import 'package:cloud_firestore/cloud_firestore.dart';
/*
class Recipe {
  final String id;
  final String title;
  final List<String> imageUrls;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tags;
  final String userId;
  final String userName;
  int likeCount;
  final List<String> comments;
  bool isLiked;
  bool isSaved;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.ingredients,
    required this.steps,
    required this.tags,
    required this.userId,
    required this.userName,
    this.likeCount = 0,
    List<String>? comments,
    this.isLiked = false,
    this.isSaved = false,
  }) : comments = comments ?? [];

  // Factory constructor to create a Recipe from a Firestore document
  factory Recipe.fromFirestore(Map<String, dynamic> data) {
    return Recipe(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      likeCount: data['likeCount'] ?? 0,
      comments: List<String>.from(data['comments'] ?? []),
      isLiked: false, // Default to false when fetching from a shared source
      isSaved: false, // Default to false
    );
  }

  // Method to convert a Recipe object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrls': imageUrls,
      'ingredients': ingredients,
      'steps': steps,
      'tags': tags,
      'userId': userId,
      'userName': userName,
      'likeCount': likeCount,
      'comments': comments,
    };
  }
}*/

// lib/screens/recipe_model.dart
/*
import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final List<String> imageUrls;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tags;
  final String userId;
  final String userName;
  int likeCount;
  final List<dynamic> comments;
  final List<String> likedBy;
  final List<String> savedBy;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.ingredients,
    required this.steps,
    required this.tags,
    required this.userId,
    required this.userName,
    this.likeCount = 0,
    List<dynamic>? comments,
    List<String>? likedBy,
    List<String>? savedBy,
  })  : comments = comments ?? [],
        likedBy = likedBy ?? [],
        savedBy = savedBy ?? [];

  factory Recipe.fromFirestore(Map<String, dynamic> data) {
    return Recipe(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      likeCount: data['likeCount'] ?? 0,
      comments: data['comments'] ?? [],
      likedBy: List<String>.from(data['likedBy'] ?? []),
      savedBy: List<String>.from(data['savedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrls': imageUrls,
      'ingredients': ingredients,
      'steps': steps,
      'tags': tags,
      'userId': userId,
      'userName': userName,
      'likeCount': likeCount,
      'comments': comments,
      'likedBy': likedBy,
      'savedBy': savedBy,
    };
  }
}*/
/*
import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final List<String> imageUrls;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tags;
  final String userId;
  final String userName;
  int likeCount;
  final List<dynamic> comments;
  final List<String> likedBy;
  final List<String> savedBy;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.ingredients,
    required this.steps,
    required this.tags,
    required this.userId,
    required this.userName,
    this.likeCount = 0,
    List<dynamic>? comments,
    List<String>? likedBy,
    List<String>? savedBy,
  })  : comments = comments ?? [],
        likedBy = likedBy ?? [],
        savedBy = savedBy ?? [];

  factory Recipe.fromFirestore(Map<String, dynamic> data) {
    return Recipe(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      likeCount: data['likeCount'] ?? 0,
      comments: data['comments'] ?? [],
      likedBy: List<String>.from(data['likedBy'] ?? []),
      savedBy: List<String>.from(data['savedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrls': imageUrls,
      'ingredients': ingredients,
      'steps': steps,
      'tags': tags,
      'userId': userId,
      'userName': userName,
      'likeCount': likeCount,
      'comments': comments,
      'likedBy': likedBy,
      'savedBy': savedBy,
    };
  }

  /// 🔹 Add this method for saving recipes (minimal fields)
  Map<String, dynamic> toMapForSavedRecipe() {
    return {
      'id': id,
      'title': title,
      'imageUrls': imageUrls,
      'userId': userId,
      'userName': userName,
    };
  }
}

 */
import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final List<String> imageUrls;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tags;
  final String userId;
  final String userName;
  int likeCount;
  final List<dynamic> comments;
  final List<String> likedBy;
  final List<String> savedBy;
  final List<String> keywords; // 🔑 Added for search
  final int defaultServings; // 🍽️ Default serving size for scaling

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.ingredients,
    required this.steps,
    required this.tags,
    required this.userId,
    required this.userName,
    this.likeCount = 0,
    List<dynamic>? comments,
    List<String>? likedBy,
    List<String>? savedBy,
    List<String>? keywords,
    this.defaultServings = 4, // Default to 4 servings
  })  : comments = comments ?? [],
        likedBy = likedBy ?? [],
        savedBy = savedBy ?? [],
        keywords = keywords ?? []; // default empty list

  factory Recipe.fromFirestore(Map<String, dynamic> data) {
    return Recipe(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown',
      likeCount: data['likeCount'] ?? 0,
      comments: data['comments'] ?? [],
      likedBy: List<String>.from(data['likedBy'] ?? []),
      savedBy: List<String>.from(data['savedBy'] ?? []),
      keywords: List<String>.from(data['keywords'] ?? []), // 🔑 load keywords
      defaultServings: data['defaultServings'] ?? 4, // Load with default fallback
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrls': imageUrls,
      'ingredients': ingredients,
      'steps': steps,
      'tags': tags,
      'userId': userId,
      'userName': userName,
      'likeCount': likeCount,
      'comments': comments,
      'likedBy': likedBy,
      'savedBy': savedBy,
      'keywords': keywords, // 🔑 save keywords
      'defaultServings': defaultServings, // Save serving size
    };
  }

  /// 🔹 For saving recipes (minimal fields)
  Map<String, dynamic> toMapForSavedRecipe() {
    return {
      'id': id,
      'title': title,
      'imageUrls': imageUrls,
      'userId': userId,
      'userName': userName,
    };
  }
}

