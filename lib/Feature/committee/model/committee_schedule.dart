DateTime committeeDateForCycle(DateTime startDate, int cycleIndex) {
  if (cycleIndex < 0) {
    throw ArgumentError.value(cycleIndex, 'cycleIndex', 'Must not be negative.');
  }

  final DateTime targetMonth = DateTime(
    startDate.year,
    startDate.month + cycleIndex,
    1,
  );
  final int lastDay = DateTime(
    targetMonth.year,
    targetMonth.month + 1,
    0,
  ).day;

  return DateTime(
    targetMonth.year,
    targetMonth.month,
    startDate.day > lastDay ? lastDay : startDate.day,
  );
}

int committeeCycleCount(Map<String, dynamic> committee) {
  final int configuredMembers =
      int.tryParse(
        (committee['memberCount'] ?? committee['membersCount'] ?? '')
            .toString(),
      ) ??
      0;

  final dynamic members = committee['members'];
  final int savedMembersCount = members is List ? members.length : 0;
  return configuredMembers > savedMembersCount
      ? configuredMembers
      : savedMembersCount;
}
