// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../data/health_service.dart';
import '../../data/models/health_record_model.dart';

class RecordHealthDialog extends StatefulWidget {
  const RecordHealthDialog({super.key});

  @override
  State<RecordHealthDialog> createState() => _RecordHealthDialogState();
}

class _RecordHealthDialogState extends State<RecordHealthDialog> {
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  double _bmi = 0;
  String _bmiCategory = 'NORMAL';
  Color _bmiColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_calculateBmi);
    _heightController.addListener(_calculateBmi);
  }

  void _calculateBmi() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;

    if (weight > 0 && height > 0) {
      final heightInMeters = height / 100;
      setState(() {
        _bmi = weight / (heightInMeters * heightInMeters);
        if (_bmi < 18.5) {
          _bmiCategory = 'UNDERWEIGHT';
          _bmiColor = Colors.orange;
        } else if (_bmi < 25) {
          _bmiCategory = 'NORMAL';
          _bmiColor = Colors.green;
        } else if (_bmi < 30) {
          _bmiCategory = 'OVERWEIGHT';
          _bmiColor = Colors.orange;
        } else {
          _bmiCategory = 'OBESE';
          _bmiColor = Colors.red;
        }
      });
    }
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _bloodSugarController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFF0E6CF2),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Record Today\'s Health',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'SYSTOLIC',
                          '120',
                          'MMHG',
                          _systolicController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          'DIASTOLIC',
                          '80',
                          'MMHG',
                          _diastolicController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'HEART RATE',
                          '72',
                          'BPM',
                          _heartRateController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          'BLOOD SUGAR',
                          '95',
                          'MG/DL',
                          _bloodSugarController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'WEIGHT(KG)',
                          '70.5',
                          'KG',
                          _weightController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          'HEIGHT(CM)',
                          '175',
                          'CM',
                          _heightController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildBmiDisplay(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final record = HealthRecord(
                          id: DateTime.now().toString(),
                          systolic:
                              double.tryParse(_systolicController.text) ?? 0,
                          diastolic:
                              double.tryParse(_diastolicController.text) ?? 0,
                          heartRate:
                              double.tryParse(_heartRateController.text) ?? 0,
                          bloodSugar:
                              double.tryParse(_bloodSugarController.text) ?? 0,
                          weight: double.tryParse(_weightController.text) ?? 0,
                          height: double.tryParse(_heightController.text) ?? 0,
                          bmi: _bmi,
                          date: DateTime.now(),
                        );
                        try {
                          await HealthService().addHealthRecord(record);
                          Navigator.pop(context, true);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save health data: $e'),
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
                      child: const Text(
                        'Record Health Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    String unit,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: InputBorder.none,
              suffixText: unit,
              suffixStyle: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBmiDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF0E6CF2), width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CALCULATED BMI',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _bmi.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _bmiColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _bmiCategory,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _bmiColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calculate_outlined,
              color: Color(0xFF0E6CF2),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
