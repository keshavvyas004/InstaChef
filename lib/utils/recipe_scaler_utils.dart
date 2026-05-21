// lib/utils/recipe_scaler_utils.dart

/// Represents a parsed ingredient with extractable amount and unit
class ParsedIngredient {
  final double? amount;
  final String? unit;
  final String name;
  final String originalText;
  final bool isScalable;

  ParsedIngredient({
    this.amount,
    this.unit,
    required this.name,
    required this.originalText,
    this.isScalable = true,
  });
}

/// Utility class for parsing and scaling recipe ingredients
class IngredientParser {
  // Common units for matching
  static final Set<String> volumeUnits = {
    'cup', 'cups', 'c',
    'tablespoon', 'tablespoons', 'tbsp', 'tbs', 'T',
    'teaspoon', 'teaspoons', 'tsp', 'ts', 't',
    'milliliter', 'milliliters', 'ml', 'mL',
    'liter', 'liters', 'l', 'L',
    'fluid ounce', 'fluid ounces', 'fl oz', 'fl. oz.',
    'pint', 'pints', 'pt',
    'quart', 'quarts', 'qt',
    'gallon', 'gallons', 'gal',
  };

  static final Set<String> weightUnits = {
    'gram', 'grams', 'g',
    'kilogram', 'kilograms', 'kg',
    'ounce', 'ounces', 'oz',
    'pound', 'pounds', 'lb', 'lbs',
  };

  static final Set<String> nonScalablePhases = {
    'to taste',
    'as needed',
    'pinch',
    'pinch of',
    'dash',
    'dash of',
    'optional',
  };

  /// Parse an ingredient string to extract amount, unit, and name
  static ParsedIngredient parse(String ingredientText) {
    final trimmed = ingredientText.trim();

    // Check if non-scalable
    final lowerText = trimmed.toLowerCase();
    for (var phrase in nonScalablePhases) {
      if (lowerText.contains(phrase)) {
        return ParsedIngredient(
          originalText: trimmed,
          name: trimmed,
          isScalable: false,
        );
      }
    }

    // Regex patterns for parsing
    // Pattern 1: "2 cups flour" or "1/2 cup sugar"
    // Pattern 2: "2-3 eggs"
    // Pattern 3: "3 large eggs" (count with descriptor)
    
    final fractionPattern = RegExp(r'^(\d+)\s*/\s*(\d+)');
    final decimalPattern = RegExp(r'^(\d+\.?\d*)');
    final rangePattern = RegExp(r'^(\d+)\s*-\s*(\d+)');

    String remaining = trimmed;
    double? parsedAmount;

    // Try to parse fraction first
    var match = fractionPattern.firstMatch(remaining);
    if (match != null) {
      final numerator = double.parse(match.group(1)!);
      final denominator = double.parse(match.group(2)!);
      parsedAmount = numerator / denominator;
      remaining = remaining.substring(match.end).trim();
    } else {
      // Try decimal/whole number
      match = decimalPattern.firstMatch(remaining);
      if (match != null) {
        parsedAmount = double.parse(match.group(1)!);
        remaining = remaining.substring(match.end).trim();
        
        // Check for following fraction (e.g., "1 1/2")
        final followingFraction = fractionPattern.firstMatch(remaining);
        if (followingFraction != null) {
          final numerator = double.parse(followingFraction.group(1)!);
          final denominator = double.parse(followingFraction.group(2)!);
          parsedAmount = parsedAmount + (numerator / denominator);
          remaining = remaining.substring(followingFraction.end).trim();
        }
      } else {
        // Try range pattern
        match = rangePattern.firstMatch(remaining);
        if (match != null) {
          final min = double.parse(match.group(1)!);
          final max = double.parse(match.group(2)!);
          parsedAmount = (min + max) / 2; // Use average
          remaining = remaining.substring(match.end).trim();
        }
      }
    }

    // Try to find unit
    String? parsedUnit;
    final words = remaining.split(RegExp(r'\s+'));
    if (words.isNotEmpty) {
      final firstWord = words[0].toLowerCase().replaceAll(RegExp(r'[,.]$'), '');
      
      if (volumeUnits.contains(firstWord) || weightUnits.contains(firstWord)) {
        parsedUnit = words[0];
        remaining = words.skip(1).join(' ');
      }
    }

    return ParsedIngredient(
      amount: parsedAmount,
      unit: parsedUnit,
      name: remaining.isNotEmpty ? remaining : trimmed,
      originalText: trimmed,
      isScalable: parsedAmount != null,
    );
  }

  /// Format a number as a fraction string when appropriate
  static String formatAmount(double amount) {
    // Common cooking fractions
    final fractions = {
      0.125: '⅛',
      0.25: '¼',
      0.333: '⅓',
      0.375: '⅜',
      0.5: '½',
      0.625: '⅝',
      0.666: '⅔',
      0.75: '¾',
      0.875: '⅞',
    };

    final whole = amount.floor();
    final decimal = amount - whole;

    // Find closest fraction
    String? fractionStr;
    if (decimal > 0.01) {
      double closestDiff = double.infinity;
      for (var entry in fractions.entries) {
        final diff = (entry.key - decimal).abs();
        if (diff < closestDiff && diff < 0.05) {
          closestDiff = diff;
          fractionStr = entry.value;
        }
      }
    }

    if (fractionStr != null) {
      return whole > 0 ? '$whole$fractionStr' : fractionStr;
    } else if (decimal < 0.01) {
      return whole.toString();
    } else {
      // Round to 1 decimal place
      return amount.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    }
  }

  /// Scale ingredient text by a multiplier
  static String scaleIngredient(String ingredientText, double multiplier) {
    final parsed = parse(ingredientText);
    
    if (!parsed.isScalable || parsed.amount == null) {
      return ingredientText; // Return original if not scalable
    }

    final scaledAmount = parsed.amount! * multiplier;
    final formattedAmount = formatAmount(scaledAmount);

    if (parsed.unit != null) {
      return '$formattedAmount ${parsed.unit} ${parsed.name}';
    } else {
      return '$formattedAmount ${parsed.name}';
    }
  }
}

/// Utility class for scaling entire recipes
class RecipeScaler {
  /// Scale all ingredients in a recipe
  static List<String> scaleIngredients(
    List<String> ingredients,
    int fromServings,
    int toServings,
  ) {
    if (fromServings == toServings) return ingredients;
    
    final multiplier = toServings / fromServings;
    return ingredients
        .map((ingredient) => IngredientParser.scaleIngredient(ingredient, multiplier))
        .toList();
  }
}
