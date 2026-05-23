// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../core/theme/app_colors.dart';
import '../utils/date_utils.dart';

class CustomCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const CustomCalendarPicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthGrid = AppDateUtils.generateMonthGrid(_currentMonth);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: _previousMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: _nextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Weekdays
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'].map((day) {
              return SizedBox(
                width: 32,
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: monthGrid.length,
            itemBuilder: (context, index) {
              final day = monthGrid[index];
              if (day == null) return const SizedBox.shrink();

              final isSelected =
                  day.year == _selectedDate.year &&
                  day.month == _selectedDate.month &&
                  day.day == _selectedDate.day;

              final isCurrentMonth = day.month == _currentMonth.month;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDate = day;
                  });
                  widget.onDateSelected(day);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : (isCurrentMonth
                                  ? AppColors.textPrimary
                                  : Colors.grey[300]),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: widget.onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Select',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
