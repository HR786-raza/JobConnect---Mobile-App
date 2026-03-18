import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color? color;

  const SkillChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: EdgeInsets.only(
          left: 12,
          right: onDelete != null ? 4 : 12,
          top: 6,
          bottom: 6,
        ),
        decoration: BoxDecoration(
          color: (color ?? Theme.of(context).primaryColor).withOpacity(
            isSelected ? 0.2 : 0.1,
          ),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: color ?? Theme.of(context).primaryColor)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Theme.of(context).primaryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: color ?? Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}