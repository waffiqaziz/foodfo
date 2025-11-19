import 'package:flutter/widgets.dart';

class RoundedCornerBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerSize; // length of each visible edge segment
  final double cornerRadius; // radius of the rounded arc at the corner

  RoundedCornerBorderPainter({
    required this.color,
    this.strokeWidth = 4.0,
    this.cornerSize = 20.0,
    this.cornerRadius = 12.0,
  }) : assert(
         cornerRadius <= cornerSize,
         'cornerRadius should be <= cornerSize to avoid overlap',
       );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // ----- TOP LEFT CORNER -----
    // Horizontal line (top)
    path.moveTo(cornerRadius, 0);
    path.lineTo(cornerSize, 0);

    // Arc (top-left corner)
    path.moveTo(cornerRadius, 0);
    path.arcToPoint(
      Offset(0, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );

    // Vertical line (left)
    path.moveTo(0, cornerRadius);
    path.lineTo(0, cornerSize);

    // ----- TOP RIGHT CORNER -----
    // Horizontal line (top) - draw from right to left
    path.moveTo(size.width - cornerSize, 0);
    path.lineTo(size.width - cornerRadius, 0);

    // Arc (top-right corner) - clockwise this time
    path.moveTo(size.width - cornerRadius, 0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true, // Changed to clockwise
    );

    // Vertical line (right)
    path.moveTo(size.width, cornerRadius);
    path.lineTo(size.width, cornerSize);

    // ----- BOTTOM RIGHT CORNER -----
    // Vertical line (right) - draw from bottom to top
    path.moveTo(size.width, size.height - cornerSize);
    path.lineTo(size.width, size.height - cornerRadius);

    // Arc (bottom-right corner) - clockwise
    path.moveTo(size.width, size.height - cornerRadius);
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
      clockwise: true, // Changed to clockwise
    );

    // Horizontal line (bottom) - draw from right to left
    path.moveTo(size.width - cornerSize, size.height);
    path.lineTo(size.width - cornerRadius, size.height);

    // ----- BOTTOM LEFT CORNER -----
    // Vertical line (left) - draw from bottom to top
    path.moveTo(0, size.height - cornerSize);
    path.lineTo(0, size.height - cornerRadius);

    // Arc (bottom-left corner)
    path.moveTo(0, size.height - cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, size.height),
      radius: Radius.circular(cornerRadius),
      clockwise: false,
    );

    // Horizontal line (bottom)
    path.moveTo(cornerRadius, size.height);
    path.lineTo(cornerSize, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RoundedCornerBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerSize != cornerSize ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
