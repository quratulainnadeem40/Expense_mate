import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/committe_controller.dart';

class CommitteeHistoryView extends StatefulWidget {
  const CommitteeHistoryView({super.key});

  @override
  State<CommitteeHistoryView> createState() => _CommitteeHistoryViewState();
}

class _CommitteeHistoryViewState extends State<CommitteeHistoryView> {
  final CommitteeController _committeeController = CommitteeController.instance;
  String _selectedFilter = 'Active';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F6F8);
    final Color cardColor = theme.colorScheme.surface;
    final Color borderColor = theme.colorScheme.outlineVariant;
    final Color secondaryTextColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Committee History'.tr),
        centerTitle: true,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: 'Active',
                  label: Text('Active'.tr),
                ),
                ButtonSegment<String>(
                  value: 'Completed',
                  label: Text('Completed'.tr),
                ),
              ],
              selected: {_selectedFilter},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _selectedFilter = selection.first);
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              final List<Map<String, dynamic>> committees = _committeeController
                  .committees
                  .map((committee) => Map<String, dynamic>.from(committee))
                  .where((committee) {
                    return _isCompleted(committee) ==
                        (_selectedFilter == 'Completed');
                  })
                  .toList();

              if (_committeeController.committees.isEmpty) {
                return Center(
                  child: Text(
                    'No committees available yet.'.tr,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                );
              }

              if (committees.isEmpty) {
                return Center(
                  child: Text(
                    'No committees in this category.'.tr,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: committees.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final Map<String, dynamic> committee = committees[index];
                  return _buildCommitteeCard(
                    context: context,
                    committee: committee,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    secondaryTextColor: secondaryTextColor,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitteeCard({
    required BuildContext context,
    required Map<String, dynamic> committee,
    required Color cardColor,
    required Color borderColor,
    required Color secondaryTextColor,
  }) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final bool completed = _isCompleted(committee);
    final DateTime? startDate = _parseDate(committee['startDate']);
    final DateTime? endDate = _parseDate(committee['endingDate']);
    final List<Map<String, dynamic>> members = _membersFor(committee);
    final int totalMembers = _integer(
      committee['memberCount'] ?? committee['membersCount'],
      members.length,
    );
    final double monthlyAmount = _number(committee['contribution']);
    final int roundCount = _roundCount(committee, members.length);
    final List<DateTime?> memberReceiveDates = _memberReceiveDates(
      members.length,
      roundCount,
      startDate,
      endDate,
      completed,
    );
    final int completedRounds = memberReceiveDates
        .where((date) => date != null)
        .length;
    final double progress = roundCount == 0
        ? 0
        : (completedRounds / roundCount).clamp(0.0, 1.0);
    final String committeeName =
        committee['name']?.toString().trim().isNotEmpty == true
        ? committee['name'].toString()
        : 'Committee'.tr;
    final Color statusColor = completed
        ? secondaryTextColor
        : (isDark ? const Color(0xFF81C784) : const Color(0xFF218653));
    final Color statusBackground = completed
        ? theme.colorScheme.surfaceContainerHighest
        : (isDark ? const Color(0xFF263D32) : const Color(0xFFDDF5E5));

    final List<_CommitteeMemberWithDate> orderedMembers = _orderedMembers(
      members,
      memberReceiveDates,
    );

    return Card(
      margin: EdgeInsets.zero,
      color: cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => _CommitteeHistoryDetailView(
                committeeName: committeeName,
                completed: completed,
                members: orderedMembers,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      committeeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      completed ? 'Completed' : 'Active',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, color: secondaryTextColor),
                ],
              ),
              const SizedBox(height: 14),
              _summaryLine(
                context,
                'Total amount',
                '${_formatAmount(monthlyAmount * totalMembers)} '
                    '($totalMembers members x ${_formatAmount(monthlyAmount)})',
              ),
              const SizedBox(height: 9),
              _summaryLine(
                context,
                'Monthly installment',
                _formatAmount(monthlyAmount),
              ),
              const SizedBox(height: 9),
              _summaryLine(context, 'Total members', '$totalMembers'),
              const SizedBox(height: 9),
              _summaryLine(
                context,
                'Start date',
                _formatDate(startDate) ?? '—',
              ),
              const SizedBox(height: 12),
              Text(
                '$completedRounds/$roundCount rounds complete',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 7),
              LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryLine(BuildContext context, String label, String value) {
    final TextStyle? labelStyle = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    final TextStyle? valueStyle = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 142, child: Text(label, style: labelStyle)),
        Expanded(child: Text(value, style: valueStyle)),
      ],
    );
  }

  bool _isCompleted(Map<String, dynamic> committee) {
    final DateTime? endingDate = _parseDate(committee['endingDate']);
    if (endingDate == null) return false;
    final DateTime today = DateUtils.dateOnly(DateTime.now());
    return DateUtils.dateOnly(endingDate).isBefore(today);
  }

  List<Map<String, dynamic>> _membersFor(Map<String, dynamic> committee) {
    final dynamic savedMembers = committee['members'];
    if (savedMembers is! List) return [];

    return savedMembers
        .whereType<Map>()
        .map((member) => Map<String, dynamic>.from(member))
        .where((member) => member['name']?.toString().trim().isNotEmpty == true)
        .toList();
  }

  int _roundCount(Map<String, dynamic> committee, int memberCount) {
    final int duration = _integer(committee['duration'], 0);
    final String unit = (committee['unit'] ?? committee['durationUnit'] ?? '')
        .toString()
        .toLowerCase();

    final double months = switch (unit) {
      'year' || 'years' => duration * 12.0,
      'week' || 'weeks' => duration / 4.345,
      'day' || 'days' => duration / 30,
      _ => duration.toDouble(),
    };
    final int configuredRounds = months.ceil();
    if (memberCount == 0) return configuredRounds;
    return configuredRounds < memberCount ? configuredRounds : memberCount;
  }

  List<DateTime?> _memberReceiveDates(
    int memberCount,
    int roundCount,
    DateTime? startDate,
    DateTime? endingDate,
    bool completed,
  ) {
    final List<DateTime?> dates = List<DateTime?>.filled(memberCount, null);
    if (startDate == null || roundCount <= 0) return dates;

    final DateTime today = DateUtils.dateOnly(DateTime.now());
    for (int index = 0; index < memberCount && index < roundCount; index++) {
      final DateTime scheduledDate = _addMonthsClamped(startDate, index);
      final bool roundComplete = completed
          ? endingDate != null && !scheduledDate.isAfter(endingDate)
          : !DateUtils.dateOnly(scheduledDate).isAfter(today);
      if (roundComplete) dates[index] = scheduledDate;
    }

    return dates;
  }

  List<_CommitteeMemberWithDate> _orderedMembers(
    List<Map<String, dynamic>> members,
    List<DateTime?> dates,
  ) {
    final List<_CommitteeMemberWithDate> result = [
      for (int index = 0; index < members.length; index++)
        _CommitteeMemberWithDate(
          member: members[index],
          receiveDate: index < dates.length ? dates[index] : null,
          originalIndex: index,
        ),
    ];

    result.sort((left, right) {
      if (left.receiveDate == null && right.receiveDate == null) {
        return left.originalIndex.compareTo(right.originalIndex);
      }
      if (left.receiveDate == null) return 1;
      if (right.receiveDate == null) return -1;
      final int dateOrder = left.receiveDate!.compareTo(right.receiveDate!);
      return dateOrder != 0
          ? dateOrder
          : left.originalIndex.compareTo(right.originalIndex);
    });
    return result;
  }

  DateTime _addMonthsClamped(DateTime date, int months) {
    final DateTime targetMonth = DateTime(date.year, date.month + months, 1);
    final int lastDay = DateTime(
      targetMonth.year,
      targetMonth.month + 1,
      0,
    ).day;
    return DateTime(
      targetMonth.year,
      targetMonth.month,
      date.day > lastDay ? lastDay : date.day,
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  int _integer(dynamic value, int fallback) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
  }

  String _formatAmount(double amount) {
    final String number = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    final List<String> parts = number.split('.');
    final StringBuffer formatted = StringBuffer();

    for (int index = 0; index < parts.first.length; index++) {
      if (index > 0 && (parts.first.length - index) % 3 == 0) {
        formatted.write(',');
      }
      formatted.write(parts.first[index]);
    }
    if (parts.length > 1) {
      formatted.write('.');
      formatted.write(parts[1]);
    }
    return formatted.toString();
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }
}

class _CommitteeMemberWithDate {
  const _CommitteeMemberWithDate({
    required this.member,
    required this.receiveDate,
    required this.originalIndex,
  });

  final Map<String, dynamic> member;
  final DateTime? receiveDate;
  final int originalIndex;
}

class _CommitteeHistoryDetailView extends StatelessWidget {
  const _CommitteeHistoryDetailView({
    required this.committeeName,
    required this.completed,
    required this.members,
  });

  final String committeeName;
  final bool completed;
  final List<_CommitteeMemberWithDate> members;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color secondaryText = theme.colorScheme.onSurfaceVariant;
    final Color receivedColor = theme.brightness == Brightness.dark
        ? const Color(0xFF81C784)
        : const Color(0xFF218653);

    return Scaffold(
      appBar: AppBar(title: Text('$committeeName History'), centerTitle: true),
      body: members.isEmpty
          ? Center(
              child: Text(
                'No members have been added to this committee yet.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: secondaryText,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: members.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final _CommitteeMemberWithDate entry = members[index];
                final bool received = entry.receiveDate != null;
                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.member['name']?.toString() ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                entry.member['phone']?.toString() ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (received)
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 17,
                              color: receivedColor,
                            ),
                          ),
                        Text(
                          received
                              ? _formatHistoryDate(entry.receiveDate!)
                              : 'Not received yet',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: received ? receivedColor : secondaryText,
                            fontWeight: received
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

String _formatHistoryDate(DateTime date) {
  const List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} '
      '${months[date.month - 1]} ${date.year}';
}
