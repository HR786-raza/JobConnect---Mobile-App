import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? hintText;
  final bool autoFocus;

  const CustomSearchBar({
    super.key,
    this.onTap,
    this.onChanged,
    this.controller,
    this.hintText,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                autofocus: autoFocus,
                decoration: InputDecoration(
                  hintText: hintText ?? 'Search...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (onTap != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: const Icon(Icons.tune, color: Colors.grey),
                  onPressed: onTap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}