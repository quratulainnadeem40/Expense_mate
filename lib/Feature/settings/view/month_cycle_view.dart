import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../Core/constants/app_keys.dart';
import '../../Budgets/controller/budget_controller.dart';

const Color _green = Color(0xFF2EA44F);

/// One place to manage both month cycles.
///
/// They used to be set from the Budgets and Categories screens, which
/// meant the same kind of setting lived in two unrelated corners of the
/// app. Both now sit here, one per tab.
class MonthCycleView extends StatefulWidget {
  const MonthCycleView({super.key});

  @override
  State<MonthCycleView> createState() => _MonthCycleViewState();
}

class _MonthCycleViewState extends State<MonthCycleView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background =
        isDark ? const Color(0xFF101010) : const Color(0xFFF6F7F2);
    final primaryText = isDark ? Colors.white : const Color(0xFF1C1C1C);
    final secondaryText =
        isDark ? Colors.white70 : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: primaryText),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Month Cycle',
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          labelColor: _green,
          unselectedLabelColor: secondaryText,
          indicatorColor: _green,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Budget'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _CategoryCycleTab(),
          _BudgetCycleTab(),
        ],
      ),
    );
  }
}

// =====================================================================
// SHARED PIECES
// =====================================================================

/// "1st of every month" rather than "1th".
String _ordinal(int day) {
  if (day >= 11 && day <= 13) return '${day}th';

  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fullDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// February has no 31st, so a chosen day is pulled back to the last day
/// the month actually has.
int _clampDay(int year, int month, int day) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return day > lastDay ? lastDay : day;
}

DateTime _nextResetFrom(DateTime start, int day) {
  final startDate = DateTime(start.year, start.month, start.day);

  final thisMonth = DateTime(
    start.year,
    start.month,
    _clampDay(start.year, start.month, day),
  );

  if (thisMonth.isAfter(startDate)) return thisMonth;

  final next = DateTime(start.year, start.month + 1, 1);
  return DateTime(
    next.year,
    next.month,
    _clampDay(next.year, next.month, day),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
            ),
          ),
          child: child,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Grid of 1 to 31.
class _DayGrid extends StatelessWidget {
  const _DayGrid({required this.selected, required this.onPick});

  final int selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(31, (i) {
        final day = i + 1;
        final active = day == selected;

        return GestureDetector(
          onTap: () => onPick(day),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? _green
                  : (isDark
                      ? const Color(0xFF242424)
                      : const Color(0xFFF1F4F0)),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.automatic, required this.onChanged});

  final bool automatic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget tab(String label, bool value) {
      final active = automatic == value;

      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? _green : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202020) : const Color(0xFFEAEFEA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [tab('Automatic', true), tab('Manual', false)]),
    );
  }
}

class _DatePair extends StatelessWidget {
  const _DatePair({required this.last, required this.next});

  final String last;
  final String next;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = isDark ? Colors.white70 : Colors.black54;

    Widget cell(String title, String value) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: label)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2B82FB),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [cell('Last reset', last), cell('Next reset', next)],
    );
  }
}

Future<bool> _confirmReset(BuildContext context, String what) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final result = await Get.dialog<bool>(
    AlertDialog(
      backgroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Start a new month?'),
      content: Text(
        'Your $what totals go back to zero and today becomes the new '
        'start day, so every month after this turns over on this date.'
        '\n\nNothing is deleted: your transactions stay as they are.',
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: isDark ? Colors.white70 : const Color(0xFF4B5563),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Get.back(result: true),
          child: const Text('Reset now'),
        ),
      ],
    ),
  );

  return result ?? false;
}

// =====================================================================
// BUDGET TAB
// =====================================================================
class _BudgetCycleTab extends StatelessWidget {
  const _BudgetCycleTab();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BudgetController>()) {
      Get.put(BudgetController());
    }

    final controller = Get.find<BudgetController>();

    return Obx(() {
      final day = controller.monthStartDay.value;
      final automatic = controller.isAutomaticReset.value;

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        children: [
          _Section(
            title: 'Month start',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_ordinal(day)} of every month',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: _green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Budget runs ${controller.cycleLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 14),
                _DayGrid(
                  selected: day,
                  onPick: controller.setMonthStartDay,
                ),
                if (day > 28) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Shorter months will start on their last day instead.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          _Section(
            title: 'Reset mode',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ModeToggle(
                  automatic: automatic,
                  onChanged: controller.setAutomaticReset,
                ),
                const SizedBox(height: 12),
                Text(
                  automatic
                      ? 'Budget resets on its own each cycle.'
                      : 'Budget will not reset automatically.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 16),
                _DatePair(
                  last: _fullDate(
                    controller.lastResetDate.value ??
                        controller.cycleStartDay,
                  ),
                  next: _fullDate(controller.nextResetDate),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                if (await _confirmReset(context, 'budget')) {
                  await controller.performReset();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Reset budget now',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// =====================================================================
// CATEGORY TAB
// =====================================================================
class _CategoryCycleTab extends StatefulWidget {
  const _CategoryCycleTab();

  @override
  State<_CategoryCycleTab> createState() => _CategoryCycleTabState();
}

class _CategoryCycleTabState extends State<_CategoryCycleTab> {
  Box get _box => Hive.box(AppKeys.budgetBox);

  int get _day {
    final stored = _box.get(AppKeys.categoryCycleStartDayKey);
    return stored is int && stored >= 1 && stored <= 31 ? stored : 1;
  }

  bool get _automatic {
    final stored = _box.get(AppKeys.categoryCycleAutomaticResetKey);
    return stored is bool ? stored : true;
  }

  DateTime get _lastReset {
    final raw = _box.get(AppKeys.categoryCycleManualResetKey);
    final parsed = raw is String ? DateTime.tryParse(raw) : null;
    if (parsed != null) return parsed;

    // Never reset by hand: fall back to the most recent start day that
    // has already gone by.
    final now = DateTime.now();
    final thisMonth =
        DateTime(now.year, now.month, _clampDay(now.year, now.month, _day));

    if (!now.isBefore(thisMonth)) return thisMonth;

    final prev = DateTime(now.year, now.month - 1, 1);
    return DateTime(
      prev.year,
      prev.month,
      _clampDay(prev.year, prev.month, _day),
    );
  }

  Future<void> _setDay(int day) async {
    await _box.put(AppKeys.categoryCycleStartDayKey, day);
    if (mounted) setState(() {});
  }

  Future<void> _setMode(bool automatic) async {
    await _box.put(AppKeys.categoryCycleAutomaticResetKey, automatic);
    if (mounted) setState(() {});
  }

  Future<void> _resetNow() async {
    final now = DateTime.now();

    // Same rule as the budget: a reset by hand moves the start day.
    await _box.put(AppKeys.categoryCycleStartDayKey, now.day);
    await _box.put(AppKeys.categoryCycleManualResetKey, now.toIso8601String());

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final day = _day;
    final last = _lastReset;
    final next = _nextResetFrom(last, day);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
      children: [
        _Section(
          title: 'Month start',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_ordinal(day)} of every month',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Category totals run '
                '${last.day} ${_months[last.month - 1]} - '
                '${next.subtract(const Duration(days: 1)).day} '
                '${_months[next.subtract(const Duration(days: 1)).month - 1]}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 14),
              _DayGrid(selected: day, onPick: _setDay),
              if (day > 28) ...[
                const SizedBox(height: 10),
                Text(
                  'Shorter months will start on their last day instead.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ],
          ),
        ),

        _Section(
          title: 'Reset mode',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ModeToggle(automatic: _automatic, onChanged: _setMode),
              const SizedBox(height: 12),
              Text(
                _automatic
                    ? 'Category totals reset on their own each cycle.'
                    : 'Category totals will not reset automatically.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 16),
              _DatePair(last: _fullDate(last), next: _fullDate(next)),
            ],
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () async {
              if (await _confirmReset(context, 'category')) {
                await _resetNow();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Reset categories now',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
