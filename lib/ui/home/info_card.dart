import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: colorScheme.onSecondaryContainer,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Take or select a photo of food to identify it using Machine Learning',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
