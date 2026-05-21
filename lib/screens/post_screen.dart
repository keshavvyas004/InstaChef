/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_model.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<File> selectedImages = [];
  List<String> ingredientList = [];
  List<String> stepsList = [];
  List<String> tagsList = [];
  String recipeTitle = '';
  bool _isUploading = false;

  Future<List<String>> uploadImagesToCloudinary(List<File> images) async {
    const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/da0i4vauf/image/upload';
    const uploadPreset = 'flutter_profiles';

    List<String> imageUrls = [];

    for (var image in images) {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final resJson = json.decode(resStr);
        imageUrls.add(resJson['secure_url']);
      } else {
        throw Exception('Failed to upload image');
      }
    }

    return imageUrls;
  }

  Future<void> submitRecipe() async {
    if (recipeTitle.isEmpty || selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and images are required')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final uploadedImageUrls = await uploadImagesToCloudinary(selectedImages);
      final user = FirebaseAuth.instance.currentUser!;
      final recipeId = FirebaseFirestore.instance.collection('artifacts').doc().id;

      final recipe = Recipe(
        id: recipeId,
        title: recipeTitle,
        images: selectedImages,
        imageUrls: uploadedImageUrls,
        ingredients: ingredientList,
        steps: stepsList,
        tags: tagsList,
        userId: user.uid,
        userName: user.displayName ?? 'Unknown',
      );

      await FirebaseFirestore.instance
          .collection('artifacts/YOUR_APP_ID/public/recipes')
          .doc(recipeId)
          .set(recipe.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe posted successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post recipe: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Recipe')),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Recipe Title'),
              onChanged: (val) => recipeTitle = val,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Pick images logic here and add to selectedImages
              },
              child: const Text('Pick Images'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: submitRecipe,
              child: const Text('Submit Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}


 */
/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_model.dart';

class RecipePostScreen extends StatefulWidget {
  const RecipePostScreen({super.key});

  @override
  State<RecipePostScreen> createState() => _RecipePostScreenState();
}

class _RecipePostScreenState extends State<RecipePostScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = [];
  bool _isUploading = false;

  final List<String> _ingredients = [];
  final List<String> _steps = [];
  final List<String> _tags = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _stepController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  Future<void> _pickMedia() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _mediaFiles.addAll(pickedFiles.map((xFile) => File(xFile.path)).toList());
      });
    }
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty) {
      setState(() {
        _ingredients.add(ingredient);
        _ingredientController.clear();
      });
    }
  }

  void _addStep() {
    final step = _stepController.text.trim();
    if (step.isNotEmpty) {
      setState(() {
        _steps.add(step);
        _stepController.clear();
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      setState(() {
        _tags.add(tag.startsWith("#") ? tag : "#$tag");
        _tagController.clear();
      });
    }
  }

  Future<List<String>> _uploadImagesToCloudinary(List<File> images) async {
    const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/da0i4vauf/image/upload';
    const uploadPreset = 'flutter_profiles';

    List<String> imageUrls = [];

    for (var image in images) {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final resJson = json.decode(resStr);
        imageUrls.add(resJson['secure_url']);
      } else {
        throw Exception('Failed to upload image');
      }
    }
    return imageUrls;
  }

  Future<void> _postRecipe() async {
    final title = _titleController.text.trim();
    if (_mediaFiles.isEmpty || _steps.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a title, at least 1 image and steps")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final uploadedImageUrls = await _uploadImagesToCloudinary(_mediaFiles);
      final user = FirebaseAuth.instance.currentUser!;

      // ✅ Use a placeholder for the appId that you must replace
      const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';

      final recipeDocRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc();

      final newRecipe = Recipe(
        id: recipeDocRef.id,
        title: title,
        imageUrls: uploadedImageUrls,
        ingredients: List.from(_ingredients),
        steps: List.from(_steps),
        tags: List.from(_tags),
        userId: user.uid,
        userName: user.displayName ?? 'Unknown',
      );

      await recipeDocRef.set(newRecipe.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe Posted Successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post recipe: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color.fromRGBO(15, 29, 37, 1);
    final orange = const Color.fromRGBO(247, 158, 27, 1);

    if (_isUploading) {
      return Scaffold(
        backgroundColor: darkBlue,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Uploading recipe...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBlue,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Post Recipe",
                  style: GoogleFonts.robotoSlab(
                    color: Colors.white,
                    fontSize: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Recipe Title",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.title, color: Colors.black),
                  hintText: "Enter recipe title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Upload Images",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              if (_mediaFiles.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _mediaFiles.map(
                        (file) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _mediaFiles.remove(file);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).toList(),
                ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickMedia,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_a_photo,
                    size: 32,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Ingredients",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addIngredient(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.restaurant, color: Colors.black),
                        hintText: "Add ingredient",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _addIngredient,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _ingredients.map(
                      (ingredient) => Chip(
                    label: Text(
                      ingredient,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(
                      side: BorderSide(color: Colors.white),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onDeleted: () {
                      setState(() {
                        _ingredients.remove(ingredient);
                      });
                    },
                  ),
                ).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                "Steps",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _stepController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addStep(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.format_list_numbered,
                          color: Colors.black,
                        ),
                        hintText: "Add a step",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _addStep,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _steps.asMap().entries.map((entry) {
                  int index = entry.key;
                  String step = entry.value;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: orange,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      step,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _steps.removeAt(index);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                "Tags",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addTag(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.tag, color: Colors.black),
                        hintText: "Add a tag (e.g., vegan, dessert)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _addTag,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _tags.map(
                      (tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(
                      side: BorderSide(color: Colors.white),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  ),
                ).toList(),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _postRecipe,
                  child: const Text(
                    "Post",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_model.dart'; // ✅ Make sure this import path is correct

class RecipePostScreen extends StatefulWidget {
  const RecipePostScreen({super.key});

  @override
  State<RecipePostScreen> createState() => _RecipePostScreenState();
}

class _RecipePostScreenState extends State<RecipePostScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = [];
  bool _isUploading = false;

  final List<String> _ingredients = [];
  final List<String> _steps = [];
  final List<String> _tags = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _stepController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  Future<void> _pickMedia() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _mediaFiles.addAll(pickedFiles.map((xFile) => File(xFile.path)).toList());
      });
    }
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty) {
      setState(() {
        _ingredients.add(ingredient);
        _ingredientController.clear();
      });
    }
  }

  void _addStep() {
    final step = _stepController.text.trim();
    if (step.isNotEmpty) {
      setState(() {
        _steps.add(step);
        _stepController.clear();
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      setState(() {
        _tags.add(tag.startsWith("#") ? tag : "#$tag");
        _tagController.clear();
      });
    }
  }

  Future<List<String>> _uploadImagesToCloudinary(List<File> images) async {
    const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/da0i4vauf/image/upload';
    const uploadPreset = 'flutter_profiles';

    List<String> imageUrls = [];

    for (var image in images) {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final resJson = json.decode(resStr);
        imageUrls.add(resJson['secure_url']);
      } else {
        throw Exception('Failed to upload image');
      }
    }
    return imageUrls;
  }

  Future<void> _postRecipe() async {
    final title = _titleController.text.trim();
    if (_mediaFiles.isEmpty || _steps.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a title, at least 1 image and steps")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final uploadedImageUrls = await _uploadImagesToCloudinary(_mediaFiles);
      final user = FirebaseAuth.instance.currentUser!;

      // ✅ Use a placeholder for the appId that you must replace
      const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';

      final recipeDocRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc();

      final newRecipe = Recipe(
        id: recipeDocRef.id,
        title: title,
        imageUrls: uploadedImageUrls,
        ingredients: List.from(_ingredients),
        steps: List.from(_steps),
        tags: List.from(_tags),
        userId: user.uid,
        userName: user.displayName ?? 'Unknown',
      );

      // ✅ Calling .set with the toMap() method
      await recipeDocRef.set(newRecipe.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe Posted Successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post recipe: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color.fromRGBO(15, 29, 37, 1);
    final orange = const Color.fromRGBO(247, 158, 27, 1);

    if (_isUploading) {
      return Scaffold(
        backgroundColor: darkBlue,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Uploading recipe...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBlue,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Post Recipe",
                  style: GoogleFonts.robotoSlab(
                    color: Colors.white,
                    fontSize: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Recipe Title",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.title, color: Colors.black),
                  hintText: "Enter recipe title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Upload Images",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              if (_mediaFiles.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _mediaFiles.map(
                        (file) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _mediaFiles.remove(file);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).toList(),
                ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickMedia,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_a_photo,
                    size: 32,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Ingredients",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addIngredient(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.restaurant, color: Colors.black),
                        hintText: "Add ingredient",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _addIngredient,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _ingredients.map(
                      (ingredient) => Chip(
                    label: Text(
                      ingredient,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(
                      side: BorderSide(color: Colors.white),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onDeleted: () {
                      setState(() {
                        _ingredients.remove(ingredient);
                      });
                    },
                  ),
                ).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                "Steps",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _stepController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addStep(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.format_list_numbered,
                          color: Colors.black,
                        ),
                        hintText: "Add a step",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _addStep,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _steps.asMap().entries.map((entry) {
                  int index = entry.key;
                  String step = entry.value;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: orange,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      step,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _steps.removeAt(index);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                "Tags",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addTag(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.tag, color: Colors.black),
                        hintText: "Add a tag (e.g., vegan, dessert)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _addTag,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _tags.map(
                      (tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(
                      side: BorderSide(color: Colors.white),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  ),
                ).toList(),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _postRecipe,
                  child: const Text(
                    "Post",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_model.dart'; // ✅ Ensure correct import path

class RecipePostScreen extends StatefulWidget {
  const RecipePostScreen({super.key});

  @override
  State<RecipePostScreen> createState() => _RecipePostScreenState();
}

class _RecipePostScreenState extends State<RecipePostScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _mediaFiles = [];
  bool _isUploading = false;

  final List<String> _ingredients = [];
  final List<String> _steps = [];
  final List<String> _tags = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _stepController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  Future<void> _pickMedia() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _mediaFiles.addAll(pickedFiles.map((xFile) => File(xFile.path)).toList());
      });
    }
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty) {
      setState(() {
        _ingredients.add(ingredient);
        _ingredientController.clear();
      });
    }
  }

  void _addStep() {
    final step = _stepController.text.trim();
    if (step.isNotEmpty) {
      setState(() {
        _steps.add(step);
        _stepController.clear();
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      setState(() {
        _tags.add(tag.startsWith("#") ? tag : "#$tag");
        _tagController.clear();
      });
    }
  }

  Future<List<String>> _uploadImagesToCloudinary(List<File> images) async {
    const cloudinaryUrl = 'https://api.cloudinary.com/v1_1/da0i4vauf/image/upload';
    const uploadPreset = 'flutter_profiles';

    List<String> imageUrls = [];

    for (var image in images) {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final resJson = json.decode(resStr);
        imageUrls.add(resJson['secure_url']);
      } else {
        throw Exception('Failed to upload image');
      }
    }
    return imageUrls;
  }

  Future<void> _postRecipe() async {
    final title = _titleController.text.trim();
    if (_mediaFiles.isEmpty || _steps.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a title, at least 1 image and steps")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to post a recipe")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload images to Cloudinary
      final uploadedImageUrls = await _uploadImagesToCloudinary(_mediaFiles);

      if (uploadedImageUrls.isEmpty) {
        throw Exception("Failed to upload images");
      }

      // Fetch username from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final username = userDoc.data()?['username'] ?? user.displayName ?? 'Unknown';

      // Replace with your Firebase appId
      const String appId = '1:250338435801:android:ddd8de8871e9db841c54c8';

      final recipeDocRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('recipes')
          .collection('all')
          .doc();

      // Generate keywords for search
      List<String> keywords = [];
      keywords.addAll(title.toLowerCase().split(" ")); // words from title
      keywords.add(title.toLowerCase()); // full title
      keywords.addAll(_tags.map((t) => t.replaceAll("#", "").toLowerCase()));
      keywords.addAll(_ingredients.map((i) => i.toLowerCase()));
      keywords = keywords.toSet().toList(); // remove duplicates

      final newRecipe = Recipe(
        id: recipeDocRef.id,
        title: title,
        imageUrls: uploadedImageUrls,
        ingredients: List.from(_ingredients),
        steps: List.from(_steps),
        tags: List.from(_tags),
        userId: user.uid,
        userName: username,
        keywords: keywords,
      );

      await recipeDocRef.set(newRecipe.toMap());

      if (!mounted) return;
      
      // Reset loading state first
      setState(() {
        _isUploading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe Posted Successfully!")),
      );
      // Pop all pages and go to home page
      Navigator.of(context).pushNamedAndRemoveUntil('home', (route) => false);
    } catch (e) {
      debugPrint("Error posting recipe: $e");
      // Always reset loading state on error
      if (mounted) {
      setState(() {
        _isUploading = false;
      });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post recipe: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color.fromRGBO(15, 29, 37, 1);
    final orange = const Color.fromRGBO(247, 158, 27, 1);

    if (_isUploading) {
      return Scaffold(
        backgroundColor: darkBlue,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Uploading recipe...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBlue,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: 20,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: darkBlue,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Post Recipe",
                  style: GoogleFonts.robotoSlab(
                    color: Colors.white,
                    fontSize: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Recipe Title",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.title, color: Colors.black),
                  hintText: "Enter recipe title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Upload Images",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              if (_mediaFiles.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _mediaFiles.map(
                        (file) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _mediaFiles.remove(file);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).toList(),
                ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickMedia,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_a_photo,
                    size: 32,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Ingredients",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ingredientController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addIngredient(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.restaurant, color: Colors.black),
                        hintText: "Add ingredient",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _addIngredient,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _ingredients.map(
                      (ingredient) => Chip(
                    label: Text(
                      ingredient,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(
                      side: BorderSide(color: Colors.white),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onDeleted: () {
                      setState(() {
                        _ingredients.remove(ingredient);
                      });
                    },
                  ),
                ).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                "Steps",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _stepController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addStep(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.format_list_numbered,
                          color: Colors.black,
                        ),
                        hintText: "Add a step",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _addStep,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _steps.asMap().entries.map((entry) {
                  int index = entry.key;
                  String step = entry.value;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: orange,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      step,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _steps.removeAt(index);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                "Tags",
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addTag(),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.tag, color: Colors.black),
                        hintText: "Add a tag (e.g., vegan, dessert)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.white),
                    onPressed: _addTag,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _tags.map(
                      (tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.transparent,
                    shape: const StadiumBorder(
                      side: BorderSide(color: Colors.white),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  ),
                ).toList(),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _postRecipe,
                  child: const Text(
                    "Post",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
