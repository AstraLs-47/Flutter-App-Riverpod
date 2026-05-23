// Project imports:
import 'graph_point.dart';

class GraphDataset {
  final String title;
  final List<GraphPoint> points;
  final String? yAxisLabel;
  final String? xAxisLabel;

  const GraphDataset({
    required this.title,
    required this.points,
    this.yAxisLabel,
    this.xAxisLabel,
  });

  factory GraphDataset.fromJson(Map<String, dynamic> json) {
    return GraphDataset(
      title: json['title'],
      points: (json['points'] as List)
          .map((p) => GraphPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      yAxisLabel: json['yAxisLabel'],
      xAxisLabel: json['xAxisLabel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'points': points.map((p) => p.toJson()).toList(),
      'yAxisLabel': yAxisLabel,
      'xAxisLabel': xAxisLabel,
    };
  }

  bool get isEmpty => points.isEmpty;
  bool get isNotEmpty => points.isNotEmpty;

  double get maxY {
    if (isEmpty) return 0;
    return points.map((p) => p.y).reduce((a, b) => a > b ? a : b);
  }

  double get minY {
    if (isEmpty) return 0;
    return points.map((p) => p.y).reduce((a, b) => a < b ? a : b);
  }
}
