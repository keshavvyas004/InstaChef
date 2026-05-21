import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

Future<void> main() async {
  const apiKey = 'AIzaSyBXKl08TS4_MgVyUXDhkTrhszOEofosuq4';
  
  print('Testing Recipe Generation with Gemini...');

  final prompt = """
You are a professional chef. Create a simple recipe using these ingredients: chicken, garlic, lemon.
Format your output exactly like this:

Title:
[Recipe Name]

Ingredients:
[List ingredients]

Steps:
[List steps]
""";

  try {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    print('\n✅ RECIPE GENERATED SUCESSFULLY:\n');
    print(response.text);
  } catch (e) {
    print('\n❌ FAILED TO GENERATE RECIPE:\n');
    print('Error: $e');
  }
}
