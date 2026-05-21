// lib/utils/unit_converter.dart

/// Utility class for converting between metric and imperial units
class UnitConverter {
  // Conversion factors to metric (base units: ml for volume, g for weight)
  static const Map<String, double> _toMetric = {
    // Volume conversions to ml
    'cup': 236.588,
    'cups': 236.588,
    'c': 236.588,
    'tablespoon': 14.787,
    'tablespoons': 14.787,
    'tbsp': 14.787,
    'tbs': 14.787,
    'T': 14.787,
    'teaspoon': 4.929,
    'teaspoons': 4.929,
    'tsp': 4.929,
    'ts': 4.929,
    't': 4.929,
    'fluid ounce': 29.574,
    'fluid ounces': 29.574,
    'fl oz': 29.574,
    'fl. oz.': 29.574,
    'pint': 473.176,
    'pints': 473.176,
    'pt': 473.176,
    'quart': 946.353,
    'quarts': 946.353,
    'qt': 946.353,
    'gallon': 3785.41,
    'gallons': 3785.41,
    'gal': 3785.41,
    'liter': 1000.0,
    'liters': 1000.0,
    'l': 1000.0,
    'L': 1000.0,
    'milliliter': 1.0,
    'milliliters': 1.0,
    'ml': 1.0,
    'mL': 1.0,
    
    // Weight conversions to grams
    'ounce': 28.35,
    'ounces': 28.35,
    'oz': 28.35,
    'pound': 453.592,
    'pounds': 453.592,
    'lb': 453.592,
    'lbs': 453.592,
    'kilogram': 1000.0,
    'kilograms': 1000.0,
    'kg': 1000.0,
    'gram': 1.0,
    'grams': 1.0,
    'g': 1.0,
  };

  // Imperial units (for recognition)
  static const Set<String> _imperialUnits = {
    'cup', 'cups', 'c',
    'tablespoon', 'tablespoons', 'tbsp', 'tbs', 'T',
    'teaspoon', 'teaspoons', 'tsp', 'ts', 't',
    'fluid ounce', 'fluid ounces', 'fl oz', 'fl. oz.',
    'pint', 'pints', 'pt',
    'quart', 'quarts', 'qt',
    'gallon', 'gallons', 'gal',
    'ounce', 'ounces', 'oz',
    'pound', 'pounds', 'lb', 'lbs',
  };

  // Metric units (for recognition)
  static const Set<String> _metricUnits = {
    'milliliter', 'milliliters', 'ml', 'mL',
    'liter', 'liters', 'l', 'L',
    'gram', 'grams', 'g',
    'kilogram', 'kilograms', 'kg',
  };

  /// Check if a unit is imperial
  static bool isImperial(String? unit) {
    if (unit == null) return false;
    return _imperialUnits.contains(unit.toLowerCase());
  }

  /// Check if a unit is metric
  static bool isMetric(String? unit) {
    if (unit == null) return false;
    return _metricUnits.contains(unit.toLowerCase());
  }

  /// Convert amount from one unit to metric
  static (double amount, String unit)? convertToMetric(double amount, String unit) {
    final lowerUnit = unit.toLowerCase();
    
    if (!_toMetric.containsKey(lowerUnit)) {
      return null; // Unknown unit
    }

    if (isMetric(unit)) {
      return (amount, unit); // Already metric
    }

    final mlOrG = amount * _toMetric[lowerUnit]!;

    // Determine if volume or weight
    final isVolume = ['cup', 'cups', 'c', 'tablespoon', 'tablespoons', 'tbsp', 'tbs', 'T',
                      'teaspoon', 'teaspoons', 'tsp', 'ts', 't', 'fluid ounce', 'fluid ounces', 
                      'fl oz', 'fl. oz.', 'pint', 'pints', 'pt', 'quart', 'quarts', 'qt',
                      'gallon', 'gallons', 'gal'].contains(lowerUnit);

    if (isVolume) {
      // Convert to ml or liters
      if (mlOrG >= 1000) {
        return (mlOrG / 1000, 'L');
      } else {
        return (mlOrG, 'ml');
      }
    } else {
      // Convert to grams or kg
      if (mlOrG >= 1000) {
        return (mlOrG / 1000, 'kg');
      } else {
        return (mlOrG, 'g');
      }
    }
  }

  /// Convert amount from metric to imperial
  static (double amount, String unit)? convertToImperial(double amount, String unit) {
    final lowerUnit = unit.toLowerCase();
    
    if (!_toMetric.containsKey(lowerUnit)) {
      return null; // Unknown unit
    }

    if (isImperial(unit)) {
      return (amount, unit); // Already imperial
    }

    // Convert metric to ml/g first
    double mlOrG = amount * _toMetric[lowerUnit]!;

    // Determine if volume or weight
    final isVolume = ['ml', 'mL', 'milliliter', 'milliliters', 'l', 'L', 'liter', 'liters']
        .contains(lowerUnit);

    if (isVolume) {
      // Prefer cups for larger volumes
      if (mlOrG >= 236.588) {
        return (mlOrG / 236.588, 'cups');
      } else if (mlOrG >= 14.787) {
        return (mlOrG / 14.787, 'tbsp');
      } else {
        return (mlOrG / 4.929, 'tsp');
      }
    } else {
      // Weight: prefer oz or lb
      if (mlOrG >= 453.592) {
        return (mlOrG / 453.592, 'lb');
      } else {
        return (mlOrG / 28.35, 'oz');
      }
    }
  }

  /// Format the converted unit for display
  static String formatConversion(double amount, String unit, {int decimals = 1}) {
    // Round to specified decimals
    var rounded = double.parse(amount.toStringAsFixed(decimals));
    
    // Remove trailing zeros
    String formatted = rounded.toString().replaceAll(RegExp(r'\.0+$'), '');
    
    return '$formatted $unit';
  }

  /// Convert ingredient text between metric and imperial
  static String? convertIngredientText(
    String ingredientText,
    bool toMetric,
    double amount,
    String? unit,
    String name,
  ) {
    if (unit == null) return null;

    final conversion = toMetric 
        ? convertToMetric(amount, unit)
        : convertToImperial(amount, unit);

    if (conversion == null) return null;

    final (convertedAmount, convertedUnit) = conversion;
    final formatted = formatConversion(convertedAmount, convertedUnit);
    
    return '$formatted $name';
  }
}
