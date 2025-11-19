import 'package:flutter/material.dart';

class ResultChip extends StatelessWidget {
  const ResultChip({super.key, required this.isNotFood});

  final bool isNotFood;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: !isNotFood
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.red.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: !isNotFood
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isNotFood) ...[
            Icon(Icons.cancel, size: 16, color: Colors.red.shade300),
            const SizedBox(width: 6),
            Text(
              'Not Detected',
              style: TextStyle(
                color: Colors.red.shade200,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            Icon(Icons.check_circle, size: 16, color: Colors.green.shade300),
            const SizedBox(width: 6),
            Text(
              'Detected',
              style: TextStyle(
                color: Colors.green.shade200,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
