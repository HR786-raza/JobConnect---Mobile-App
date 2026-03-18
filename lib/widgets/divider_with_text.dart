import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final double height;

  const DividerWithText({
    super.key,
    required this.text,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: height),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}