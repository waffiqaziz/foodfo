import 'dart:convert';

import 'package:foodfo/model/meal_response.dart';
import 'package:foodfo/utils/helper.dart';
import 'package:http/http.dart' as http;

class MealService {
  final http.Client _client;

  MealService({http.Client? client}) : _client = client ?? http.Client();

  Future<MealDetail?> fetchMealDetail(String foodName) async {
    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/search.php?s=${foodName.trim()}',
    );

    try {
      final response = await _client.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to load data: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final mealResponse = MealResponse.fromJson(data);

      if (mealResponse.meals != null && mealResponse.meals!.isNotEmpty) {
        return mealResponse.meals!.first;
      }

      return null;
    } catch (e) {
      logger.e('Meal fetch error: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
