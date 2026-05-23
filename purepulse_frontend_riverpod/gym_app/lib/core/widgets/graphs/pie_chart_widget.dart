// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';

// Project imports:
import '../../models/graph_dataset.dart';
import '../../theme/app_colors.dart';

class PieChartWidget extends StatelessWidget {
  final GraphDataset dataset;
  final double height;

  const PieChartWidget({super.key, required this.dataset, this.height = 220});

  @override
  Widget build(BuildContext context) {
    if (dataset.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final total = dataset.points.fold(0.0, (sum, point) => sum + point.y);

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 50,
                sections: dataset.points.map((point) {
                  return PieChartSectionData(
                    color: _getColorForLabel(point.label),
                    value: point.y,
                    title: '',
                    radius: 30,
                    showTitle: false,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(total),
        ],
      ),
    );
  }

  Widget _buildLegend(double total) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: dataset.points.map((point) {
        final percent = total > 0 ? (point.y / total * 100).round() : 0;
        return _buildLegendItem(
          _getColorForLabel(point.label),
          '${point.label ?? "Unknown"} $percent%',
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getColorForLabel(String? label) {
    switch (label) {
      case 'Cardio':
        return AppColors.primary;
      case 'Strength':
        return const Color(0xFF1EA1F2);
      case 'Aerobics':
        return const Color(0xFF90CAF9);
      default:
        // Use hash code to generate a somewhat consistent color
        return Color((label?.hashCode ?? 0) * 0xFFFFFF).withValues(alpha: 1.0);
    }
  }
}
