import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:foodfo/model/nutrition_response.dart';

import '../utils/helper.dart';

class NutritionService {
  static NutritionService? _instance;
  GenerativeModel? _model;

  NutritionService._();

  static NutritionService getInstance() {
    _instance ??= NutritionService._();
    return _instance!;
  }

  GenerativeModel _getModel() {
    if (_model != null) return _model!;

    final ai = FirebaseAI.googleAI(
      appCheck: FirebaseAppCheck.instance,
      useLimitedUseAppCheckTokens: true,
    );

    _model = ai.generativeModel(
      model: 'gemini-3.1-flash-lite',
      systemInstruction: Content.system(
        'Provide nutritional information per 100g serving. Values in grams.',
      ),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema(
          SchemaType.object,
          properties: {
            'calories': Schema(
              SchemaType.number,
              description: 'Calories per 100g',
              nullable: false,
            ),
            'carbs': Schema(
              SchemaType.number,
              description: 'Carbohydrates in grams',
              nullable: false,
            ),
            'protein': Schema(
              SchemaType.number,
              description: 'Protein in grams',
              nullable: false,
            ),
            'fat': Schema(
              SchemaType.number,
              description: 'Fat in grams',
              nullable: false,
            ),
            'fiber': Schema(
              SchemaType.number,
              description: 'Fiber in grams',
              nullable: false,
            ),
          },
        ),
      ),
    );

    return _model!;
  }

  Future<NutritionInfo> fetchNutritionInfo(String foodName) async {
    final prompt = 'Nutritional information for $foodName';

    try {
      final response = await _getModel().generateContent([Content.text(prompt)]);

      if (response.text == null) {
        throw Exception('Empty response from Gemini API');
      }

      final jsonData = json.decode(response.text!);
      logger.i(jsonData);
      return NutritionInfo.fromJson(jsonData);
    } catch (e) {
      logger.e('Nutrition fetch error: $e');
      throw Exception('Failed to fetch nutrition info: ${e.toString()}');
    }
  }
}
