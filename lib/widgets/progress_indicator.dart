import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;

  const CustomProgressIndicator({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPercentage)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        if (showPercentage) const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.grey[200],
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: progressColor ?? Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isOdd) {
              return Expanded(
                child: Container(
                  height: 2,
                  color: index ~/ 2 < currentStep - 1
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                ),
              );
            }
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep - 1;
            final isCurrent = stepIndex == currentStep - 1;
            
            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? Theme.of(context).primaryColor
                    : isCurrent
                        ? Theme.of(context).primaryColor.withOpacity(0.2)
                        : Colors.grey[300],
                border: isCurrent
                    ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          color: isCurrent
                              ? Theme.of(context).primaryColor
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
              ),
            );
          }),
        ),
        if (stepLabels != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stepLabels!.map((label) {
              return Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}