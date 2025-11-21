import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodfo/controller/detail_provider.dart';
import 'package:foodfo/ui/detail/ingredients_card.dart';
import 'package:foodfo/ui/detail/instructions_card.dart';
import 'package:foodfo/ui/detail/meal_picture_card.dart';
import 'package:foodfo/ui/detail/no_meal_data_card.dart';
import 'package:foodfo/ui/detail/nutrition_card.dart';
import 'package:foodfo/ui/detail/section_header.dart';
import 'package:provider/provider.dart';

class DetailBody extends StatefulWidget {
  final String foodName;
  final String imagePath;
  final double confidence;

  const DetailBody({
    super.key,
    required this.foodName,
    required this.imagePath,
    required this.confidence,
  });

  @override
  State<DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<DetailBody> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<FoodDetailProvider>(
      builder: (context, provider, child) {
        final isMealNull = provider.mealDetail == null;

        return CustomScrollView(
          slivers: [
            SliverAppBar.large(
              expandedHeight: 300,
              pinned: true,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              flexibleSpace: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool isCollapsed =
                      constraints.maxHeight <= kToolbarHeight + 75;

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
                      widget.foodName,
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
                        Image.file(File(widget.imagePath), fit: BoxFit.cover),
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
                              '${(widget.confidence * 100).toStringAsFixed(1)}% Confidence',
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

                    if (!isMealNull &&
                        provider.mealDetail!.thumbnail != null &&
                        provider.mealDetail!.thumbnail!.isNotEmpty) ...[
                      SectionHeader(
                        icon: Icons.photo_library_outlined,
                        title: 'Others Picture',
                      ),
                      const SizedBox(height: 12),
                      MealPictureCard(imageUrl: provider.mealDetail?.thumbnail),
                      const SizedBox(height: 24),
                    ],

                    // category meal
                    if (!isMealNull)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (provider.mealDetail!.category != null)
                            Chip(
                              avatar: const Icon(Icons.restaurant, size: 18),
                              label: Text(provider.mealDetail!.category!),
                              backgroundColor: colorScheme.secondaryContainer,
                            ),
                          if (provider.mealDetail!.area != null)
                            Chip(
                              avatar: const Icon(Icons.public, size: 18),
                              label: Text(provider.mealDetail!.area!),
                              backgroundColor: colorScheme.tertiaryContainer,
                            ),
                        ],
                      ),
                    if (!isMealNull) const SizedBox(height: 24),

                    SectionHeader(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Nutritional Information',
                    ),
                    const SizedBox(height: 12),
                    NutritionCard(
                      nutritionInfo: provider.nutritionInfo,
                      isLoading: provider.isNutritionLoading,
                      error: provider.nutritionError,
                      onRetry: () =>
                          provider.retryNutritionInfo(widget.foodName),
                    ),

                    const SizedBox(height: 24),

                    // ingredients
                    SectionHeader(
                      icon: Icons.shopping_basket_outlined,
                      title: 'Ingredients',
                    ),
                    const SizedBox(height: 12),
                    isMealNull
                        ? NoDataCard(message: 'No ingredients data found')
                        : IngredientsCard(
                            ingredients: provider.mealDetail!.ingredients,
                          ),

                    const SizedBox(height: 24),

                    // how to make
                    SectionHeader(
                      icon: Icons.menu_book_outlined,
                      title: 'How to Make',
                    ),
                    const SizedBox(height: 12),
                    isMealNull
                        ? NoDataCard(message: 'No recipe instructions found')
                        : InstructionsCard(
                            instructions: provider.mealDetail!.instructions,
                          ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
