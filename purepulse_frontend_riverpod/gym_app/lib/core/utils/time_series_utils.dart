class TimeSeriesUtils {
  TimeSeriesUtils._();

  /// Generates a continuous list of dates between [startDate] and [endDate] (inclusive).
  /// This ensures that graph systems have an unbroken timeline even if there is no data
  /// on certain days, which is critical for accurate x-axis plotting.
  static List<DateTime> generateDateRange(DateTime startDate, DateTime endDate) {
    if (endDate.isBefore(startDate)) return [];
    
    final int days = endDate.difference(startDate).inDays;
    return List.generate(days + 1, (index) {
      return DateTime(startDate.year, startDate.month, startDate.day + index);
    });
  }

  /// Truncates the time component of a DateTime to group data strictly by day.
  static DateTime truncateToDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
