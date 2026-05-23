// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../data/models/workout_entry_model.dart';
import '../../data/workout_store.dart';

class EditWorkoutScreen extends StatefulWidget {
  const EditWorkoutScreen({super.key});

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  late String _selectedIntensity;
  late String _selectedFeeling;
  late TextEditingController _exerciseController;
  late TextEditingController _durationController;
  late TextEditingController _weightController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _kcalController;
  late TextEditingController _achievementController;
  late TextEditingController _notesController;

  WorkoutEntry? _entry;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _entry = GoRouterState.of(context).extra as WorkoutEntry?;
      _selectedIntensity = _entry?.intensity ?? 'Moderate';
      _selectedFeeling = 'Good';
      _exerciseController = TextEditingController(
        text: _entry?.exercise ?? 'Full Cardio',
      );
      _durationController = TextEditingController(
        text: _entry?.duration.split(' ')[0] ?? '0',
      );
      _weightController = TextEditingController(text: _entry?.weight ?? '0');
      _setsController = TextEditingController(text: _entry?.sets ?? '0');
      _repsController = TextEditingController(text: _entry?.reps ?? '0');
      _kcalController = TextEditingController(text: _entry?.calories ?? '');
      _achievementController = TextEditingController(
        text: _entry?.achievement ?? '',
      );
      _notesController = TextEditingController(text: _entry?.notes ?? '');
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _durationController.dispose();
    _weightController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _kcalController.dispose();
    _achievementController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Edit Workout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Exercise'),
            _buildDropdownField(_exerciseController.text),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Duration (min)'),
                      _buildTextField(_durationController),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Weight (kg)'),
                      _buildTextField(_weightController),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Sets'),
                      _buildTextField(_setsController),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Reps'),
                      _buildTextField(_repsController),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('Intensity'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildIntensityButton('Light'),
                const SizedBox(width: 12),
                _buildIntensityButton('Moderate'),
                const SizedBox(width: 12),
                _buildIntensityButton('Intense'),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('Feeling'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFeelingItem(
                  Icons.sentiment_very_dissatisfied,
                  'Exhausted',
                  'Tired',
                ),
                _buildFeelingItem(
                  Icons.sentiment_dissatisfied,
                  'Tired',
                  'Good',
                ),
                _buildFeelingItem(Icons.sentiment_satisfied, 'Good', 'Great'),
                _buildFeelingItem(
                  Icons.sentiment_very_satisfied,
                  'Unstoppable',
                  'UNSTOPPABLE',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('Estimated kcal'),
            _buildTextField(_kcalController, hint: 'Estimated kcal'),
            const SizedBox(height: 24),
            _buildLabel('Achievement unlocked? (e.g., New PB)'),
            _buildTextField(_achievementController, hint: 'Share your win!'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (_entry != null) {
                    try {
                      await WorkoutStore().updateEntry(
                        WorkoutEntry(
                          id: _entry!.id,
                          title: _entry!.title,
                          date: _entry!.date,
                          duration: '${_durationController.text} MIN',
                          exercise: _exerciseController.text,
                          intensity: _selectedIntensity,
                          weight: _weightController.text,
                          sets: _setsController.text,
                          reps: _repsController.text,
                          calories: _kcalController.text,
                          achievement: _achievementController.text,
                          notes: _notesController.text,
                        ),
                      );
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update workout: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }
                  }
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E6CF2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Update Entry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildLabel('Notes'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'How was your workout?',
                  hintStyle: TextStyle(color: Color(0xFF9155FD), fontSize: 12),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Color(0xFF9155FD), fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {String? hint}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdownField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _buildIntensityButton(String label) {
    final isSelected = _selectedIntensity == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIntensity = label),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0E6CF2)
                : const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeelingItem(IconData icon, String label, String designLabel) {
    final isSelected = _selectedFeeling == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFeeling = label),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0E6CF2).withValues(alpha: 0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF0E6CF2)
                  : const Color(0xFF9CA3AF),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            designLabel,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF0E6CF2)
                  : const Color(0xFF6B7280),
              fontSize: 8,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
