import 'committee_schedule.dart';

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

    final int cycleCount = committeeCycleCount(committee);
    if (cycleCount <= 0) continue;

    final String committeeId = committee['id']?.toString() ?? '';
    final String name = committee['name']?.toString().trim() ?? '';
    for (int index = 1; index <= cycleCount; index++) {
      result.add(
        CommitteeReminderOccurrence(
          committeeId: committeeId,
          committeeName: name,
          date: committeeDateForCycle(firstDate, index),
        ),
      );
    }
  }

  result.sort((first, second) => first.date.compareTo(second.date));
  return result;
}
