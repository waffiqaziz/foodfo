import 'package:flutter/material.dart';

class PausedState extends StatelessWidget {
  const PausedState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.pause_circle_outline,
          size: 48,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 12),
        Text(
          'Detection Paused',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap play to resume',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
