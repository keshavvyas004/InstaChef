import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AiRecipeGeneratorPage extends StatefulWidget {
  const AiRecipeGeneratorPage({Key? key}) : super(key: key);

  @override
  State<AiRecipeGeneratorPage> createState() => _AiRecipeGeneratorPageState();
}

class _AiRecipeGeneratorPageState extends State<AiRecipeGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  String _recipe = "";
  File? _imageFile;

  final FlutterTts _flutterTts = FlutterTts();

  bool   _isSpeaking  = false;
  bool   _isPaused    = false;
  double _speechRate  = 0.45;

  String? _selectedCuisine;

  final List<String> _filters = [
    "Veg", "Non-Veg", "Vegan", "Gluten-Free",
    "Keto", "Low-Carb", "High-Protein", "Dairy-Free",
  ];
  final Set<String> _selectedFilters = {};

  final Color accentColor     = const Color.fromRGBO(247, 158, 27, 1);
  final Color cardColor       = const Color.fromRGBO(20, 40, 50, 1);
  final Color backgroundColor = const Color.fromRGBO(15, 29, 37, 1);

  // ── Image picker ──────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _controller.text = "Tomato, Onion, Garlic";
      });
      Navigator.pop(context);
    }
  }

  // ── TTS helpers ───────────────────────────────────────────────────────────
  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setVoice({"name": "en-in-x-end#male_1", "locale": "en-IN"});
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() { _isSpeaking = true; _isPaused = false; });
    });
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() { _isSpeaking = false; _isPaused = false; });
    });
    _flutterTts.setCancelHandler(() {
      if (mounted) setState(() { _isSpeaking = false; _isPaused = false; });
    });
    _flutterTts.setPauseHandler(() {
      if (mounted) setState(() => _isPaused = true);
    });
    _flutterTts.setContinueHandler(() {
      if (mounted) setState(() => _isPaused = false);
    });
  }

  Future<void> _startListening() async {
    if (_recipe.isEmpty) return;
    await _initTts();
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.stop();
    final narration = """
Hello! Welcome to InstaChef Kitchen.
Today, I will guide you through this recipe.
Let us begin with the ingredients.
$_recipe
Take it slow, enjoy cooking, and trust the process. Great food always comes from patience.
""";
    await _flutterTts.speak(narration);
  }

  Future<void> _pauseResume() async {
    if (_isPaused) {
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.speak(_recipe);
      setState(() => _isPaused = false);
    } else {
      final result = await _flutterTts.pause();
      if (result == 1) setState(() => _isPaused = true);
    }
  }

  Future<void> _stopTts() async {
    await _flutterTts.stop();
    setState(() { _isSpeaking = false; _isPaused = false; });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  // ── Demo generate (no API key needed) ─────────────────────────────────────
  Future<void> _generateRecipe() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter at least one ingredient."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() { _loading = true; _recipe = ""; });

    // Simulate a short network delay for realism
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _loading = false;
      _recipe = "";
    });

    // Show demo dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: const Color.fromRGBO(20, 40, 50, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(247, 158, 27, 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromRGBO(247, 158, 27, 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color.fromRGBO(247, 158, 27, 1),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                "Demo Mode",
                style: GoogleFonts.robotoSlab(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                "This is a Demo App.\nRecipe Generation is Prohibited.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "To enable AI recipe generation, configure your Gemini API key in the app settings.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(247, 158, 27, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Got it",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Copy & Share ──────────────────────────────────────────────────────────
  void _copyRecipe() {
    Clipboard.setData(ClipboardData(text: _recipe));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Recipe copied to clipboard!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareRecipe() {
    Share.share(_recipe, subject: "Check out this recipe from InstaChef!");
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                // Title
                Text(
                  "AI Recipe Generator",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoSlab(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Demo badge
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(247, 158, 27, 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color.fromRGBO(247, 158, 27, 0.4),
                    ),
                  ),
                  child: const Text(
                    "DEMO MODE",
                    style: TextStyle(
                      color: Color.fromRGBO(247, 158, 27, 1),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Ingredient input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.black),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: "Enter ingredients (comma separated)",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add_a_photo, color: accentColor),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: cardColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) => Container(
                              padding: const EdgeInsets.all(20),
                              child: Wrap(
                                spacing: 20,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.camera_alt, color: accentColor),
                                    title: const Text("Take Photo", style: TextStyle(color: Colors.white)),
                                    onTap: () => _pickImage(ImageSource.camera),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.photo, color: accentColor),
                                    title: const Text("Choose from Gallery", style: TextStyle(color: Colors.white)),
                                    onTap: () => _pickImage(ImageSource.gallery),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Selected image preview
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
                    ),
                  ),

                // Filter chips
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _filters.map((filter) {
                    final selected = _selectedFilters.contains(filter);
                    return FilterChip(
                      label: Text(filter, style: const TextStyle(color: Colors.white)),
                      selected: selected,
                      backgroundColor: Colors.grey[700],
                      selectedColor: accentColor,
                      checkmarkColor: Colors.white,
                      onSelected: (v) => setState(() =>
                          v ? _selectedFilters.add(filter) : _selectedFilters.remove(filter)),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Cuisine dropdown
                DropdownButtonFormField<String>(
                  dropdownColor: cardColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  hint: const Text("Select Cuisine", style: TextStyle(color: Colors.white70)),
                  value: _selectedCuisine,
                  items: ["Indian", "Italian", "Chinese", "Mexican", "Japanese", "Mediterranean", "American"]
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCuisine = v),
                ),

                const SizedBox(height: 25),

                // Generate button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(220, 55),
                  ),
                  onPressed: _loading ? null : _generateRecipe,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Generate Recipe",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                ),

                const SizedBox(height: 30),

                // Recipe output (only shows if _recipe is non-empty)
                if (_recipe.isNotEmpty) ...[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      _recipe,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.copy, color: Colors.white),
                    label: const Text("Copy Recipe", style: TextStyle(fontSize: 18, color: Colors.white)),
                    onPressed: _copyRecipe,
                  ),
                  const SizedBox(height: 14),

                  // TTS player card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withOpacity(0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.headphones_rounded, color: accentColor, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Listen to Recipe",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: accentColor.withOpacity(0.4)),
                              ),
                              child: Text(
                                "${_speechRate.toStringAsFixed(2)}x",
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.slow_motion_video_rounded, color: Colors.white54, size: 18),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: accentColor,
                                  inactiveTrackColor: accentColor.withOpacity(0.2),
                                  thumbColor: accentColor,
                                  overlayColor: accentColor.withOpacity(0.15),
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                ),
                                child: Slider(
                                  value: _speechRate,
                                  min: 0.3,
                                  max: 1.0,
                                  divisions: 7,
                                  onChanged: (v) async {
                                    setState(() => _speechRate = v);
                                    if (_isSpeaking && !_isPaused) {
                                      await _flutterTts.setSpeechRate(v);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const Icon(Icons.fast_forward_rounded, color: Colors.white54, size: 18),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: Icon(
                                  _isSpeaking && !_isPaused
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _isSpeaking && !_isPaused
                                      ? "Pause"
                                      : (_isPaused ? "Resume" : "Play"),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                onPressed: () {
                                  if (!_isSpeaking) {
                                    _startListening();
                                  } else {
                                    _pauseResume();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                              ),
                              onPressed: _isSpeaking || _isPaused ? _stopTts : null,
                              child: const Icon(Icons.stop_rounded, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      minimumSize: const Size(300, 50),
                    ),
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text("Share Recipe", style: TextStyle(fontSize: 18, color: Colors.white)),
                    onPressed: _shareRecipe,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
