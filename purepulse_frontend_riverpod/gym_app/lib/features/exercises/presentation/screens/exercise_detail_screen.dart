// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

// Project imports:
import '../../../admin/presentation/screens/activity_detail_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Map<String, String> exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  // Structural mock data mapping based on the admin logic
  Map<String, dynamic> _getWorkoutStructure() {
    final title = exercise['title'] ?? '';

    if (title.contains('Strength') || title.contains('Dumbbell')) {
      return {
        'duration': '60 min',
        'sections': [
          {
            'title': '🔥 Warm-Up',
            'items': [
              {
                'title': 'Treadmill Walking',
                'duration': '3-5 min',
                'note': 'Light pace',
              },
              {
                'title': 'Arm Circles',
                'duration': '30 sec each direction',
                'note': '',
              },
              {'title': 'High Knees', 'duration': '20 reps', 'note': ''},
              {
                'title': 'Dynamic Stretching',
                'duration': '2-3 min',
                'note': '',
              },
            ],
          },
          {
            'title': '💪 Main Strength Workout',
            'items': [
              {
                'title': 'Barbell Squat',
                'duration': '8-12 reps x 3 sets',
                'note': 'Keep chest up, push through heels',
              },
              {
                'title': 'Dumbbell Lunges',
                'duration': '8-10 reps each leg x 3 sets',
                'note': '',
              },
              {
                'title': 'Bench Press',
                'duration': '8-12 reps x 3 sets',
                'note': '',
              },
              {
                'title': 'Dumbbell Shoulder Press',
                'duration': '8-12 reps x 3 sets',
                'note': '',
              },
              {
                'title': 'Lat Pulldown',
                'duration': '8-12 reps x 3 sets',
                'note': '',
              },
              {
                'title': 'Seated Cable Row',
                'duration': '8-12 reps x 3 sets',
                'note': '',
              },
              {'title': 'Plank', 'duration': '30-45 sec x 3 sets', 'note': ''},
              {
                'title': 'Hanging Leg Raise',
                'duration': '10-15 reps x 3 sets',
                'note': '',
              },
            ],
          },
          {
            'title': '🧘 Cool Down',
            'items': [
              {
                'title': 'Hamstring Stretch',
                'duration': '20-30 sec',
                'note': '',
              },
              {
                'title': 'Quadriceps Stretch',
                'duration': '20-30 sec each leg',
                'note': '',
              },
              {'title': 'Child\'s Pose', 'duration': '30-60 sec', 'note': ''},
              {
                'title': 'Shoulder Stretch',
                'duration': '20-30 sec',
                'note': '',
              },
            ],
          },
        ],
        'rest':
            'Rest Guidelines: 60-90 sec between sets / 1-2 min between exercises',
      };
    } else if (title.contains('Running') || title.contains('Cardio Burn')) {
      return {
        'duration': '45 min',
        'sections': [
          {
            'title': '🔥 Warm-Up',
            'items': [
              {
                'title': 'Treadmill Walking',
                'duration': '3-5 min',
                'note': 'Light pace to get blood flowing',
              },
              {
                'title': 'Arm Circles',
                'duration': '30 sec each direction',
                'note': '',
              },
              {'title': 'High Knees', 'duration': '20 reps', 'note': ''},
            ],
          },
          {
            'title': '🏃 Main Cardio',
            'items': [
              {
                'title': 'Treadmill Run',
                'duration': '15 min',
                'note': 'Moderate pace, 65-75% max HR',
              },
              {'title': 'Jump Rope', 'duration': '3 sets, 3 min', 'note': ''},
              {
                'title': 'Cycling',
                'duration': '10 min',
                'note': 'High resistance intervals',
              },
            ],
          },
          {
            'title': '🧘 Cool Down',
            'items': [
              {'title': 'Walking', 'duration': '3 min', 'note': ''},
              {
                'title': 'Hamstring Stretch',
                'duration': '20-30 sec',
                'note': '',
              },
              {'title': 'Deep Breathing', 'duration': '2 min', 'note': ''},
            ],
          },
        ],
        'rest':
            'Rest Guidelines: 60-90 sec between sets / 1-2 min between exercises',
      };
    } else {
      return {
        'duration': '40 min',
        'sections': [
          {
            'title': '🔥 Warm-Up',
            'items': [
              {'title': 'March In Place', 'duration': '3 min', 'note': ''},
              {'title': 'Arm Swings', 'duration': '1 min', 'note': ''},
              {
                'title': 'Ankle Rotations',
                'duration': '30 sec each',
                'note': '',
              },
            ],
          },
          {
            'title': '🎵 Main Session',
            'items': [
              {'title': 'Step Touch', 'duration': '3 min', 'note': ''},
              {
                'title': 'Grapevine',
                'duration': 'Alternate sides for 3 min',
                'note': '',
              },
              {'title': 'Box Step', 'duration': '2 min', 'note': ''},
              {
                'title': 'Jumping Jacks',
                'duration': '3 sets x 20 reps',
                'note': '',
              },
              {
                'title': 'Yoga Flow',
                'duration': '10 min',
                'note': 'Sun salutation sequence',
              },
            ],
          },
          {
            'title': '🧘 Cool Down',
            'items': [
              {'title': 'Slow Walking', 'duration': '3 min', 'note': ''},
              {'title': 'Full Body Stretch', 'duration': '5 min', 'note': ''},
              {
                'title': 'Meditation Breathing',
                'duration': '3 min',
                'note': '',
              },
            ],
          },
        ],
        'rest':
            'Rest Guidelines: 60-90 sec between sets / 1-2 min between exercises',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // Delegate to the admin ActivityDetailScreen UI but hide admin actions (edit/delete)
    return ActivityDetailScreen(
      activity: exercise,
      onUpdate: () {},
      showActions: false,
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0E6CF2).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0E6CF2),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDurationTag(String duration) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 14, color: Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          duration,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(Map<String, dynamic> section) {
    final String title = section['title'];
    final List<Map<String, String>> items = (section['items'] as List)
        .cast<Map<String, String>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        ...items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number Circle (Blue)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E6CF2).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${idx + 1}',
                    style: const TextStyle(
                      color: Color(0xFF0E6CF2),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      if (item['note']!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item['note']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF0E6CF2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  item['duration']!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}
