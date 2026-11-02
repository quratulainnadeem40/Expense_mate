class CommitteeReminderOccurrence {
  final String committeeId;
  final String committeeName;
  final DateTime date;

  const CommitteeReminderOccurrence({
    required this.committeeId,
    required this.committeeName,
    required this.date,
  });

  DateTime reminderDate({required int daysBefore}) {
    if (daysBefore != 0 && daysBefore != 1) {
      throw ArgumentError.value(daysBefore, 'daysBefore', 'Must be 0 or 1.');
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      9,
    ).subtract(Duration(days: daysBefore));
  }
}

List<CommitteeReminderOccurrence> buildCommitteeReminderOccurrences(
  Iterable<Map<String, dynamic>> committees,
) {
  final List<CommitteeReminderOccurrence> result = [];

  for (final Map<String, dynamic> committee in committees) {
    final dynamic storedDate = committee['startDate'];
    final DateTime? firstDate = storedDate is DateTime
        ? storedDate
        : DateTime.tryParse(storedDate?.toString() ?? '');
    if (firstDate == null) continue;

    final int duration =
        int.tryParse(committee['duration']?.toString() ?? '') ?? 0;
    if (duration <= 0) continue;

    final String unit = (committee['unit']?.toString() ?? 'Months')
        .trim()
        .toLowerCase();
    final double durationInMonths = switch (unit) {
      'year' || 'years' => duration * 12,
      'week' || 'weeks' => duration / 4.345,
      'day' || 'days' => duration / 30,
      _ => duration.toDouble(),
    };

    final String committeeId = committee['id']?.toString() ?? '';
    final String name = committee['name']?.toString().trim() ?? '';
    for (int index = 0; index < durationInMonths.ceil(); index++) {
      final DateTime targetMonth = DateTime(
        firstDate.year,
        firstDate.month + index,
        1,
      );
      final int lastDay = DateTime(
        targetMonth.year,
        targetMonth.month + 1,
        0,
      ).day;

      result.add(
        CommitteeReminderOccurrence(
          committeeId: committeeId,
          committeeName: name,
          date: DateTime(
            targetMonth.year,
            targetMonth.month,
            firstDate.day > lastDay ? lastDay : firstDate.day,
          ),
        ),
      );
    }
  }

  result.sort((first, second) => first.date.compareTo(second.date));
  return result;
}
