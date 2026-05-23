class AppDateUtils {
  AppDateUtils._();

  static List<DateTime?> generateMonthGrid(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    
    int weekdayOfFirst = firstDay.weekday; // 1 = Mon, 7 = Sunday
    int offset = weekdayOfFirst - 1;
    
    // Always generate 42 cells (6 weeks) for a stable UI
    return List.generate(42, (index) {
      if (index < offset || index >= offset + lastDay.day) return null;
      return DateTime(month.year, month.month, index - offset + 1);
    });
  }
}
