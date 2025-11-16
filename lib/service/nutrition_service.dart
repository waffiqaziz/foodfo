import 'dart:convert';

import 'package:foodfo/env/env.dart';
import 'package:foodfo/model/nutrition_response.dart';
import 'package:foodfo/utils/helper.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class NutritionService {
  final GenerativeModel _model;

  NutritionService()
    : _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: Env.geminiApiKey,
        systemInstruction: Content.system(
          'I am a machine capable of identifying the nutrients or nutritional content of food, '
          'just like a food laboratory test. The items I can identify are calories, carbohydrates, '
          'fat, fiber, and protein. The units of these indicators are grams. '
          'Always respond with valid JSON only, no markdown formatting.',
        ),
      );

  Future<NutritionInfo> fetchNutritionInfo(String foodName) async {
    final prompt =
        'Provide nutritional information for $foodName per 100g serving. '
        'Return JSON with these exact keys: calories, carbs, protein, fat, fiber';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null) {
        throw Exception('Empty response from Gemini API');
      }

      // Clean and parse the response
      final jsonText = _cleanJsonResponse(response.text!);
      final jsonData = json.decode(jsonText);

      return NutritionInfo.fromJson(jsonData);
    } catch (e) {
      logger.e('Nutrition fetch error: $e');
      throw Exception('Failed to fetch nutrition info: ${e.toString()}');
    }
  }

  String _cleanJsonResponse(String text) {
    return text.trim().replaceAll('```json', '').replaceAll('```', '').trim();
  }
}
