import 'package:flutter/material.dart';
import 'package:foodfo/ui/real_time_camera/confidence_bar_view.dart';
import 'package:foodfo/ui/real_time_camera/result_chip.dart';
import 'package:foodfo/utils/constant.dart';

class ClassificationResults extends StatelessWidget {
  final Map<String, num> classifications;

  const ClassificationResults({super.key, required this.classifications});

  @override
  Widget build(BuildContext context) {
    final entries = classifications.entries.toList();
    final isNotFood = entries[0].value < confidenceThreshold;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ResultChip(isNotFood: isNotFood),
            const Spacer(),
            !isNotFood
                ? Icon(
                    Icons.restaurant,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.7),
                  )
                : SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 16),

        // if food not detected
        if (isNotFood) ...[
          Center(
            child: Column(
              children: [
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
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ]
        // if food detected
        else ...[
          Text(
            _formatFoodName(entries[0].key),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ConfidenceBar(confidence: entries[0].value.toDouble()),
              ),
              const SizedBox(width: 12),
              Text(
                '${(entries[0].value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],

        // Other predictions
        if (entries.length > 1 && !isNotFood) ...[
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 12),
          ...entries
              .skip(1)
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatFoodName(entry.key),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${(entry.value * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ],
    );
  }

  String _formatFoodName(String name) {
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
