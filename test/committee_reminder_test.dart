import 'package:expense_mate/Feature/committee/model/committee_reminder_occurrence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('committee reminder dates', () {
    test('calculates reminder from any due date, at 9 AM', () {
      final dueDates = [
        DateTime(2026, 11, 18),
        DateTime(2027, 3, 21),
        DateTime(2028, 1, 1),
      ];

      for (final dueDate in dueDates) {
        final occurrence = CommitteeReminderOccurrence(
          committeeId: 'committee',
          committeeName: 'Monthly committee',
          date: dueDate,
        );

        expect(
          occurrence.reminderDate(daysBefore: 1),
          DateTime(dueDate.year, dueDate.month, dueDate.day - 1, 9),
        );
        expect(
          occurrence.reminderDate(daysBefore: 0),
          DateTime(dueDate.year, dueDate.month, dueDate.day, 9),
        );
      }
    });

    test('clamps monthly dates to the last day of shorter months', () {
      final occurrences = buildCommitteeReminderOccurrences([
        {
          'id': 'committee',
          'name': 'Month end',
          'startDate': DateTime(2026, 1, 31),
          'duration': 3,
          'unit': 'Months',
        },
      ]);

      expect(occurrences.map((occurrence) => occurrence.date), [
        DateTime(2026, 1, 31),
        DateTime(2026, 2, 28),
        DateTime(2026, 3, 31),
      ]);
    });

    test('builds occurrences for every saved committee and sorts by date', () {
      final occurrences = buildCommitteeReminderOccurrences([
        {
          'id': 'later',
          'name': 'Later',
          'startDate': DateTime(2026, 12, 8),
          'duration': 1,
          'unit': 'Months',
        },
        {
          'id': 'earlier',
          'name': 'Earlier',
          'startDate': DateTime(2026, 11, 5),
          'duration': 1,
          'unit': 'Months',
        },
      ]);

      expect(occurrences.map((occurrence) => occurrence.date), [
        DateTime(2026, 11, 5),
        DateTime(2026, 12, 8),
      ]);
    });
  });
}
