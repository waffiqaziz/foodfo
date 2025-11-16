import 'package:flutter/foundation.dart';
import 'package:foodfo/model/meal_response.dart';
import 'package:foodfo/model/nutrition_response.dart';
import 'package:foodfo/service/meal_service.dart';
import 'package:foodfo/service/nutrition_service.dart';
import 'package:foodfo/utils/helper.dart';

class FoodDetailProvider extends ChangeNotifier {
  final MealService _mealService;
  final NutritionService _nutritionService;

  FoodDetailProvider(this._mealService, this._nutritionService);

  MealDetail? _mealDetail;
  bool _isMealLoading = false;
  String? _mealError;

  NutritionInfo? _nutritionInfo;
  bool _isNutritionLoading = false;
  String? _nutritionError;

  MealDetail? get mealDetail => _mealDetail;
  bool get isMealLoading => _isMealLoading;
  String? get mealError => _mealError;

  NutritionInfo? get nutritionInfo => _nutritionInfo;
  bool get isNutritionLoading => _isNutritionLoading;
  String? get nutritionError => _nutritionError;

  bool get hasError => _mealError != null;
  bool get isLoading => _isMealLoading || _isNutritionLoading;

  // fetch all
  Future<void> fetchFoodDetails(String foodName) async {
    await _fetchMealDetails(foodName);

    if (_mealDetail != null) {
      await _fetchNutritionInfo(foodName);
    }
  }

  Future<void> _fetchMealDetails(String foodName) async {
    _isMealLoading = true;
    _mealError = null;
    _mealDetail = null;
    notifyListeners();

    try {
      _mealDetail = await _mealService.fetchMealDetail(foodName);

      if (_mealDetail != null) {
        logger.d('Meal loaded: ${_mealDetail!.name}');
      } else {
        _mealError = 'No recipe found for "$foodName"';
      }
    } catch (e) {
      logger.e('Meal fetch error: $e');
      _mealError = 'Failed to load recipe details';
    } finally {
      _isMealLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchNutritionInfo(String foodName) async {
    _isNutritionLoading = true;
    _nutritionError = null;
    _nutritionInfo = null;
    notifyListeners();

    try {
      _nutritionInfo = await _nutritionService.fetchNutritionInfo(foodName);
      logger.d('Nutrition loaded: ${_nutritionInfo.toString()}');
    } catch (e) {
      logger.e('Nutrition fetch error: $e');
      _nutritionError = 'Failed to load nutrition info';
    } finally {
      _isNutritionLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryNutritionInfo(String foodName) async {
    await _fetchNutritionInfo(foodName);
  }

  Future<void> retryMealDetails(String foodName) async {
    await fetchFoodDetails(foodName);
  }

  void clearErrors() {
    _mealError = null;
    _nutritionError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mealService.dispose();
    super.dispose();
  }
}
