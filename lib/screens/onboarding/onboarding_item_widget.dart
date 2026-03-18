import 'package:flutter/material.dart';

class OnboardingItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imageUrl;
  final Animation<double> animation;

  const OnboardingItemWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imageUrl,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image or Icon
            if (imageUrl != null)
              Image.asset(
                imageUrl!,
                height: 200,
                fit: BoxFit.contain,
              )
            else
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: color,
                ),
              ),

            const SizedBox(height: 48),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}