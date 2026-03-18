import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  final Color color;
  final double radius;

  const CustomTabIndicator({
    this.color = Colors.blue,
    this.radius = 8,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(color: color, radius: radius);
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final Color color;
  final double radius;

  _CustomTabIndicatorPainter({
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()..color = color;
    final Rect rect = Offset(
      offset.dx,
      configuration.size!.height - 3,
    ) & Size(configuration.size!.width, 3);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }
}