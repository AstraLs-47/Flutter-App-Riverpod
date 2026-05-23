// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';

// Project imports:
import '../../models/graph_dataset.dart';

class LineGraphWidget extends StatelessWidget {
  final List<GraphDataset> datasets;
  final List<Color>? lineColors;
  final double height;
  final bool showTooltips;
  final double? yInterval;
  final double? fixedMaxY;
  final double? fixedMinY;

  const LineGraphWidget({
    super.key,
    required this.datasets,
    this.lineColors,
    this.height = 220,
    this.showTooltips = true,
    this.yInterval,
    this.fixedMaxY,
    this.fixedMinY,
  });

  @override
  Widget build(BuildContext context) {
    if (datasets.isEmpty || datasets.every((d) => d.isEmpty)) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ),
      );
    }

    double maxY = fixedMaxY ?? 0;
    double minY = fixedMinY ?? double.infinity;
    int maxPointsCount = 0;

    if (fixedMaxY == null || fixedMinY == null) {
      for (final dataset in datasets) {
        if (dataset.isNotEmpty) {
          if (dataset.maxY > maxY) {
            maxY = dataset.maxY;
          }
          if (dataset.minY < minY) {
            minY = dataset.minY;
          }
          if (dataset.points.length > maxPointsCount) {
            maxPointsCount = dataset.points.length;
          }
        }
      }
      maxY = maxY > 0 ? maxY * 1.2 : 140.0;
      minY = minY != double.infinity ? (minY * 0.8).floorToDouble() : 60.0;
    } else {
      for (final dataset in datasets) {
        if (dataset.isNotEmpty && dataset.points.length > maxPointsCount) {
          maxPointsCount = dataset.points.length;
        }
      }
    }

    final lineBarsData = datasets.asMap().entries.map((entry) {
      final index = entry.key;
      final dataset = entry.value;

      final color = lineColors != null && index < lineColors!.length
          ? lineColors![index]
          : (index == 0 ? const Color(0xFF0E6CF2) : const Color(0xFF93C5FD));

      List<FlSpot> spots = dataset.points.asMap().entries.map((pEntry) {
        return FlSpot(pEntry.key.toDouble(), pEntry.value.y);
      }).toList();

      if (spots.length == 1) {
        spots = [FlSpot(0, spots[0].y), FlSpot(1, spots[0].y)];
      }

      return LineChartBarData(
        spots: spots,
        isCurved: true, // Returned to curved representation
        color: color,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
        // Area fill: Restored for high-fidelity look
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.05),
        ),
      );
    }).toList();

    return SizedBox(
      height: height,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            // REMOVE THE "STICK" (Vertical Indicator Line)
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      const FlLine(
                        color: Colors.transparent,
                      ), // Transparent "stick"
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 6,
                              color: barData.color ?? const Color(0xFF0E6CF2),
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                      ),
                    );
                  }).toList();
                },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.white,
              tooltipBorder: const BorderSide(color: Color(0xFFF1F5F9)),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                if (touchedBarSpots.isEmpty) return [];

                final dataset0 = datasets[0];
                final pointIndex = touchedBarSpots[0].x.toInt();
                final point = dataset0.points.length > pointIndex
                    ? dataset0.points[pointIndex]
                    : dataset0.points[0];
                final dateStr =
                    "${point.x.month.toString().padLeft(2, '0')}-${point.x.day.toString().padLeft(2, '0')}";

                return [
                  LineTooltipItem(
                    '',
                    const TextStyle(fontSize: 0),
                    children: [
                      TextSpan(
                        text: '$dateStr\n',
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      ...touchedBarSpots.map((barSpot) {
                        final ds = datasets[barSpot.barIndex];
                        final isSystolic = ds.title.toLowerCase().contains(
                          'systolic',
                        );
                        return TextSpan(
                          text: '\n${ds.title} : ${barSpot.y.toInt()}',
                          style: TextStyle(
                            color: isSystolic
                                ? const Color(0xFF0E6CF2)
                                : const Color(0xFF93C5FD),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            height: 1.8,
                          ),
                        );
                      }),
                    ],
                  ),
                ];
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Color(0xFFF1F5F9),
                strokeWidth: 1,
                dashArray: [3, 3],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0) return const SizedBox.shrink();
                  final ds = datasets.firstWhere(
                    (d) => d.isNotEmpty,
                    orElse: () => datasets[0],
                  );
                  if (ds.isEmpty || value.toInt() >= ds.points.length) {
                    return const SizedBox.shrink();
                  }
                  final date = ds.points[value.toInt()].x;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 9,
                      ),
                    ),
                  );
                },
                reservedSize: 22,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval:
                    yInterval ?? (maxY > 10 ? (maxY / 5).ceilToDouble() : 2),
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: maxPointsCount <= 1 ? 1 : (maxPointsCount - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: lineBarsData,
        ),
      ),
    );
  }
}
