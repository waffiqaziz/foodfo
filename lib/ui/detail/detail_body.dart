import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodfo/model/meal_response.dart';
import 'package:foodfo/model/nutrition_response.dart';
import 'package:foodfo/ui/detail/ingredients_card.dart';
import 'package:foodfo/ui/detail/instructions_card.dart';
import 'package:foodfo/ui/detail/nutrition_card.dart';
import 'package:foodfo/ui/detail/section_header.dart';

class DetailBody extends StatelessWidget {
  final MealDetail meal;
  final String imagePath;
  final double confidence;
  final NutritionInfo? nutritionInfo;
  final bool isLoadingNutrition;
  final String? nutritionError;
  final VoidCallback onRetryNutrition;

  const DetailBody({
    super.key,
    required this.meal,
    required this.imagePath,
    required this.confidence,
    this.nutritionInfo,
    required this.isLoadingNutrition,
    this.nutritionError,
    required this.onRetryNutrition,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool isCollapsed =
                  constraints.maxHeight <= kToolbarHeight + 50;

              return FlexibleSpaceBar(
                titlePadding: isCollapsed
                    ? const EdgeInsetsDirectional.only(
                        start: 56,
                        end: 56,
                        bottom: 20,
                      )
                    : const EdgeInsetsDirectional.only(
                        start: 16,
                        end: 16,
                        bottom: 16,
                      ),
                title: Text(
                  meal.name,
                  style: TextStyle(
                    color: isCollapsed
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: isCollapsed
                        ? []
                        : [
                            const Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3.0,
                              color: Colors.black45,
                            ),
                          ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(imagePath), fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // confidence
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 18,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(confidence * 100).toStringAsFixed(1)}% Confidence',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // category meal
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (meal.category != null)
                      Chip(
                        avatar: const Icon(Icons.restaurant, size: 18),
                        label: Text(meal.category!),
                        backgroundColor: colorScheme.secondaryContainer,
                      ),
                    if (meal.area != null)
                      Chip(
                        avatar: const Icon(Icons.public, size: 18),
                        label: Text(meal.area!),
                        backgroundColor: colorScheme.tertiaryContainer,
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                SectionHeader(
                  icon: Icons.monitor_heart_outlined,
                  title: 'Nutritional Information',
                ),
                const SizedBox(height: 12),
                NutritionCard(
                  nutritionInfo: nutritionInfo,
                  isLoading: isLoadingNutrition,
                  error: nutritionError,
                  onRetry: onRetryNutrition,
                ),

                const SizedBox(height: 24),

                // ingredients
                SectionHeader(
                  icon: Icons.shopping_basket_outlined,
                  title: 'Ingredients',
                ),
                const SizedBox(height: 12),
                IngredientsCard(ingredients: meal.ingredients),

                const SizedBox(height: 24),

                // how to make
                SectionHeader(
                  icon: Icons.menu_book_outlined,
                  title: 'How to Make',
                ),
                const SizedBox(height: 12),
                InstructionsCard(instructions: meal.instructions),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
