import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../settings/controller/settings_controller.dart';
import '../controller/udhaar_controller.dart';
import '../model/udhaar_model.dart';

const Color _green = Color(0xFF2EA44F);
const Color _red = Color(0xFFE53935);

class UdhaarView extends GetView<UdhaarController> {
  const UdhaarView({super.key});

  static String _money(num value) {
    final digits = value.abs().round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  static String get _symbol {
    if (!Get.isRegistered<SettingsController>()) return 'Rs';
    return Get.find<SettingsController>().selectedCurrency.value;
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _date(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background =
        isDark ? const Color(0xFF101010) : const Color(0xFFF6F7F2);
    final card = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final primaryText = isDark ? Colors.white : const Color(0xFF1E1E1E);
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
          'Udhaar',
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEntrySheet(context, isDark),
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add udhaar'),
      ),

      body: Obx(() {
        final people = controller.visiblePeople;

        return Column(
          children: [
            _summary(isDark, secondaryText),
            _filters(isDark, secondaryText),

            Expanded(
              child: people.isEmpty
                  ? _empty(primaryText, secondaryText)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: people.length,
                      itemBuilder: (context, i) => _personCard(
                        context,
                        people[i],
                        card,
                        isDark,
                        primaryText,
                        secondaryText,
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  // =================================================================
  // SUMMARY
  // =================================================================
  Widget _summary(bool isDark, Color secondaryText) {
    final receive = controller.totalToReceive;
    final pay = controller.totalToPay;
    final net = controller.netBalance;
    final positive = net >= 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: positive
              ? const [Color(0xFF34A853), Color(0xFF1B5E20)]
              : const [Color(0xFFEF5350), Color(0xFFB71C1C)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            positive ? 'You will receive overall' : 'You owe overall',
            style: const TextStyle(fontSize: 12.5, color: Colors.white70),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '$_symbol ${_money(net)}',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _summaryCell(
                  'To receive',
                  '$_symbol ${_money(receive)}',
                  Icons.south_west_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white24,
              ),
              Expanded(
                child: _summaryCell(
                  'To pay',
                  '$_symbol ${_money(pay)}',
                  Icons.north_east_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCell(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: Colors.white70),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // FILTERS
  // =================================================================
  Widget _filters(bool isDark, Color secondaryText) {
    const options = [
      (UdhaarFilter.all, 'All'),
      (UdhaarFilter.toReceive, 'To receive'),
      (UdhaarFilter.toPay, 'To pay'),
      (UdhaarFilter.settled, 'Settled'),
    ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: options.map((option) {
          final active = controller.filter.value == option.$1;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => controller.setFilter(option.$1),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: active
                      ? _green
                      : (isDark
                          ? const Color(0xFF1F1F1F)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active
                        ? _green
                        : (isDark ? Colors.white12 : Colors.black12),
                  ),
                ),
                child: Text(
                  option.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : secondaryText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =================================================================
  // PERSON CARD
  // =================================================================
  Widget _personCard(
    BuildContext context,
    UdhaarPerson person,
    Color card,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final clear = person.isClear;
    final accent = clear
        ? secondaryText
        : (person.theyOweYou ? _green : _red);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),

          leading: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withOpacity(isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              person.name.isEmpty
                  ? '?'
                  : person.name.characters.first.toUpperCase(),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),

          title: Text(
            person.name,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: primaryText,
            ),
          ),

          subtitle: Text(
            clear
                ? 'Settled'
                : '${person.openCount} open '
                    '${person.openCount == 1 ? 'entry' : 'entries'}',
            style: TextStyle(fontSize: 11.5, color: secondaryText),
          ),

          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                clear ? '—' : '$_symbol ${_money(person.net)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              if (!clear)
                Text(
                  person.theyOweYou ? 'you get' : 'you give',
                  style: TextStyle(fontSize: 10.5, color: secondaryText),
                ),
            ],
          ),

          children: [
            ...controller.entriesFor(person.name).map(
                  (entry) => _entryRow(
                    context,
                    entry,
                    isDark,
                    primaryText,
                    secondaryText,
                  ),
                ),

            const SizedBox(height: 6),

            Row(
              children: [
                if (!clear)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _confirmSettleAll(context, person, isDark),
                      icon: const Icon(Icons.done_all_rounded, size: 17),
                      label: const Text('Settle all'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _green,
                        side: const BorderSide(color: _green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                if (!clear) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openEntrySheet(
                      context,
                      isDark,
                      presetName: person.name,
                      presetPhone: person.phone,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 17),
                    label: const Text('Add'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: secondaryText,
                      side: BorderSide(
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryRow(
    BuildContext context,
    UdhaarEntry entry,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final accent = entry.isLent ? _green : _red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            entry.isLent
                ? Icons.south_west_rounded
                : Icons.north_east_rounded,
            size: 16,
            color: entry.isSettled ? secondaryText : accent,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.note.isEmpty
                      ? (entry.isLent ? 'You gave' : 'You took')
                      : entry.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                    decoration: entry.isSettled
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                Text(
                  _date(entry.date),
                  style: TextStyle(fontSize: 11, color: secondaryText),
                ),
              ],
            ),
          ),

          Text(
            '$_symbol ${_money(entry.amount)}',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: entry.isSettled ? secondaryText : accent,
              decoration:
                  entry.isSettled ? TextDecoration.lineThrough : null,
            ),
          ),

          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: secondaryText,
            ),
            color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'settle') {
                controller.toggleSettled(entry.id);
              } else if (value == 'delete') {
                controller.deleteEntry(entry.id);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: 'settle',
                child: Text(
                  entry.isSettled ? 'Mark as open' : 'Mark as settled',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text(
                  'Delete',
                  style: TextStyle(color: _red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =================================================================
  // EMPTY
  // =================================================================
  Widget _empty(Color primaryText, Color secondaryText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _green.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.handshake_outlined,
                size: 42,
                color: _green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nothing here yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Record money you lent to someone, or took from them, '
              'and the balance with each person is kept for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.6,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // ADD SHEET
  // =================================================================
  void _openEntrySheet(
    BuildContext context,
    bool isDark, {
    String presetName = '',
    String presetPhone = '',
  }) {
    final nameController = TextEditingController(text: presetName);
    final phoneController = TextEditingController(text: presetPhone);
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    final isLent = true.obs;
    final date = DateTime.now().obs;
    final error = RxnString();

    final fieldFill =
        isDark ? Colors.white10 : Colors.black.withOpacity(0.04);
    final primaryText = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final secondaryText =
        isDark ? Colors.white70 : const Color(0xFF6B7280);

    InputDecoration decoration(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: secondaryText.withOpacity(0.7),
            fontSize: 14,
          ),
          filled: true,
          fillColor: fieldFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _green, width: 1.4),
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF151515) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: secondaryText.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'New udhaar',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        color: secondaryText,
                      ),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ------------------------------------- direction
                Obx(() {
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: fieldFill,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _directionTab(
                          label: 'I gave',
                          caption: 'they owe me',
                          active: isLent.value,
                          colour: _green,
                          secondaryText: secondaryText,
                          onTap: () => isLent.value = true,
                        ),
                        _directionTab(
                          label: 'I took',
                          caption: 'I owe them',
                          active: !isLent.value,
                          colour: _red,
                          secondaryText: secondaryText,
                          onTap: () => isLent.value = false,
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 14),

                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: primaryText),
                  decoration: decoration('Person name'),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: primaryText),
                  decoration: decoration('Amount').copyWith(
                    prefixText: '$_symbol ',
                    prefixStyle: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: primaryText),
                  decoration: decoration('Phone (optional)'),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: noteController,
                  style: TextStyle(color: primaryText),
                  decoration: decoration('Note (optional)'),
                ),

                const SizedBox(height: 10),

                Obx(() {
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: sheetContext,
                        initialDate: date.value,
                        firstDate: DateTime(2015),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365),
                        ),
                      );

                      if (picked != null) date.value = picked;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: fieldFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 17,
                            color: secondaryText,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _date(date.value),
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                Obx(() {
                  if (error.value == null) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      error.value!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _red,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final amount = double.tryParse(
                        amountController.text.trim().replaceAll(',', ''),
                      );

                      if (name.isEmpty) {
                        error.value = 'Please enter the person name.';
                        return;
                      }

                      if (amount == null || amount <= 0) {
                        error.value = 'Please enter a valid amount.';
                        return;
                      }

                      await controller.addEntry(
                        personName: name,
                        amount: amount,
                        isLent: isLent.value,
                        date: date.value,
                        phone: phoneController.text,
                        note: noteController.text,
                      );

                      Navigator.pop(sheetContext);
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
                      'Save',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _directionTab({
    required String label,
    required String caption,
    required bool active,
    required Color colour,
    required Color secondaryText,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? colour : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : secondaryText,
                ),
              ),
              Text(
                caption,
                style: TextStyle(
                  fontSize: 10.5,
                  color: active ? Colors.white70 : secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSettleAll(
    BuildContext context,
    UdhaarPerson person,
    bool isDark,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Text(
          'Settle with ${person.name}?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        content: Text(
          'Every open entry with ${person.name} will be marked as '
          'settled. Nothing is deleted, so you can reopen any of them '
          'later.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark ? Colors.white70 : const Color(0xFF4B5563),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
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
            onPressed: () {
              Get.back();
              controller.settlePerson(person.name);
            },
            child: const Text('Settle'),
          ),
        ],
      ),
    );
  }
}
