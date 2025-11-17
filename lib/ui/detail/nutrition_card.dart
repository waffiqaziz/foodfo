import 'package:flutter/material.dart';
import 'package:foodfo/model/nutrition_response.dart';
import 'package:foodfo/ui/detail/error_view.dart';

class NutritionCard extends StatelessWidget {
  final NutritionInfo? nutritionInfo;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const NutritionCard({
    super.key,
    this.nutritionInfo,
    required this.isLoading,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Analyzing nutritional content...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (error != null) {
      return ErrorView(
        message: 'Failed to load nutrition info',
        message2: error!,
        onRetry: onRetry,
      );
    }

    if (nutritionInfo == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Per 100g serving',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _NutritionItem(
              icon: Icons.local_fire_department,
              label: 'Calories',
              value: '${nutritionInfo!.calories}',
              unit: 'kcal',
              color: Colors.orange,
            ),
            const Divider(height: 24),
            _NutritionItem(
              icon: Icons.bakery_dining,
              label: 'Carbohydrates',
              value: '${nutritionInfo!.carbs}',
              unit: 'g',
              color: Colors.brown,
            ),
            const Divider(height: 24),
            _NutritionItem(
              icon: Icons.fitness_center,
              label: 'Protein',
              value: '${nutritionInfo!.protein}',
              unit: 'g',
              color: Colors.red,
            ),
            const Divider(height: 24),
            _NutritionItem(
              icon: Icons.water_drop,
              label: 'Fat',
              value: '${nutritionInfo!.fat}',
              unit: 'g',
              color: Colors.yellow.shade700,
            ),
            const Divider(height: 24),
            _NutritionItem(
              icon: Icons.grass,
              label: 'Fiber',
              value: '${nutritionInfo!.fiber}',
              unit: 'g',
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutritionItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
