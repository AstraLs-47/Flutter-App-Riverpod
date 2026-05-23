// Flutter imports:
import 'package:flutter/material.dart';

class DailyGoalProgress extends StatelessWidget {
  final int percentage;

  const DailyGoalProgress({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    // Convert percentage to 0.0 - 1.0 range
    final double value = percentage / 100.0;

    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F1F1).withValues(alpha: 0.3),
              border: Border.all(color: const Color(0xFFF1F1F1), width: 12),
            ),
          ),
          // Progress Indicator
          if (percentage > 0)
            SizedBox(
              height: 200,
              width: 200,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 12,
                backgroundColor: Colors.transparent,
                color: const Color(0xFF0E6CF2),
                strokeCap: StrokeCap.round,
              ),
            ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$percentage %',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'DAILY GOAL',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
