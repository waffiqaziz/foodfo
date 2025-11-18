import 'package:flutter/material.dart';
import 'package:foodfo/ui/detail/detail_page.dart';
import 'package:foodfo/utils/constant.dart';

class FoodResultsCard extends StatelessWidget {
  final Map<String, num> classifications;
  final String? imagePath;

  const FoodResultsCard({
    super.key,
    required this.classifications,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = classifications.entries.toList();
    final isNotFood = entries.isEmpty || entries[0].value < confidenceThreshold;

    return Card(
      color: colorScheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: imagePath != null && entries.isNotEmpty && isNotFood
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodDetailScreen(
                      foodName: entries[0].key,
                      imagePath: imagePath!,
                      confidence: entries[0].value.toDouble(),
                    ),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isNotFood ? Icons.warning_amber : Icons.restaurant_menu,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isNotFood
                        ? 'Recognition Result'
                        : 'Food Recognition Results',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // if not food
              if (isNotFood) ...[
                Icon(
                  Icons.no_meals,
                  size: 48,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Not Food',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'The image doesn\'t appear to contain recognizable food',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ]
              // show if food
              else ...[
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: imagePath != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodDetailScreen(
                                foodName: entries[0].key,
                                imagePath: imagePath!,
                                confidence: entries[0].value.toDouble(),
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Column(
                    children: [
                      // top prediction
                      Text(
                        _formatFoodName(entries[0].key),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(entries[0].value * 100).toStringAsFixed(1)}% confidence',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colorScheme.onPrimaryContainer.withValues(
                                alpha: 0.8,
                              ),
                            ),
                      ),

                      // other predictions
                      if (entries.length > 1) ...[
                        const SizedBox(height: 20),
                        Divider(color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          'Other possibilities:',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...entries
                            .skip(1)
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatFoodName(entry.key),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      '${(entry.value * 100).toStringAsFixed(1)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatFoodName(String name) {
    // Capitalize first letter of each word
    return name
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}
