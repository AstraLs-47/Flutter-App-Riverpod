// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:go_router/go_router.dart';

// Project imports:
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/auth_service.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  void _next() async {
    if (_currentPage < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      setState(() => _isLoading = true);
      try {
        await AuthService().submitOnboarding();
        if (mounted) {
          context.goNamed(RouteConstants.dashboardName);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Onboarding failed: ${e.toString().replaceFirst('Exception: ', '').replaceFirst('ApiException: ', '')}',
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _GoalSelectionPage(onNext: _next),
                _ActivityLevelPage(onNext: _next, onBack: _back),
                _UserInfoPage(onNext: _next, onBack: _back),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  final String question;
  const _OnboardingHeader({required this.question});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'THE PULSE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Hey, ${AuthService.currentUserName} ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text('💪', style: TextStyle(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _GoalSelectionPage extends StatefulWidget {
  final VoidCallback onNext;
  const _GoalSelectionPage({required this.onNext});

  @override
  State<_GoalSelectionPage> createState() => _GoalSelectionPageState();
}

class _GoalSelectionPageState extends State<_GoalSelectionPage> {
  String? selectedGoal;
  final List<String> goals = [
    'Lose Weight',
    'Gain Weight',
    'Gain Muscle',
    'Manage Stress',
    'Maintain Weight',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OnboardingHeader(question: 'What is your goal?'),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          ...goals.map(
                            (goal) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _OptionButton(
                                label: goal,
                                isSelected: selectedGoal == goal,
                                onTap: () {
                                  setState(() => selectedGoal = goal);
                                  AuthService.selectedGoal = goal;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _NavButton(
                      label: 'Next',
                      onTap: () {
                        if (selectedGoal == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select your goal to continue',
                              ),
                            ),
                          );
                        } else {
                          widget.onNext();
                        }
                      },
                      isPrimary: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityLevelPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _ActivityLevelPage({required this.onNext, required this.onBack});

  @override
  State<_ActivityLevelPage> createState() => _ActivityLevelPageState();
}

class _ActivityLevelPageState extends State<_ActivityLevelPage> {
  String? selectedLevel;
  final List<String> levels = [
    'Active',
    'Very Active',
    'Lightly Active',
    'Not Active',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _OnboardingHeader(
            question: 'What is your baseline activity level?',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F8),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          ...levels.map(
                            (level) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _OptionButton(
                                label: level,
                                isSelected: selectedLevel == level,
                                onTap: () {
                                  setState(() => selectedLevel = level);
                                  AuthService.activityLevel = level;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NavButton(
                        label: 'Back',
                        onTap: widget.onBack,
                        isPrimary: false,
                      ),
                      _NavButton(
                        label: 'Next',
                        onTap: () {
                          if (selectedLevel == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select your activity level',
                                ),
                              ),
                            );
                          } else {
                            widget.onNext();
                          }
                        },
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserInfoPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const _UserInfoPage({required this.onNext, required this.onBack});

  @override
  State<_UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<_UserInfoPage> {
  String selectedSex = 'Female';
  final _birthController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalWeightController = TextEditingController();

  @override
  void dispose() {
    _birthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  bool _isValidBirthDate(String input) {
    final match = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{4})$').firstMatch(input);
    if (match == null) return false;
    final month = int.tryParse(match.group(1)!) ?? 0;
    final day = int.tryParse(match.group(2)!) ?? 0;
    final year = int.tryParse(match.group(3)!) ?? 0;
    if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1900) {
      return false;
    }
    final date = DateTime.tryParse(
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
    );
    if (date == null) return false;
    return date.year == year &&
        date.month == month &&
        date.day == day &&
        date.isBefore(DateTime.now());
  }

  double? _parseMetric(String input) {
    final cleaned = input.trim().replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  void _validateAndProceed() {
    final birthText = _birthController.text.trim();
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();
    final goalWeightText = _goalWeightController.text.trim();

    if (birthText.isEmpty ||
        heightText.isEmpty ||
        weightText.isEmpty ||
        goalWeightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all information to complete your profile',
          ),
        ),
      );
      return;
    }

    if (!_isValidBirthDate(birthText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid birthdate in mm/dd/yyyy format'),
        ),
      );
      return;
    }

    final parsedHeight = _parseMetric(heightText);
    final parsedWeight = _parseMetric(weightText);
    final parsedGoalWeight = _parseMetric(goalWeightText);

    if (parsedHeight == null || parsedHeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid height in meters')),
      );
      return;
    }

    if (parsedWeight == null || parsedWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid current weight in kg'),
        ),
      );
      return;
    }

    if (parsedGoalWeight == null || parsedGoalWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid goal weight in kg')),
      );
      return;
    }

    // Save to AuthService
    AuthService.sex = selectedSex;
    AuthService.birthDate = birthText;
    AuthService.height = heightText;
    AuthService.weight = weightText;
    AuthService.goalWeight = goalWeightText;

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _OnboardingHeader(
                    question:
                        'Please select which sex we should use to calculate your calorie needs.',
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      _SexOption(
                        label: 'Female',
                        isSelected: selectedSex == 'Female',
                        onTap: () => setState(() => selectedSex = 'Female'),
                      ),
                      const SizedBox(width: 48),
                      _SexOption(
                        label: 'Male',
                        isSelected: selectedSex == 'Male',
                        onTap: () => setState(() => selectedSex = 'Male'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _InputField(
                    label: 'When were you born?',
                    hint: 'mm/dd/yyyy',
                    controller: _birthController,
                  ),
                  const SizedBox(height: 24),
                  _InputField(
                    label: 'How tall are you?',
                    hint: 'Height (meter)',
                    controller: _heightController,
                  ),
                  const SizedBox(height: 24),
                  _InputField(
                    label: 'How much do you weight?',
                    hint: 'Current weight(kg)',
                    controller: _weightController,
                  ),
                  const SizedBox(height: 24),
                  _InputField(
                    label: 'What\'s your goal weight?',
                    hint: 'Goal weight(kg)',
                    controller: _goalWeightController,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(label: 'Back', onTap: widget.onBack, isPrimary: false),
              _NavButton(
                label: 'Next',
                onTap: _validateAndProceed,
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primary : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _SexOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SexOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _NavButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppColors.primary
              : const Color(0xFFF0F0F0),
          foregroundColor: isPrimary ? Colors.white : AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
