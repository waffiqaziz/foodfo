import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:foodfo/model/nutrition_response.dart';

import '../utils/helper.dart';

class NutritionService {
  static NutritionService? _instance;
  GenerativeModel? _model;
  TemplateGenerativeModel? _templateModel;

  NutritionService._();

  static NutritionService getInstance() {
    _instance ??= NutritionService._();
    return _instance!;
  }

  GenerativeModel _getModel() {
    if (_model != null) return _model!;

    final ai = FirebaseAI.googleAI(useLimitedUseAppCheckTokens: true);

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
        thinkingConfig: ThinkingConfig.withThinkingLevel(
          ThinkingLevel.minimal,
          includeThoughts: false,
        ),
      ),
    );

    return _model!;
  }

  TemplateGenerativeModel _getTemplateModel() {
    if (_templateModel != null) return _templateModel!;

    final ai = FirebaseAI.googleAI(useLimitedUseAppCheckTokens: true);

    _templateModel = ai.templateGenerativeModel();

    return _templateModel!;
  }

  Future<NutritionInfo> fetchNutritionInfo(String foodName) async {
    final prompt = 'Nutritional information for $foodName';

    try {
      final response = await _getModel().generateContent([
        Content.text(prompt),
      ]);

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

  /// Experimental: uses a Firebase AI Logic server-side prompt template.
  ///
  /// Template ID: "nutrition-template-v1-0-0"
  /// 
  /// Docs: https://firebase.google.com/docs/ai-logic/server-prompt-templates/get-started
  ///
  /// You can use this template, copy and paste on your Prompt templates:
  /// 
  /// *Configuration (frontmatter):*
  /// ```yaml
  /// model: "gemini-3.1-flash-lite"
  /// config:
  ///   thinkingConfig:
  ///     thinkingLevel: minimal
  ///     includeThoughts: false
  /// ```
  ///
  /// *Prompt and (optional) system instructions :*
  /// ```
  /// Provide nutritional information per 100g for {{food}}.
  ///
  /// Return exactly this JSON structure:
  /// {
  ///   "calories": number,
  ///   "carbs": number,
  ///   "protein": number,
  ///   "fat": number,
  ///   "fiber": number
  /// }
  /// ```
  Future<NutritionInfo> fetchNutritionInfoFromTemplate(
    String foodName, {
    String templateId = 'nutrition-template-v1-0-0',
  }) async {
    try {
      final response = await _getTemplateModel().generateContent(
        templateId,
        inputs: {'food': foodName},
      );

      final text = response.text;
      if (text == null) {
        throw Exception('Empty response from Gemini API (template)');
      }

      final jsonData = json.decode(text);
      logger.i(jsonData);
      return NutritionInfo.fromJson(jsonData);
    } catch (e) {
      logger.e('Nutrition fetch error (template): $e');
      throw Exception(
        'Failed to fetch nutrition info from template: ${e.toString()}',
      );
    }
  }
}
