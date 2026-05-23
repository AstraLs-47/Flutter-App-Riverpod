// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../progress/data/health_store.dart';
import '../../../workout/data/workout_store.dart';

class HealthSnapshotCard extends StatelessWidget {
  const HealthSnapshotCard({super.key});

  @override
  Widget build(BuildContext context) {
    final healthStore = HealthStore();
    final workoutStore = WorkoutStore();
    final latest = healthStore.latestRecord;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HEALTH SNAPSHOT',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSnapshotItem(
                latest != null ? '${latest.systolic.toInt()}/${latest.diastolic.toInt()}' : '0/0', 
                'Blood Pressure',
                Icons.bolt,
              ),
              _buildSnapshotItem(
                latest != null ? '${latest.weight.toStringAsFixed(1)} kg' : '0 kg', 
                'Weight',
                Icons.balance,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSnapshotItem(
                latest != null ? '${latest.bloodSugar.toInt()} mg/dL' : '0 mg/dL', 
                'Blood Sugar',
                Icons.water_drop_outlined,
              ),
              _buildSnapshotItem(
                '${workoutStore.count}', 
                'Total Activities',
                Icons.directions_run,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotItem(String value, String label, IconData icon) {
    final parts = value.split(' ');
    final mainValue = parts[0];
    final unit = parts.length > 1 ? parts[1] : '';

    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0E6CF2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      mainValue,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
