import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_keys.dart';

/// One stop on the guided tour.
class CoachStep {
  const CoachStep({
    required this.key,
    required this.title,
    required this.body,
    this.radius = 16,
    this.padding = 8,
  });

  /// Attached to the widget this step points at.
  final GlobalKey key;

  final String title;
  final String body;

  /// Corner rounding of the cut-out.
  final double radius;

  /// Breathing room between the widget and the edge of the cut-out.
  final double padding;
}

/// Keys the tour points at.
///
/// They live here rather than inside one screen because the steps span
/// the home screen and the shell around it.
class TourKeys {
  static final balanceCard = GlobalKey();
  static final recentEntries = GlobalKey();
  static final addButton = GlobalKey();
  static final transactionsTab = GlobalKey();
  static final categoriesTab = GlobalKey();
  static final reportsTab = GlobalKey();
  static final menuButton = GlobalKey();
}

/// Runs the tour and remembers that it has been seen.
class CoachMarkController {
  CoachMarkController._();

  static final CoachMarkController instance = CoachMarkController._();

  static const String _seenKey = 'home_tour_seen';

  OverlayEntry? _entry;
  List<CoachStep> _steps = const [];

  /// Drives the overlay. Changing it rebuilds the card in place instead
  /// of tearing the overlay down and inserting a new one.
  final ValueNotifier<int> _index = ValueNotifier<int>(0);

  bool get hasSeenTour {
    if (!Hive.isBoxOpen(AppKeys.settingsBox)) return true;
    return Hive.box(AppKeys.settingsBox).get(_seenKey, defaultValue: false)
        as bool;
  }

  Future<void> _markSeen() async {
    if (!Hive.isBoxOpen(AppKeys.settingsBox)) return;
    await Hive.box(AppKeys.settingsBox).put(_seenKey, true);
  }

  /// Clears the flag so the tour can be watched again.
  Future<void> resetTour() async {
    if (!Hive.isBoxOpen(AppKeys.settingsBox)) return;
    await Hive.box(AppKeys.settingsBox).delete(_seenKey);
  }

  bool get isRunning => _entry != null;

  /// Shows the tour. Pass [force] to run it even when it has been seen,
  /// which is what a "Replay tour" option would use.
  void start(
    BuildContext context,
    List<CoachStep> steps, {
    bool force = false,
  }) {
    if (isRunning || steps.isEmpty) return;
    if (!force && hasSeenTour) return;

    _steps = steps;
    _index.value = 0;

    // Marked here, not when the tour ends. Writing it at the end meant
    // closing the app halfway brought the tour back on the next launch,
    // which is not "only on a fresh install".
    _markSeen();

    // A target that has not been laid out yet has no position, so wait
    // for the first frame before measuring anything.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlay = Overlay.maybeOf(context);
      if (overlay == null) return;

      _entry = OverlayEntry(
        builder: (_) => ValueListenableBuilder<int>(
          valueListenable: _index,
          builder: (_, value, __) => _CoachMarkView(
            steps: _steps,
            index: value,
            onNext: _next,
            onPrevious: _previous,
            onSkip: finish,
          ),
        ),
      );

      overlay.insert(_entry!);
    });
  }

  void _next() {
    if (_index.value >= _steps.length - 1) {
      finish();
      return;
    }

    _index.value++;
  }

  void _previous() {
    if (_index.value == 0) return;
    _index.value--;
  }

  void finish() {
    _entry?.remove();
    _entry = null;
  }
}

// =====================================================================
// THE OVERLAY ITSELF
// =====================================================================
class _CoachMarkView extends StatelessWidget {
  const _CoachMarkView({
    required this.steps,
    required this.index,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  final List<CoachStep> steps;
  final int index;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  Rect? _targetRect() {
    final context = steps[index].key.currentContext;
    if (context == null) return null;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;

    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[index];
    final screen = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    final raw = _targetRect();

    // Nothing to point at (a tab that is not built yet, for instance):
    // show the card centred rather than skipping the step silently.
    final hole = raw == null
        ? null
        : Rect.fromLTRB(
            raw.left - step.padding,
            raw.top - step.padding,
            raw.right + step.padding,
            raw.bottom + step.padding,
          );

    const cardHeight = 186.0;
    const gap = 14.0;

    double cardTop;
    if (hole == null) {
      cardTop = (screen.height - cardHeight) / 2;
    } else if (hole.bottom + gap + cardHeight <
        screen.height - safeBottom - 12) {
      cardTop = hole.bottom + gap;
    } else {
      cardTop = hole.top - gap - cardHeight;
    }

    cardTop = cardTop.clamp(safeTop + 12, screen.height - cardHeight - 12);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dim everything except the target.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onNext,
              child: CustomPaint(
                painter: _HolePainter(hole: hole, radius: step.radius),
              ),
            ),
          ),

          // A soft ring so the highlighted area reads as deliberate.
          if (hole != null)
            Positioned(
              left: hole.left,
              top: hole.top,
              width: hole.width,
              height: hole.height,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(step.radius),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.55),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            left: 16,
            right: 16,
            top: cardTop,
            child: _StepCard(
              step: step,
              index: index,
              total: steps.length,
              onNext: onNext,
              onPrevious: onPrevious,
              onSkip: onSkip,
            ),
          ),
        ],
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  _HolePainter({required this.hole, required this.radius});

  final Rect? hole;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final dim = Paint()..color = Colors.black.withOpacity(0.72);
    final full = Rect.fromLTWH(0, 0, size.width, size.height);

    if (hole == null) {
      canvas.drawRect(full, dim);
      return;
    }

    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(full),
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(hole!, Radius.circular(radius)),
        ),
    );

    canvas.drawPath(path, dim);
  }

  @override
  bool shouldRepaint(_HolePainter old) =>
      old.hole != hole || old.radius != radius;
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.index,
    required this.total,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
  });

  final CoachStep step;
  final int index;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = index == total - 1;

    const green = Color(0xFF2EA44F);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
              Text(
                '${index + 1} of $total',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            step.body,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              if (!isLast)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        isDark ? Colors.white60 : Colors.black54,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Skip'),
                ),

              const Spacer(),

              if (index > 0)
                OutlinedButton(
                  onPressed: onPrevious,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: green,
                    side: const BorderSide(color: green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: const Text('Back'),
                ),

              const SizedBox(width: 8),

              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                ),
                child: Text(isLast ? 'Got it' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// THE TOUR ITSELF
// =====================================================================

/// The seven stops, written for Expense Mate.
List<CoachStep> expenseMateTour() => [
      CoachStep(
        key: TourKeys.balanceCard,
        title: 'Your balance',
        body: 'Everything you have, minus everything you have spent. '
            'The income and expense figures below it cover this month '
            'only.',
        radius: 20,
      ),
      CoachStep(
        key: TourKeys.recentEntries,
        title: 'Recent transactions',
        body: 'The last few entries you recorded, newest first. Tap one '
            'to open or change it.',
      ),
      CoachStep(
        key: TourKeys.addButton,
        title: 'Add a transaction',
        body: 'Record money in or out. Choose a category and wallet, and '
            'the balance updates by itself.',
        radius: 40,
        padding: 10,
      ),
      CoachStep(
        key: TourKeys.transactionsTab,
        title: 'Transactions',
        body: 'Your full record. Search it, edit an entry, or delete one '
            'or several together.',
        radius: 12,
      ),
      CoachStep(
        key: TourKeys.categoriesTab,
        title: 'Categories',
        body: 'Decide how your spending is sorted. Tap any category to '
            'see just its transactions.',
        radius: 12,
      ),
      CoachStep(
        key: TourKeys.reportsTab,
        title: 'Reports',
        body: 'Where the money actually went: income against expense, a '
            'breakdown by category, and the trend over six months.',
        radius: 12,
      ),
      CoachStep(
        key: TourKeys.menuButton,
        title: 'Everything else',
        body: 'Wallets, budgets, savings goals, bill reminders and your '
            'committee all live behind this menu.',
        radius: 12,
      ),
    ];