import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final Color? backgroundColor;
  final bool showBorder;
  final Widget? child;

  const Avatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 24,
    this.backgroundColor,
    this.showBorder = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: Colors.white, width: 2)
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? 
            (imageUrl == null ? Theme.of(context).primaryColor.withOpacity(0.1) : null),
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child: child ?? 
            (initials != null
                ? Text(
                    initials!,
                    style: TextStyle(
                      color: backgroundColor != null 
                          ? Colors.white 
                          : Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: radius * 0.5,
                    ),
                  )
                : null),
      ),
    );
  }
}