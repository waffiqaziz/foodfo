import 'package:flutter/material.dart';

class ConfidenceBar extends StatelessWidget {
  final double confidence;

  const ConfidenceBar({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = confidence * 100;
    Color barColor;

    if (percentage >= 70) {
      barColor = Colors.green;
    } else if (percentage >= 40) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: confidence.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [barColor.withValues(alpha: 0.7), barColor],
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: barColor.withValues(alpha: 0.4), blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}
