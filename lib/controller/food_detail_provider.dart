import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foodfo/model/meal_response.dart';
import 'package:foodfo/utils/helper.dart';
import 'package:http/http.dart' as http;

class FoodDetailProvider extends ChangeNotifier {
  MealDetail? _mealDetail;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  MealDetail? get mealDetail => _mealDetail;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFoodDetails(String foodName) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/search.php?s=${foodName.trim()}',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to load data: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final mealResponse = MealResponse.fromJson(data);

      if (mealResponse.meals != null && mealResponse.meals!.isNotEmpty) {
        _mealDetail = mealResponse.meals!.first;
        logger.d('Response: ${_mealDetail!.name}');
      } else {
        // Try first letter search as fallback
        logger.e('Empty response');
      }
    } catch (e) {
      logger.e('Error: $e');
      _hasError = true;
      _errorMessage = 'Failed to load recipe details';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }
}
