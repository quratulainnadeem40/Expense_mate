
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/committe_controller.dart';

class CommitteeDetailsView extends StatefulWidget {
  final bool membersOnly;

  const CommitteeDetailsView({
    super.key,
    this.membersOnly = false,
  });

  @override
  State<CommitteeDetailsView> createState() =>
      _CommitteeDetailsViewState();
}

class _CommitteeDetailsViewState
    extends State<CommitteeDetailsView> {
  final CommitteeController committeeController =
      CommitteeController.instance;

  // --------------------------------------------------
  // THEME COLORS
  // --------------------------------------------------

  static const Color lightBackground = Color(0xFFF5F6F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF252B35);
  static const Color lightSecondary = Color(0xFF626B78);
  static const Color lightBorder = Color(0xFFDDE1E7);

  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCard = Color(0xFF202124);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkSecondary = Color(0xFFBDBDBD);
  static const Color darkBorder = Color(0xFF383838);

  static const Color greenAccent = Color(0xFF27845D);
  static const Color lightGreen = Color(0xFFE5F4EC);
  static const Color darkGreen = Color(0xFF20352C);

  static const Color amberAccent = Color(0xFFB7791F);
  static const Color lightAmber = Color(0xFFFFF3D6);
  static const Color darkAmber = Color(0xFF3A3020);

  static const Color purpleAccent = Color(0xFF8056B3);
  static const Color lightPurple = Color(0xFFF0E9FA);
  static const Color darkPurple = Color(0xFF302640);

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get screenBackground =>
      isDark ? darkBackground : lightBackground;

  Color get cardBackground =>
      isDark ? darkCard : lightCard;

  Color get primaryText =>
      isDark ? darkText : lightText;

  Color get secondaryText =>
      isDark ? darkSecondary : lightSecondary;

  Color get outlineColor =>
      isDark ? darkBorder : lightBorder;

  Color get greenBackground =>
      isDark ? darkGreen : lightGreen;

  Color get amberBackground =>
      isDark ? darkAmber : lightAmber;

  Color get purpleBackground =>
      isDark ? darkPurple : lightPurple;

  Color get greenText =>
      isDark ? const Color(0xFF7DD6A8) : greenAccent;

  Color get amberText =>
      isDark ? const Color(0xFFFFD180) : amberAccent;

  Color get purpleText =>
      isDark ? const Color(0xFFC7A7F4) : purpleAccent;

  Color get primaryAccent =>
      isDark ? const Color(0xFF7DD6A8) : greenAccent;

  ThemeData get dialogTheme {
    return Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: primaryAccent,
            surface: cardBackground,
            onSurface: primaryText,
          ),
      scaffoldBackgroundColor: screenBackground,
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: secondaryText),
        hintStyle: TextStyle(color: secondaryText),
        prefixStyle: TextStyle(color: primaryText),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryAccent,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.6,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HELPERS
  // --------------------------------------------------

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String _formatAmount(double amount) =>
      'PKR ${amount.toStringAsFixed(0)}';

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not Set';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  DateTime _calculateEndingDate({
    required DateTime startDate,
    required int duration,
    required String unit,
  }) {
    final String normalizedUnit = unit.toLowerCase().trim();

    if (normalizedUnit == 'day' || normalizedUnit == 'days') {
      return startDate.add(Duration(days: duration));
    }

    if (normalizedUnit == 'week' || normalizedUnit == 'weeks') {
      return startDate.add(Duration(days: duration * 7));
    }

    if (normalizedUnit == 'month' ||
        normalizedUnit == 'months') {
      final int totalMonths =
          startDate.year * 12 + startDate.month - 1 + duration;
      final int year = totalMonths ~/ 12;
      final int month = totalMonths % 12 + 1;
      final int lastDay = DateTime(year, month + 1, 0).day;

      return DateTime(
        year,
        month,
        startDate.day > lastDay ? lastDay : startDate.day,
      );
    }

    if (normalizedUnit == 'year' || normalizedUnit == 'years') {
      final int year = startDate.year + duration;
      final int lastDay =
          DateTime(year, startDate.month + 1, 0).day;

      return DateTime(
        year,
        startDate.month,
        startDate.day > lastDay ? lastDay : startDate.day,
      );
    }

    return startDate.add(Duration(days: duration * 30));
  }

  double get _totalPayment =>
      committeeController.totalDurationAmount;

  double get _receivedPayment {
    return committeeController.payments.fold<double>(
      0,
      (total, payment) {
        if ((payment['status']?.toString().toLowerCase() ?? '') ==
            'received') {
          return total + _toDouble(payment['amount']);
        }
        return total;
      },
    );
  }

  double get _remainingPayment =>
      (_totalPayment - _receivedPayment)
          .clamp(0.0, double.infinity);

  // --------------------------------------------------
  // SUMMARY CARD
  // --------------------------------------------------

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    Color? accentColor,
    Color? cardColor,
  }) {
    final Color accent = accentColor ?? primaryAccent;

    return Expanded(
      child: Card(
        color: cardColor ?? cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 1 : 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: outlineColor),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 23,
                color: accent,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: primaryText,
      ),
    );
  }

  // --------------------------------------------------
  // COMMITTEE SUMMARY
  // --------------------------------------------------

  Widget _buildCommitteeSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Committee Summary'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(
              icon: Icons.payments_outlined,
              title: 'Monthly Contribution',
              value: _formatAmount(
                committeeController.monthlyContribution.value,
              ),
              accentColor: greenText,
              cardColor: greenBackground,
            ),
            const SizedBox(width: 10),
            _buildSummaryCard(
              icon: Icons.groups_outlined,
              title: 'Members',
              value: '${committeeController.totalMembers.value}',
              accentColor: purpleText,
              cardColor: purpleBackground,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Total Pool',
              value: _formatAmount(committeeController.totalPool),
              accentColor: greenText,
              cardColor: greenBackground,
            ),
            const SizedBox(width: 10),
            _buildSummaryCard(
              icon: Icons.calendar_month_outlined,
              title: 'Duration',
              value: '${committeeController.duration.value} '
                  '${committeeController.durationUnit.value}',
              accentColor: amberText,
              cardColor: amberBackground,
            ),
          ],
        ),
      ],
    );
  }

  // --------------------------------------------------
  // PAYMENT SUMMARY
  // --------------------------------------------------

  Widget _buildPaymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Payment Summary'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(
              icon: Icons.receipt_long_outlined,
              title: 'Total Payment',
              value: _formatAmount(_totalPayment),
              accentColor: purpleText,
              cardColor: purpleBackground,
            ),
            const SizedBox(width: 8),
            _buildSummaryCard(
              icon: Icons.check_circle_outline,
              title: 'Received',
              value: _formatAmount(_receivedPayment),
              accentColor: greenText,
              cardColor: greenBackground,
            ),
            const SizedBox(width: 8),
            _buildSummaryCard(
              icon: Icons.pending_actions_outlined,
              title: 'Remaining',
              value: _formatAmount(_remainingPayment),
              accentColor: amberText,
              cardColor: amberBackground,
            ),
          ],
        ),
      ],
    );
  }

  // --------------------------------------------------
  // EDIT COMMITTEE
  // --------------------------------------------------

  Future<void> _showEditCommitteeDialog() async {
    final TextEditingController nameController =
        TextEditingController(
      text: committeeController.committeeName.value,
    );

    final TextEditingController contributionController =
        TextEditingController(
      text: committeeController.monthlyContribution.value
          .toStringAsFixed(0),
    );

    final TextEditingController membersController =
        TextEditingController(
      text: committeeController.totalMembers.value.toString(),
    );

    final TextEditingController durationController =
        TextEditingController(
      text: committeeController.duration.value.toString(),
    );

    final List<String> units = [
      'Months',
      'Years',
      'Weeks',
      'Days',
    ];

    String selectedUnit = units.firstWhere(
      (unit) =>
          unit.toLowerCase() ==
          committeeController.durationUnit.value.toLowerCase(),
      orElse: () => 'Months',
    );

    DateTime selectedStartDate =
        committeeController.startDate.value ?? DateTime.now();

    final GlobalKey<FormState> editFormKey =
        GlobalKey<FormState>();

    bool didSaveChanges = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Theme(
            data: dialogTheme,
            child: StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                final int selectedDuration =
                    int.tryParse(durationController.text.trim()) ?? 1;

                final DateTime endingDate = _calculateEndingDate(
                  startDate: selectedStartDate,
                  duration: selectedDuration > 0
                      ? selectedDuration
                      : 1,
                  unit: selectedUnit,
                );

                return AlertDialog(
                  title: Text(
                    'Edit Committee',
                    style: TextStyle(color: primaryText),
                  ),
                  content: SingleChildScrollView(
                    child: Form(
                      key: editFormKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            textCapitalization:
                                TextCapitalization.words,
                            style: TextStyle(color: primaryText),
                            decoration: const InputDecoration(
                              labelText: 'Committee Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter committee name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: contributionController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(color: primaryText),
                            decoration: const InputDecoration(
                              labelText: 'Monthly Contribution',
                              prefixText: 'PKR ',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final double? amount =
                                  double.tryParse(value?.trim() ?? '');

                              if (amount == null || amount <= 0) {
                                return 'Enter a valid contribution';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: membersController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: primaryText),
                            decoration: const InputDecoration(
                              labelText: 'Total Members',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final int? count =
                                  int.tryParse(value?.trim() ?? '');

                              if (count == null || count <= 0) {
                                return 'Enter a valid member quantity';
                              }

                              if (count <
                                  committeeController.members.length) {
                                return 'Cannot be less than members already added';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: durationController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: primaryText),
                                  decoration: const InputDecoration(
                                    labelText: 'Duration',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (_) {
                                    setDialogState(() {});
                                  },
                                  validator: (value) {
                                    final int? number =
                                        int.tryParse(value?.trim() ?? '');

                                    if (number == null || number <= 0) {
                                      return 'Enter duration';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: selectedUnit,
                                  isExpanded: true,
                                  dropdownColor: cardBackground,
                                  style: TextStyle(
                                    color: primaryText,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Unit',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: units.map((unit) {
                                    return DropdownMenuItem<String>(
                                      value: unit,
                                      child: Text(
                                        unit,
                                        style: TextStyle(
                                          color: primaryText,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setDialogState(() {
                                        selectedUnit = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Start Date: ${_formatDate(selectedStartDate)}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: Icon(
                                Icons.calendar_month,
                                color: primaryAccent,
                              ),
                              label: Text(
                                'Change Start Date',
                                style: TextStyle(color: primaryText),
                              ),
                              onPressed: () async {
                                final DateTime? picked =
                                    await showDatePicker(
                                  context: dialogContext,
                                  initialDate: selectedStartDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder: (context, child) {
                                    return Theme(
                                      data: dialogTheme.copyWith(
                                        colorScheme: dialogTheme
                                            .colorScheme.copyWith(
                                          primary: primaryAccent,
                                          surface: cardBackground,
                                          onSurface: primaryText,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );

                                if (picked != null &&
                                    dialogContext.mounted) {
                                  setDialogState(() {
                                    selectedStartDate = picked;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Ending Date: ${_formatDate(endingDate)}',
                              style: TextStyle(
                                color: secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: secondaryText),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (!editFormKey.currentState!.validate()) {
                          return;
                        }

                        final int duration =
                            int.parse(durationController.text.trim());

                        final double contribution = double.parse(
                          contributionController.text.trim(),
                        );

                        final int memberCount =
                            int.parse(membersController.text.trim());

                        final DateTime calculatedEndingDate =
                            _calculateEndingDate(
                          startDate: selectedStartDate,
                          duration: duration,
                          unit: selectedUnit,
                        );

                        committeeController.updateCurrentCommittee(
                          name: nameController.text.trim(),
                          contribution: contribution,
                          memberCount: memberCount,
                          committeeDuration: duration,
                          unit: selectedUnit,
                          committeeStartDate: selectedStartDate,
                          committeeEndingDate: calculatedEndingDate,
                        );

                        didSaveChanges = true;

                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text('Save Changes'),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    } finally {
      // Wait until the dialog's closing transition has finished.
      // This prevents TextFormField from accessing disposed controllers.
      await Future<void>.delayed(
        const Duration(milliseconds: 300),
      );

      nameController.dispose();
      contributionController.dispose();
      membersController.dispose();
      durationController.dispose();
    }

    // Show success only if Save Changes was pressed.
    // Obx already refreshes the committee details from controller values.
    if (didSaveChanges && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: greenAccent,
          content: const Text(
            'Committee updated successfully.',
          ),
        ),
      );
    }
  }

  // --------------------------------------------------
  // DUPLICATE MEMBER CHECK
  // --------------------------------------------------

  bool _isDuplicateMember({
    required String name,
    required String fatherHusbandName,
    int? editIndex,
  }) {
    final String newName = name.trim().toLowerCase();
    final String newFatherHusband =
        fatherHusbandName.trim().toLowerCase();

    for (int i = 0;
        i < committeeController.members.length;
        i++) {
      if (editIndex != null && i == editIndex) continue;

      final Map<String, dynamic> member =
          committeeController.members[i];

      final String existingName =
          (member['name'] ?? '').toString().trim().toLowerCase();

      final String existingFatherHusband =
          (member['fatherHusbandName'] ??
                  member['fatherName'] ??
                  '')
              .toString()
              .trim()
              .toLowerCase();

      if (existingName == newName &&
          existingFatherHusband == newFatherHusband) {
        return true;
      }
    }

    return false;
  }

  String _ordinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }

    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  // --------------------------------------------------
  // ADD / EDIT MEMBER
  // --------------------------------------------------

  void _showMemberDialog({int? editIndex}) {
    final bool isEdit = editIndex != null;
    Map<String, dynamic>? existingMember;

    if (isEdit &&
        editIndex >= 0 &&
        editIndex < committeeController.members.length) {
      existingMember = committeeController.members[editIndex];
    }

    final TextEditingController nameController =
        TextEditingController(
      text: existingMember?['name']?.toString() ?? '',
    );

    final TextEditingController fatherHusbandController =
        TextEditingController(
      text: (existingMember?['fatherHusbandName'] ??
              existingMember?['fatherName'] ??
              '')
          .toString(),
    );

    final TextEditingController phoneController =
        TextEditingController(
      text: existingMember?['phone']?.toString() ?? '',
    );

    final TextEditingController contributionController =
        TextEditingController(
      text: existingMember == null
          ? ''
          : _toDouble(existingMember['contribution'])
              .toStringAsFixed(0),
    );

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: dialogTheme,
          child: AlertDialog(
            title: Text(
              isEdit ? 'Edit Member' : 'Add Member',
              style: TextStyle(color: primaryText),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: primaryText),
                      decoration: const InputDecoration(
                        labelText: 'Member Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter member name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: fatherHusbandController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: primaryText),
                      decoration: const InputDecoration(
                        labelText: 'Father Name / Husband Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter father/husband name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: primaryText),
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: contributionController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(color: primaryText),
                      decoration: const InputDecoration(
                        labelText: 'Monthly Contribution',
                        prefixText: 'PKR ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter contribution';
                        }

                        final double? amount =
                            double.tryParse(value.trim());

                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: secondaryText),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  final String name = nameController.text.trim();
                  final String fatherHusbandName =
                      fatherHusbandController.text.trim();
                  final String phone = phoneController.text.trim();
                  final double contribution = double.parse(
                    contributionController.text.trim(),
                  );

                  if (_isDuplicateMember(
                    name: name,
                    fatherHusbandName: fatherHusbandName,
                    editIndex: editIndex,
                  )) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This member already exists with the same name and father/husband name.',
                        ),
                      ),
                    );
                    return;
                  }

                  if (isEdit && editIndex != null) {
                    final bool updated =
                        committeeController.updateMember(
                      index: editIndex,
                      name: name,
                      fatherName: fatherHusbandName,
                      phone: phone,
                      contribution: contribution,
                    );

                    if (!updated) return;

                    Navigator.pop(dialogContext);
                    setState(() {});

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        backgroundColor: greenAccent,
                        content: const Text(
                          'Member updated successfully.',
                        ),
                      ),
                    );
                    return;
                  }

                  final int selectedMembers =
                      committeeController.totalMembers.value;
                  final int nextMemberNumber =
                      committeeController.members.length + 1;

                  if (selectedMembers <= 0 ||
                      committeeController.members.length >=
                          selectedMembers) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You selected $selectedMembers members. '
                          '${_ordinal(nextMemberNumber)} member cannot be added.',
                        ),
                      ),
                    );
                    return;
                  }

                  final bool added = committeeController.addMember(
                    name: name,
                    fatherName: fatherHusbandName,
                    phone: phone,
                    contribution: contribution,
                  );

                  if (!added) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'You selected $selectedMembers members. '
                          '${_ordinal(nextMemberNumber)} member cannot be added.',
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.pop(dialogContext);
                  setState(() {});

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      backgroundColor: greenAccent,
                      content: const Text('Member added successfully.'),
                    ),
                  );
                },
                child: Text(isEdit ? 'Update' : 'Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // DELETE MEMBER
  // --------------------------------------------------

  void _deleteMember(int index) {
    if (index < 0 || index >= committeeController.members.length) {
      return;
    }

    final String name =
        committeeController.members[index]['name']?.toString() ??
            'Member';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: dialogTheme,
          child: AlertDialog(
            title: Text(
              'Delete Member',
              style: TextStyle(color: primaryText),
            ),
            content: Text(
              'Are you sure you want to delete $name?',
              style: TextStyle(color: primaryText),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: secondaryText),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  committeeController.deleteMember(index);
                  Navigator.pop(dialogContext);
                  setState(() {});

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      backgroundColor: greenAccent,
                      content: const Text(
                        'Member deleted successfully.',
                      ),
                    ),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // MEMBER CARD
  // --------------------------------------------------

  Widget _buildMemberCard(
    Map<String, dynamic> member,
    int index,
  ) {
    final String name = member['name']?.toString() ?? 'Member';

    final String fatherHusband =
        (member['fatherHusbandName'] ??
                member['fatherName'] ??
                '')
            .toString();

    final String phone = member['phone']?.toString() ?? '';
    final double contribution =
        _toDouble(member['contribution']);
    final String status =
        member['paymentStatus']?.toString() ?? 'Pending';

    final bool received = status.toLowerCase() == 'received';

    return Card(
      color: cardBackground,
      surfaceTintColor: Colors.transparent,
      elevation: isDark ? 1 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outlineColor),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: greenBackground,
                  foregroundColor: greenText,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'M',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fatherHusband.isEmpty
                            ? 'Father/Husband: Not Added'
                            : 'Father/Husband: $fatherHusband',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  iconColor: secondaryText,
                  color: cardBackground,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showMemberDialog(editIndex: index);
                    } else if (value == 'delete') {
                      _deleteMember(index);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'Edit',
                        style: TextStyle(color: primaryText),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: primaryText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    phone.isEmpty ? 'Phone: Not Added' : 'Phone: $phone',
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatAmount(contribution),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: received ? greenBackground : amberBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Payment Status: $status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: received ? greenText : amberText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: cardBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outlineColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 35,
        ),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 52,
              color: secondaryText,
            ),
            const SizedBox(height: 12),
            Text(
              'No Members Added',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap "Add Member" to add committee members.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: cardBackground,
        foregroundColor: primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.membersOnly ? 'Members' : 'Digital Committee',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: greenAccent,
        foregroundColor: Colors.white,
        onPressed: _showMemberDialog,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Member'),
      ),
      body: Obx(() {
        final members = committeeController.members;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.membersOnly) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        committeeController.committeeName.value.isEmpty
                            ? 'Committee'
                            : committeeController.committeeName.value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: primaryAccent,
                      ),
                      onPressed: _showEditCommitteeDialog,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Start Date: ${_formatDate(committeeController.startDate.value)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ending Date: ${_formatDate(committeeController.endingDate.value)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
                const SizedBox(height: 22),
                _buildCommitteeSummary(),
                const SizedBox(height: 22),
                _buildPaymentSummary(),
                const SizedBox(height: 24),
              ],
              Row(
                children: [
                  Expanded(
                    child: _buildSectionTitle('Members'),
                  ),
                  Text(
                    '${members.length} / '
                    '${committeeController.totalMembers.value} Added',
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (members.isEmpty)
                _buildEmptyState()
              else
                ...List.generate(
                  members.length,
                  (index) => _buildMemberCard(
                    members[index],
                    index,
                  ),
                ),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }
}
