
import 'dart:math';

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
  final CommitteeController _committeeController =
      CommitteeController.instance;

  static const Color _primaryBlue = Color(0xFF173B67);
  static const Color _backgroundBlue = Color(0xFFF4F7FC);
  static const Color _softBlue = Color(0xFFE8F3FF);
  static const Color _borderBlue = Color(0xFFDCE5F0);
  static const Color _textColor = Color(0xFF243449);

  int _integer(dynamic value, [int fallback = 0]) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor =
        isDark ? const Color(0xFF121212) : _backgroundBlue;
    final Color cardColor = theme.colorScheme.surface;
    final Color primaryTextColor = isDark ? Colors.white : _textColor;
    final Color secondaryTextColor = theme.colorScheme.onSurfaceVariant;
    final Color borderColor =
        isDark ? const Color(0xFF3A3A3A) : _borderBlue;
    final Color accentColor =
        isDark ? const Color(0xFF80CBC4) : _primaryBlue;
    final Color iconBackgroundColor =
        isDark ? const Color(0xFF333333) : _softBlue;

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
          final List<Map<String, dynamic>> committees =
              _committeeController.committees
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
                            'Open a committee to view its schedule and '
                            'select a receiving member.',
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
              ...committees.map((committee) {
                final String id = committee['id']?.toString() ?? '';

                final String name =
                    committee['name']?.toString().trim().isNotEmpty == true
                        ? committee['name'].toString().trim()
                        : 'Committee';

                final List<dynamic> members = committee['members'] is List
                    ? committee['members'] as List<dynamic>
                    : const <dynamic>[];

                final int duration = _integer(
                  committee['duration'] ?? committee['durationMonths'],
                );

                final String unit =
                    (committee['unit'] ??
                            committee['durationUnit'] ??
                            'months')
                        .toString()
                        .toLowerCase();

                final double durationMonths = switch (unit) {
                  'year' || 'years' => duration * 12.0,
                  'week' || 'weeks' => duration / 4.345,
                  'day' || 'days' => duration / 30.0,
                  _ => duration.toDouble(),
                };

                final int rounds =
                    durationMonths > 0 ? durationMonths.ceil() : 0;

                return Padding(
                  key: ValueKey<String>('schedule-card-$id'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: cardColor,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor:
                            theme.colorScheme.onPrimaryContainer,
                        child: const Icon(Icons.groups_rounded),
                      ),
                      title: Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${members.length} '
                        '${members.length == 1 ? 'member' : 'members'}'
                        ' · $rounds ${rounds == 1 ? 'round' : 'rounds'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: secondaryTextColor,
                      ),
                      onTap: id.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      _CommitteeScheduleDetailView(
                                    committee: committee,
                                    controller: _committeeController,
                                    cardColor: cardColor,
                                    primaryTextColor: primaryTextColor,
                                    secondaryTextColor: secondaryTextColor,
                                    borderColor: borderColor,
                                    accentColor: accentColor,
                                    iconBackgroundColor: iconBackgroundColor,
                                  ),
                                ),
                              );
                            },
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ),
    );
  }
}

class _CommitteeScheduleDetailView extends StatelessWidget {
  const _CommitteeScheduleDetailView({
    required this.committee,
    required this.controller,
    required this.cardColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.borderColor,
    required this.accentColor,
    required this.iconBackgroundColor,
  });

  final Map<String, dynamic> committee;
  final CommitteeController controller;
  final Color cardColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color borderColor;
  final Color accentColor;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          committee['name']?.toString().trim().isNotEmpty == true
              ? committee['name'].toString().trim()
              : 'Committee Schedule',
        ),
        foregroundColor: primaryTextColor,
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CommitteeScheduleCard(
            committee: committee,
            controller: controller,
            cardColor: cardColor,
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
            borderColor: borderColor,
            accentColor: accentColor,
            iconBackgroundColor: iconBackgroundColor,
            expandedPage: true,
          ),
        ],
      ),
    );
  }
}

class _CommitteeScheduleCard extends StatefulWidget {
  const _CommitteeScheduleCard({
    required this.committee,
    required this.controller,
    required this.cardColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.borderColor,
    required this.accentColor,
    required this.iconBackgroundColor,
    this.expandedPage = false,
  });

  final Map<String, dynamic> committee;
  final CommitteeController controller;
  final Color cardColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color borderColor;
  final Color accentColor;
  final Color iconBackgroundColor;
  final bool expandedPage;

  @override
  State<_CommitteeScheduleCard> createState() =>
      _CommitteeScheduleCardState();
}

enum _AllocationMode { sequence, spin }

class _CommitteeScheduleCardState extends State<_CommitteeScheduleCard> {
  final Random _random = Random();

  late FixedExtentScrollController _wheelController;

  int _selectedMonthIndex = 0;
  bool _isSpinning = false;

  _AllocationMode _allocationMode = _AllocationMode.sequence;

  final Map<String, String> _selectionOverrides = <String, String>{};

  @override
  void initState() {
    super.initState();

    _allocationMode = widget.committee['allocationMode'] == 'spin'
        ? _AllocationMode.spin
        : _AllocationMode.sequence;

    final List<Map<String, dynamic>> members = _members;
    final List<Map<String, dynamic>> schedule = _createSchedule();

    final String? selectedName = schedule.isEmpty
        ? null
        : schedule.first['memberName']?.toString();

    final int selectedMemberIndex = members.indexWhere(
      (member) => member['name']?.toString().trim() == selectedName,
    );

    _wheelController = FixedExtentScrollController(
      initialItem: selectedMemberIndex < 0 ? 0 : selectedMemberIndex,
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  String get _committeeId => widget.committee['id']?.toString() ?? '';

  String get _committeeName {
    final String name = widget.committee['name']?.toString().trim() ?? '';
    return name.isEmpty ? 'Committee' : name;
  }

  List<Map<String, dynamic>> get _members {
    final dynamic savedMembers = widget.committee['members'];

    if (savedMembers is! List) return [];

    return savedMembers
        .whereType<Map>()
        .map((member) => Map<String, dynamic>.from(member))
        .where(
          (member) =>
              member['name']?.toString().trim().isNotEmpty == true ||
              member['username']?.toString().trim().isNotEmpty == true,
        )
        .toList();
  }

  String _memberName(Map<String, dynamic> member) =>
      member['name']?.toString().trim() ?? '';

  String _memberUsername(Map<String, dynamic> member) {
    final String username = member['username']?.toString().trim() ?? '';

    if (username.isNotEmpty) {
      return username.startsWith('@') ? username : '@$username';
    }

    return _memberName(member);
  }

  List<Map<String, dynamic>> _createSchedule() {
    final List<Map<String, dynamic>> members = _members;
    final DateTime? startDate = _parseDate(widget.committee['startDate']);

    if (members.isEmpty || startDate == null) return [];

    final int duration = _integer(
      widget.committee['duration'] ?? widget.committee['durationMonths'],
    );

    final String unit =
        (widget.committee['unit'] ??
                widget.committee['durationUnit'] ??
                '')
            .toString()
            .toLowerCase();

    final double durationMonths = switch (unit) {
      'year' || 'years' => duration * 12.0,
      'week' || 'weeks' => duration / 4.345,
      'day' || 'days' => duration / 30.0,
      _ => duration.toDouble(),
    };

    if (durationMonths <= 0) return [];

    final int rounds = durationMonths.ceil();

    final int memberCount = _integer(
      widget.committee['memberCount'] ?? widget.committee['membersCount'],
      members.length,
    );

    final double monthlyContribution = _number(
      widget.committee['contribution'] ??
          widget.committee['monthlyContribution'],
    );

    final double pool = monthlyContribution * memberCount;

    return List<Map<String, dynamic>>.generate(rounds, (index) {
      final DateTime date = _addMonthsClamped(startDate, index + 1);

      final String? savedName = _selectionFor(date);

      final Map<String, dynamic> defaultMember =
          members[index % members.length];

      Map<String, dynamic>? savedMember;

      if (savedName != null) {
        for (final Map<String, dynamic> member in members) {
          if (_memberName(member) == savedName ||
              _memberUsername(member) == savedName ||
              _memberUsername(member).replaceFirst('@', '') == savedName) {
            savedMember = member;
            break;
          }
        }
      }

      final Map<String, dynamic> receivingMember =
          savedMember ?? defaultMember;

      return {
        'round': index + 1,
        'isAllocated': savedMember != null,
        'month': '${_monthName(date.month)} ${date.year}',
        'memberName': _memberName(receivingMember),
        'memberUsername': _memberUsername(receivingMember),
        'amount': pool,
        'formattedAmount': _formatAmount(pool),
        'date': date,
        'dueDate': _formatDate(date),
        'status': 'Upcoming',
      };
    });
  }

  String? _selectionFor(DateTime date) {
    final String key = _monthKey(date);
    final String? override = _selectionOverrides[key];

    if (override != null) return override;

    final dynamic rawSelections = widget.committee['receivingSelections'];

    if (rawSelections is! Map) return null;

    return rawSelections[key]?.toString();
  }

  String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  List<Map<String, dynamic>> _availableMembers(
    List<Map<String, dynamic>> schedule,
  ) {
    final Set<String> allocatedNames = schedule
        .where((round) => round['isAllocated'] == true)
        .map((round) => round['memberName'].toString())
        .toSet();

    return _members
        .where((member) => !allocatedNames.contains(_memberName(member)))
        .toList();
  }

  void _selectMonth(
    int? index,
    List<Map<String, dynamic>> schedule,
  ) {
    if (index == null ||
        index < 0 ||
        index >= schedule.length ||
        _isSpinning) {
      return;
    }

    setState(() {
      _selectedMonthIndex = index;
    });

    if (_wheelController.hasClients) {
      _wheelController.jumpToItem(0);
    }
  }

  Future<void> _allocateBySequence(
    List<Map<String, dynamic>> schedule,
  ) async {
    if (_isSpinning || schedule.isEmpty) return;

    if (schedule[_selectedMonthIndex]['isAllocated'] == true) return;

    final List<Map<String, dynamic>> members = _availableMembers(schedule);

    if (members.isEmpty || !_wheelController.hasClients) return;

    await _animateToMember(0, members.length);

    if (!mounted) return;

    _saveReceivingMember(schedule, members.first);
  }

  Future<void> _spinForReceiving(
    List<Map<String, dynamic>> schedule,
  ) async {
    if (schedule.isEmpty || _selectedMonthIndex >= schedule.length) return;

    if (schedule[_selectedMonthIndex]['isAllocated'] == true) return;

    final List<Map<String, dynamic>> members = _availableMembers(schedule);

    if (_isSpinning || members.isEmpty) return;

    if (!_wheelController.hasClients) return;

    final int winnerIndex = _random.nextInt(members.length);

    await _animateToMember(winnerIndex, members.length);

    if (!mounted) return;

    _saveReceivingMember(schedule, members[winnerIndex]);
  }

  Future<void> _animateToMember(
    int winnerIndex,
    int memberCount,
  ) async {
    setState(() {
      _isSpinning = true;
    });

    try {
      final int currentItem = _wheelController.selectedItem;

      final int stepsToWinner =
          (winnerIndex - currentItem % memberCount + memberCount) %
              memberCount;

      await _wheelController.animateToItem(
        currentItem + memberCount + stepsToWinner,
        duration: Duration(
          milliseconds: _allocationMode == _AllocationMode.sequence
              ? 750
              : 1300,
        ),
        curve: Curves.easeOutQuart,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSpinning = false;
        });
      }
    }
  }

  void _saveReceivingMember(
    List<Map<String, dynamic>> schedule,
    Map<String, dynamic> member,
  ) {
    final DateTime date =
        schedule[_selectedMonthIndex]['date'] as DateTime;

    final String name = _memberName(member);

    _selectionOverrides[_monthKey(date)] = name;

    widget.controller.saveReceivingSelectionForCommittee(
      committeeId: _committeeId,
      date: date,
      memberName: name,
    );

    setState(() {});

    Get.snackbar(
      'Committee Allocated',
      '${_memberUsername(member)} is allocated to receive the committee for '
          '${_monthName(date.month)} ${date.year}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: widget.accentColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> schedule = _createSchedule();

    final List<Map<String, dynamic>> displayedSchedule =
        _allocationMode == _AllocationMode.spin
            ? schedule.where((item) => item['isAllocated'] == true).toList()
            : schedule;

    if (_selectedMonthIndex >= schedule.length) {
      _selectedMonthIndex = 0;
    }

    final List<Map<String, dynamic>> members = _members;

    final List<Map<String, dynamic>> availableMembers =
        _availableMembers(schedule);

    final bool selectedRoundAllocated = schedule.isNotEmpty &&
        schedule[_selectedMonthIndex]['isAllocated'] == true;

    final bool canAllocate =
        availableMembers.isNotEmpty && !selectedRoundAllocated;

    final Map<String, dynamic>? selectedSchedule = schedule.isEmpty
        ? null
        : schedule[_selectedMonthIndex];

    return Card(
      margin: EdgeInsets.zero,
      color: widget.cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: widget.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey<String>('committee-schedule-$_committeeId'),
        initiallyExpanded: widget.expandedPage,
        trailing: widget.expandedPage ? const SizedBox.shrink() : null,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.groups_rounded),
        ),
        title: Text(
          _committeeName,
          style: theme.textTheme.titleMedium?.copyWith(
            color: widget.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${members.length} ${members.length == 1 ? 'member' : 'members'}'
          ' · ${schedule.length} '
          '${schedule.length == 1 ? 'round' : 'rounds'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: widget.secondaryTextColor,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (schedule.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                members.isEmpty
                    ? 'Add committee members to create its receiving order.'
                    : 'Set the committee start date and duration to create '
                        'its schedule.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: widget.secondaryTextColor,
                ),
              ),
            )
          else ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Receiving Month',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: widget.primaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _selectedMonthIndex,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: widget.iconBackgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.borderColor),
                ),
              ),
              items: List<DropdownMenuItem<int>>.generate(
                schedule.length,
                (index) => DropdownMenuItem<int>(
                  value: index,
                  child: Text(
                    schedule[index]['month'].toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              onChanged: _isSpinning
                  ? null
                  : (index) => _selectMonth(index, schedule),
            ),
            const SizedBox(height: 16),
            Text(
              'Allocation method',
              style: theme.textTheme.labelLarge?.copyWith(
                color: widget.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<_AllocationMode>(
              segments: const [
                ButtonSegment<_AllocationMode>(
                  value: _AllocationMode.sequence,
                  icon: Icon(Icons.format_list_numbered_rounded),
                  label: Text('Added order'),
                ),
                ButtonSegment<_AllocationMode>(
                  value: _AllocationMode.spin,
                  icon: Icon(Icons.casino_outlined),
                  label: Text('Spin & win'),
                ),
              ],
              selected: <_AllocationMode>{_allocationMode},
              onSelectionChanged: _isSpinning
                  ? null
                  : (selection) {
                      final _AllocationMode mode = selection.first;

                      setState(() {
                        _allocationMode = mode;
                      });

                      widget.controller.setCommitteeAllocationMode(
                        committeeId: _committeeId,
                        mode: mode == _AllocationMode.sequence
                            ? 'sequence'
                            : 'spin',
                      );
                    },
              showSelectedIcon: false,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.white
                      : widget.primaryTextColor,
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => states.contains(WidgetState.selected)
                      ? widget.accentColor
                      : widget.cardColor,
                ),
                side: WidgetStatePropertyAll<BorderSide>(
                  BorderSide(color: widget.borderColor),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _allocationMode == _AllocationMode.sequence
                  ? 'Allocate each round in the order members were added.'
                  : 'Spin the wheel to randomly choose this round’s recipient.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: widget.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.iconBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IgnorePointer(
                    child: Container(
                      height: 58,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.accentColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  if (availableMembers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'All members have already received the committee.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: widget.secondaryTextColor,
                          ),
                        ),
                      ),
                    )
                  else
                    ListWheelScrollView.useDelegate(
                      key: PageStorageKey<String>(
                        'committee-schedule-wheel-$_committeeId-'
                        '${availableMembers.map(_memberName).join('-')}',
                      ),
                      controller: _wheelController,
                      itemExtent: 58,
                      physics: _isSpinning
                          ? const NeverScrollableScrollPhysics()
                          : const FixedExtentScrollPhysics(),
                      perspective: 0.003,
                      diameterRatio: 1.7,
                      childDelegate: ListWheelChildLoopingListDelegate(
                        children: availableMembers
                            .map(
                              (member) => Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Text(
                                    _memberUsername(member),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: widget.primaryTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSpinning || !canAllocate
                    ? null
                    : () => _allocationMode == _AllocationMode.sequence
                        ? _allocateBySequence(schedule)
                        : _spinForReceiving(schedule),
                icon: _isSpinning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _allocationMode == _AllocationMode.sequence
                            ? Icons.check_circle_outline_rounded
                            : Icons.casino_rounded,
                      ),
                label: Text(
                  _isSpinning
                      ? _allocationMode == _AllocationMode.sequence
                          ? 'Allocating...'
                          : 'Spinning...'
                      : _allocationMode == _AllocationMode.sequence
                          ? selectedRoundAllocated
                              ? 'Already allocated'
                              : 'Allocate by added order'
                          : selectedRoundAllocated
                              ? 'Already allocated'
                              : availableMembers.isEmpty
                                  ? 'All members allocated'
                                  : 'Spin & allocate',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (selectedSchedule != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF303030)
                      : const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.borderColor),
                ),
                child: Column(
                  children: [
                    Text(
                      _allocationMode == _AllocationMode.spin &&
                              selectedSchedule['isAllocated'] != true
                          ? 'Spin & allocate a recipient for '
                              '${selectedSchedule['month']}.'
                          : '${selectedSchedule['memberUsername']} is set to '
                              'receive the committee for '
                              '${selectedSchedule['month']}.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      selectedSchedule['formattedAmount'].toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              _allocationMode == _AllocationMode.spin
                  ? 'Allocated Rounds'
                  : 'Monthly Schedule',
              style: theme.textTheme.titleMedium?.copyWith(
                color: widget.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (displayedSchedule.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No recipients have been allocated yet. Use Spin & allocate '
                  'to choose the first recipient.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.secondaryTextColor,
                  ),
                ),
              )
            else
              ...displayedSchedule.map((item) {
                return ScheduleCard(
                  title: '${item['round']}. ${item['month']}',
                  dueDate: '${item['memberUsername']} • ${item['dueDate']}',
                  amount: item['formattedAmount'].toString(),
                  status: item['status'].toString(),
                );
              }),
          ],
        ],
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

    return double.tryParse(
          value?.toString().replaceAll(',', '') ?? '',
        ) ??
        0;
  }

  DateTime _addMonthsClamped(DateTime date, int months) {
    final DateTime firstDay = DateTime(date.year, date.month + months, 1);

    final int lastDay =
        DateTime(firstDay.year, firstDay.month + 1, 0).day;

    return DateTime(
      firstDay.year,
      firstDay.month,
      date.day > lastDay ? lastDay : date.day,
    );
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

  String _formatDate(DateTime date) =>
      '${date.day} ${_monthName(date.month)} ${date.year}';

  String _formatAmount(double amount) {
    final String value = amount.round().toString();
    final StringBuffer result = StringBuffer();

    for (int index = 0; index < value.length; index++) {
      if (index > 0 && (value.length - index) % 3 == 0) {
        result.write(',');
      }

      result.write(value[index]);
    }

    return 'PKR $result';
  }
}
