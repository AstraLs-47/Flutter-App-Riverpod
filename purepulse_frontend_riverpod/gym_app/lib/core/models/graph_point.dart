class GraphPoint {
  final DateTime x;
  final double y;
  final String? label;
  final dynamic metadata; // Optional additional data (e.g. for tooltips)

  const GraphPoint({
    required this.x,
    required this.y,
    this.label,
    this.metadata,
  });

  factory GraphPoint.fromJson(Map<String, dynamic> json) {
    return GraphPoint(
      x: DateTime.parse(json['x']),
      y: (json['y'] as num).toDouble(),
      label: json['label'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x.toIso8601String(),
      'y': y,
      'label': label,
      'metadata': metadata,
    };
  }

  @override
  String toString() => 'GraphPoint(x: $x, y: $y, label: $label)';
}
