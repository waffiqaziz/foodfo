import 'package:flutter/material.dart';

class ScanningState extends StatelessWidget {
  const ScanningState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Point camera at food',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Detection will appear here',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
