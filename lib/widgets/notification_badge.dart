import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? color;
  final double size;

  const NotificationBadge({
    super.key,
    required this.count,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(2),
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      decoration: BoxDecoration(
        color: color ?? Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}