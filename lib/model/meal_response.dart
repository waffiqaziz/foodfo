class MealDetail {
  final String id;
  final String name;
  final String? category;
  final String? area;
  final String instructions;
  final String? thumbnail;
  final List<Ingredient> ingredients;

  MealDetail({
    required this.id,
    required this.name,
    this.category,
    this.area,
    required this.instructions,
    this.thumbnail,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null &&
          ingredient.toString().trim().isNotEmpty &&
          ingredient != 'null') {
        ingredients.add(
          Ingredient(
            name: ingredient.toString().trim(),
            measure: measure?.toString().trim() ?? '',
          ),
        );
      }
    }

    return MealDetail(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'] ?? '',
      thumbnail: json['strMealThumb'],
      ingredients: ingredients,
    );
  }
}

class Ingredient {
  final String name;
  final String measure;

  Ingredient({required this.name, required this.measure});
}

class MealResponse {
  final List<MealDetail>? meals;

  MealResponse({this.meals});

  factory MealResponse.fromJson(Map<String, dynamic> json) {
    return MealResponse(
      meals: json['meals'] != null
          ? (json['meals'] as List)
                .map((meal) => MealDetail.fromJson(meal))
                .toList()
          : null,
    );
  }
}
