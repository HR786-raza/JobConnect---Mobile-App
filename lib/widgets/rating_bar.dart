import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? filledColor;
  final Color? unfilledColor;

  const RatingBar({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 20,
    this.filledColor,
    this.unfilledColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        if (index < rating.floor()) {
          return Icon(
            Icons.star,
            size: size,
            color: filledColor ?? Colors.amber,
          );
        } else if (index < rating && rating % 1 != 0) {
          return Icon(
            Icons.star_half,
            size: size,
            color: filledColor ?? Colors.amber,
          );
        } else {
          return Icon(
            Icons.star_border,
            size: size,
            color: unfilledColor ?? Colors.grey[400],
          );
        }
      }),
    );
  }
}