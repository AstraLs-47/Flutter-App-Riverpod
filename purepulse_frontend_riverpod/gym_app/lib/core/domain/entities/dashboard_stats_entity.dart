class DashboardStatsEntity {
  final double avgBmi;
  final double avgHr;
  final int totalActivities;
  final bool hasNewAnnouncements;

  const DashboardStatsEntity({
    required this.avgBmi,
    required this.avgHr,
    required this.totalActivities,
    required this.hasNewAnnouncements,
  });

  DashboardStatsEntity copyWith({
    double? avgBmi,
    double? avgHr,
    int? totalActivities,
    bool? hasNewAnnouncements,
  }) {
    return DashboardStatsEntity(
      avgBmi: avgBmi ?? this.avgBmi,
      avgHr: avgHr ?? this.avgHr,
      totalActivities: totalActivities ?? this.totalActivities,
      hasNewAnnouncements: hasNewAnnouncements ?? this.hasNewAnnouncements,
    );
  }

  factory DashboardStatsEntity.empty() => const DashboardStatsEntity(
        avgBmi: 0.0,
        avgHr: 0.0,
        totalActivities: 0,
        hasNewAnnouncements: false,
      );

  @override
  String toString() =>
      'DashboardStatsEntity(avgBmi: $avgBmi, avgHr: $avgHr, totalActivities: $totalActivities)';
}
