// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../exercises/data/exercise_repository.dart';
import '../../data/models/workout_entry_model.dart';
import '../../data/workout_store.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  String _selectedIntensity = 'Moderate';
  String _selectedFeeling = 'Good';
  String? _selectedExercise;

  List<String> _exercises = [];

  final _durationController = TextEditingController(text: '0');
  final _weightController = TextEditingController(text: '0');
  final _setsController = TextEditingController(text: '0');
  final _repsController = TextEditingController(text: '0');
  final _kcalController = TextEditingController();
  final _achievementController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final repo = ExerciseRepository();
      final list = await repo.getExercises();
      if (list.isNotEmpty && mounted) {
        setState(() {
          _exercises = list.map((e) => e.title).toList();
          // If a previously selected value no longer exists in the refreshed items,
          // clear it to avoid DropdownButton assertion errors.
          if (_selectedExercise != null &&
              !_exercises.contains(_selectedExercise)) {
            _selectedExercise = null;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading exercises: $e');
    }
  }

  @override
  void dispose() {
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
          'Log Workout',
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
            _buildLabel('EXERCISE *'),
            _buildExerciseDropdown(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Duration (min)'),
                      _buildTextField(_durationController, isNumeric: true),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Weight (kg)'),
                      _buildTextField(_weightController, isNumeric: true),
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
                      _buildTextField(_setsController, isNumeric: true),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Reps'),
                      _buildTextField(_repsController, isNumeric: true),
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
                ),
                _buildFeelingItem(Icons.sentiment_dissatisfied, 'Tired'),
                _buildFeelingItem(Icons.sentiment_satisfied, 'Good'),
                _buildFeelingItem(
                  Icons.sentiment_very_satisfied,
                  'Unstoppable',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('CALORIES BURNED (EST.)'),
            _buildTextField(
              _kcalController,
              hint: '0',
              icon: Icons.bolt,
              isNumeric: true,
            ),
            const SizedBox(height: 24),
            _buildLabel('Notes'),
            _buildTextField(
              _notesController,
              hint: 'How was the session? Any thoughts...',
            ),
            const SizedBox(height: 24),
            _buildLabel('Achievement unlocked? (e.g., New PB!)'),
            _buildTextField(
              _achievementController,
              hint: 'Share your win!',
              icon: Icons.emoji_events_outlined,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedExercise == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select an exercise'),
                      ),
                    );
                    return;
                  }
                  try {
                    await WorkoutStore().addEntry(
                      WorkoutEntry(
                        id: DateTime.now().toString(),
                        title: _selectedExercise!,
                        date: DateTime.now().toIso8601String().split('T').first,
                        duration:
                            '${_durationController.text.isEmpty ? "0" : _durationController.text} MIN',
                        exercise: _selectedExercise!,
                        intensity: _selectedIntensity,
                        weight: _weightController.text.isEmpty
                            ? "0"
                            : _weightController.text,
                        sets: _setsController.text.isEmpty
                            ? "0"
                            : _setsController.text,
                        reps: _repsController.text.isEmpty
                            ? "0"
                            : _repsController.text,
                        calories: _kcalController.text.isEmpty
                            ? "0"
                            : _kcalController.text,
                        achievement: _achievementController.text,
                        notes: _notesController.text,
                      ),
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Workout logged successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.pop();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to log workout: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E6CF2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Log Workout 🔥',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? hint,
    IconData? icon,
    bool isNumeric = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, size: 16, color: const Color(0xFF94A3B8))
              : null,
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

  Widget _buildExerciseDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedExercise,
          hint: const Text(
            'Choose your exercise...',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          items: _exercises.map((String exercise) {
            return DropdownMenuItem<String>(
              value: exercise,
              child: Text(
                exercise,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedExercise = newValue;
            });
          },
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildIntensityButton(String label) {
    final isSelected = _selectedIntensity == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIntensity = label),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0E6CF2)
                : const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(10),
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

  Widget _buildFeelingItem(IconData icon, String label) {
    final isSelected = _selectedFeeling == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFeeling = label),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
                  : const Color(0xFF94A3B8),
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF0E6CF2)
                  : const Color(0xFF6B7280),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
