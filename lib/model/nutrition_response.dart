class NutritionInfo {
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double fiber;

  NutritionInfo({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: _toDouble(json['calories']),
      carbs: _toDouble(json['carbs']),
      protein: _toDouble(json['protein']),
      fat: _toDouble(json['fat']),
      fiber: _toDouble(json['fiber']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() {
    return 'NutritionInfo(calories: $calories, carbs: $carbs, protein: $protein, fat: $fat, fiber: $fiber)';
  }
}
