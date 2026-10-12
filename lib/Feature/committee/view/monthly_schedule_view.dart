import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/committe_controller.dart';
import '../widgets/schedule_card.dart';

class MonthlyScheduleView extends StatefulWidget {
  final double monthlyContribution;
  final int totalMembers;
  final int durationMonths;
  final DateTime startDate;

  const MonthlyScheduleView({
    super.key,
    required this.monthlyContribution,
    required this.totalMembers,
    required this.durationMonths,
    required this.startDate,
  });

  @override
  State<MonthlyScheduleView> createState() => _MonthlyScheduleViewState();
}

class _MonthlyScheduleViewState extends State<MonthlyScheduleView> {
  static const Color primaryBlue = Color(0xFF173B67);
  static const Color backgroundBlue = Color(0xFFF4F7FC);
  static const Color softBlue = Color(0xFFE8F3FF);
  static const Color borderBlue = Color(0xFFDCE5F0);
  static const Color textColor = Color(0xFF243449);

  List<Map<String, dynamic>> _membersFor(Map<String, dynamic> committee) {
    final dynamic savedMembers = committee['members'];
    if (savedMembers is! List) return [];

    return savedMembers
        .whereType<Map>()
        .map((member) => Map<String, dynamic>.from(member))
        .where((member) => member['name']?.toString().trim().isNotEmpty == true)
        .toList();
  }

  List<Map<String, String>> _createSchedule(Map<String, dynamic> committee) {
    final List<Map<String, dynamic>> members = _membersFor(committee);
    final DateTime? startDate = _parseDate(committee['startDate']);
    if (members.isEmpty || startDate == null) return [];

    final int duration = _integer(committee['duration']);
    final String unit = (committee['unit'] ?? committee['durationUnit'] ?? '')
        .toString()
        .toLowerCase();
    final double durationMonths = switch (unit) {
      'year' || 'years' => duration * 12.0,
      'week' || 'weeks' => duration / 4.345,
      'day' || 'days' => duration / 30,
      _ => duration.toDouble(),
    };
    if (durationMonths <= 0) return [];

    final int rounds = durationMonths.ceil() < members.length
        ? durationMonths.ceil()
        : members.length;
    final double contribution = _number(committee['contribution']);
    final int memberCount = _integer(
      committee['memberCount'] ?? committee['membersCount'],
      members.length,
    );
    final double committeeAmount = contribution * memberCount;
    final DateTime today = DateUtils.dateOnly(DateTime.now());

    return List<Map<String, String>>.generate(rounds, (index) {
      final DateTime receivingDate = _addMonthsClamped(startDate, index);
      final Map<String, dynamic> member = members[index];
      return {
        'month': '${_monthName(receivingDate.month)} ${receivingDate.year}',
        'memberName': member['name'].toString().trim(),
        'dueDate': _formatDate(receivingDate),
        'amount': _formatAmount(committeeAmount),
        'status': DateUtils.dateOnly(receivingDate).isAfter(today)
            ? 'Upcoming'
            : 'Scheduled',
      };
    });
  }

  Widget _buildCommitteeCard({
    required BuildContext context,
    required Map<String, dynamic> committee,
    required Color cardColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color borderColor,
    required Color accentColor,
  }) {
    final ThemeData theme = Theme.of(context);
    final List<Map<String, String>> schedule = _createSchedule(committee);
    final String committeeName =
        committee['name']?.toString().trim().isNotEmpty == true
        ? committee['name'].toString().trim()
        : 'Committee';
    final List<Map<String, dynamic>> members = _membersFor(committee);

    return Card(
      margin: EdgeInsets.zero,
      color: cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey<String>(
          'monthly-schedule-${committee['id'] ?? committeeName}',
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.groups_rounded),
        ),
        title: Text(
          committeeName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: primaryTextColor,
          ),
        ),
        subtitle: Text(
          '${members.length} ${members.length == 1 ? 'member' : 'members'}'
          ' · ${schedule.length} ${schedule.length == 1 ? 'round' : 'rounds'}',
          style: theme.textTheme.bodySmall?.copyWith(color: secondaryTextColor),
        ),
        children: [
          if (schedule.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Text(
                members.isEmpty
                    ? 'Add members to see the receiving order.'
                    : 'Set a start date and duration to create the schedule.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            )
          else
            ...List.generate(schedule.length, (index) {
              final Map<String, String> item = schedule[index];
              return ScheduleCard(
                title: '${index + 1}. ${item['month']!}',
                dueDate: '${item['memberName']!} • ${item['dueDate']!}',
                amount: item['amount']!,
                status: item['status']!,
              );
            }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildScreen(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? const Color(0xFF121212)
        : backgroundBlue;
    final Color cardColor = theme.colorScheme.surface;
    final Color primaryTextColor = isDark ? Colors.white : textColor;
    final Color secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    final Color borderColor = isDark ? const Color(0xFF3A3A3A) : borderBlue;
    final Color accentColor = isDark ? const Color(0xFF80CBC4) : primaryBlue;
    final Color iconBackgroundColor = isDark
        ? const Color(0xFF333333)
        : softBlue;
    final CommitteeController controller = CommitteeController.instance;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_rounded, color: accentColor),
            const SizedBox(width: 8),
            Text(
              'Monthly Schedule',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        foregroundColor: primaryTextColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Obx(() {
          final List<Map<String, dynamic>> committees = controller.committees
              .map((committee) => Map<String, dynamic>.from(committee))
              .toList();

          if (committees.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Add a committee to see its monthly schedule.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.16 : 0.035,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        size: 28,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receiving Order',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Tap a committee to see who receives it in '
                            'each numbered round.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.45,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Committees',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),
              ...committees.map(
                (committee) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCommitteeCard(
                    context: context,
                    committee: committee,
                    cardColor: cardColor,
                    primaryTextColor: primaryTextColor,
                    secondaryTextColor: secondaryTextColor,
                    borderColor: borderColor,
                    accentColor: accentColor,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  int _integer(dynamic value, [int fallback = 0]) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
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

  String _formatDate(DateTime date) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _monthName(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatAmount(double amount) {
    final String value = amount.round().toString();
    final StringBuffer formatted = StringBuffer('PKR ');
    for (int index = 0; index < value.length; index++) {
      if (index > 0 && (value.length - index) % 3 == 0) {
        formatted.write(',');
      }
      formatted.write(value[index]);
    }
    return formatted.toString();
  }

  @override
  Widget build(BuildContext context) => _buildScreen(context);
}
