// Project imports:
import 'package:gym_app/features/progress/data/models/health_record_model.dart';
import 'package:gym_app/features/workout/data/models/workout_entry_model.dart';
import 'package:gym_app/core/models/graph_dataset.dart';
import 'package:gym_app/core/models/graph_point.dart';
import 'package:gym_app/core/utils/time_series_utils.dart';

class GraphTransformers {
  GraphTransformers._();

  static List<GraphDataset> healthRecordsToDatasets(List<HealthRecord> records, String metric) {
    if (metric == 'BP') {
      final systolicPoints = records.map((r) => GraphPoint(x: r.date, y: r.systolic, label: 'Systolic')).toList();
      final diastolicPoints = records.map((r) => GraphPoint(x: r.date, y: r.diastolic, label: 'Diastolic')).toList();
      
      systolicPoints.sort((a, b) => a.x.compareTo(b.x));
      diastolicPoints.sort((a, b) => a.x.compareTo(b.x));

      return [
        GraphDataset(title: 'Systolic', points: systolicPoints),
        GraphDataset(title: 'Diastolic', points: diastolicPoints),
      ];
    }

    final points = records.map((r) {
      double yValue = 0;
      switch (metric) {
        case 'BMI': yValue = r.bmi; break;
        case 'Heart Rate': yValue = r.heartRate; break;
      }
      return GraphPoint(
        x: r.date,
        y: yValue,
        label: metric,
      );
    }).toList();

    points.sort((a, b) => a.x.compareTo(b.x));

    return [
      GraphDataset(
        title: metric,
        points: points,
      )
    ];
  }

  /// Transforms a list of [WorkoutEntry] into a dataset showing workouts over time
  /// Groups entries by day and counts them.
  static GraphDataset userWorkoutsOverTime(List<WorkoutEntry> entries, DateTime startDate, DateTime endDate) {
    final dateRange = TimeSeriesUtils.generateDateRange(startDate, endDate);
    
    // Group raw entries by date string
    final Map<String, int> countsByDate = {};
    for (final entry in entries) {
      countsByDate[entry.date] = (countsByDate[entry.date] ?? 0) + 1;
    }

    final points = dateRange.map((date) {
      final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final count = countsByDate[dateString] ?? 0;
      
      return GraphPoint(
        x: date,
        y: count.toDouble(),
        label: dateString,
      );
    }).toList();

    return GraphDataset(
      title: 'Workout Frequency',
      points: points,
      yAxisLabel: 'Workouts',
      xAxisLabel: 'Date',
    );
  }

  /// Transforms a list of [WorkoutEntry] into a dataset showing calories burned over time
  static GraphDataset userCaloriesOverTime(List<WorkoutEntry> entries, DateTime startDate, DateTime endDate) {
    final dateRange = TimeSeriesUtils.generateDateRange(startDate, endDate);
    
    // Group raw entries by date string and sum calories
    final Map<String, double> caloriesByDate = {};
    for (final entry in entries) {
      final cal = double.tryParse(entry.calories ?? '0') ?? 0.0;
      caloriesByDate[entry.date] = (caloriesByDate[entry.date] ?? 0.0) + cal;
    }

    final points = dateRange.map((date) {
      final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final cal = caloriesByDate[dateString] ?? 0.0;
      
      return GraphPoint(
        x: date,
        y: cal,
        label: dateString,
      );
    }).toList();

    return GraphDataset(
      title: 'Calories Burned',
      points: points,
      yAxisLabel: 'Kcal',
      xAxisLabel: 'Date',
    );
  }

  // Example admin transformer: User Growth over time
  static GraphDataset adminUserEngagement(List<double> rawData) {
    final points = rawData.asMap().entries.map((e) {
      return GraphPoint(
        x: DateTime.now().subtract(Duration(days: 6 - e.key)),
        y: e.value,
        label: "Day ${e.key}",
      );
    }).toList();

    return GraphDataset(
      title: 'User Activity',
      points: points,
    );
  }

  static GraphDataset adminCategoryDistribution(Map<String, double> data) {
    final points = data.entries.map((e) {
      return GraphPoint(
        x: DateTime.now(), // Irrelevant for pie charts
        y: e.value,
        label: e.key,
      );
    }).toList();

    return GraphDataset(
      title: 'By Category',
      points: points,
    );
  }

  static GraphDataset adminProductsByType(List<double> data, List<String> labels) {
    final points = data.asMap().entries.map((e) {
      return GraphPoint(
        x: DateTime.now(), // Irrelevant for bar charts
        y: e.value,
        label: e.key < labels.length ? labels[e.key] : '',
      );
    }).toList();

    return GraphDataset(
      title: 'Products by Type',
      points: points,
    );
  }
}
