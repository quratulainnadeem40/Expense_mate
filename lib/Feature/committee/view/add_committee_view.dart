import 'package:expense_mate/Core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/committe_controller.dart';
import '../model/committee_schedule.dart';

class AddCommitteeView extends StatefulWidget {
  const AddCommitteeView({super.key});

  @override
  State<AddCommitteeView> createState() => _AddCommitteeViewState();
}

class _AddCommitteeViewState extends State<AddCommitteeView> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController contributionController = TextEditingController();

  final TextEditingController membersController = TextEditingController();

  final TextEditingController durationController = TextEditingController();

  DateTime? startDate;
  DateTime? endingDate;

  final CommitteeController committeeController = CommitteeController.instance;

  // Theme-aware colors
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
  static const Color lightGreenBackground = Color(0xFFE5F4EC);
  static const Color darkGreenBackground = Color(0xFF20352C);

  static const Color purpleAccent = Color(0xFF8056B3);
  static const Color lightPurpleBackground = Color(0xFFF0E9FA);
  static const Color darkPurpleBackground = Color(0xFF302640);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get screenBackground => isDark ? darkBackground : lightBackground;

  Color get cardBackground => isDark ? darkCard : lightCard;

  Color get primaryText => isDark ? darkText : lightText;

  Color get secondaryText => isDark ? darkSecondary : lightSecondary;

  Color get outlineColor => isDark ? darkBorder : lightBorder;

  Color get summaryGreenBackground =>
      isDark ? darkGreenBackground : lightGreenBackground;

  Color get summaryPurpleBackground =>
      isDark ? darkPurpleBackground : lightPurpleBackground;

  @override
  void initState() {
    super.initState();

    contributionController.addListener(_onContributionChanged);
    membersController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    nameController.dispose();

    contributionController.removeListener(_onContributionChanged);
    membersController.removeListener(_onInputChanged);

    contributionController.dispose();
    membersController.dispose();
    durationController.dispose();

    super.dispose();
  }

  void _onInputChanged() {
    final int memberCount = int.tryParse(membersController.text.trim()) ?? 0;
    final String calculatedDuration = memberCount > 0
        ? memberCount.toString()
        : '';
    if (durationController.text != calculatedDuration) {
      durationController.text = calculatedDuration;
    }

    _calculateEndingDate();

    if (mounted) {
      setState(() {});
    }
  }

  void _onContributionChanged() {
    final String text = contributionController.text;

    if (text.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    final String digitsOnly = text.replaceAll(',', '');

    if (digitsOnly.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    final String formatted = _formatNumberWithCommas(digitsOnly);

    if (formatted != text) {
      final int oldOffset = contributionController.selection.baseOffset;

      final int difference = formatted.length - text.length;

      int newOffset = oldOffset + difference;

      if (newOffset < 0) newOffset = 0;
      if (newOffset > formatted.length) {
        newOffset = formatted.length;
      }

      contributionController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: newOffset),
      );
    }

    if (mounted) setState(() {});
  }

  String _formatNumberWithCommas(String value) {
    final String digits = value.replaceAll(',', '');

    if (digits.isEmpty) return '';

    final StringBuffer result = StringBuffer();
    int count = 0;

    for (int i = digits.length - 1; i >= 0; i--) {
      result.write(digits[i]);
      count++;

      if (count == 3 && i != 0) {
        result.write(',');
        count = 0;
      }
    }

    return result.toString().split('').reversed.join();
  }

  double _parseContribution() {
    final String value = contributionController.text.replaceAll(',', '').trim();

    return double.tryParse(value) ?? 0;
  }

  // --------------------------------------------------
  // ENDING DATE
  // --------------------------------------------------

  void _calculateEndingDate() {
    if (startDate == null) {
      endingDate = null;
      return;
    }

    final int memberCount = int.tryParse(membersController.text.trim()) ?? 0;

    if (memberCount <= 0) {
      endingDate = null;
      return;
    }

    endingDate = committeeDateForCycle(startDate!, memberCount);
  }

  Future<void> selectStartDate() async {
    final bool dark = isDark;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: dark
                ? const ColorScheme.dark(
                    primary: greenAccent,
                    onPrimary: Colors.white,
                    surface: darkCard,
                    onSurface: darkText,
                  )
                : const ColorScheme.light(
                    primary: greenAccent,
                    onPrimary: Colors.white,
                    surface: lightCard,
                    onSurface: lightText,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    setState(() {
      startDate = pickedDate;
      _calculateEndingDate();
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: greenAccent,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // --------------------------------------------------
  // AMOUNT CALCULATIONS
  // --------------------------------------------------

  double get monthlyCommitteeAmount {
    final double contribution = _parseContribution();

    final int members = int.tryParse(membersController.text.trim()) ?? 0;

    return contribution * members;
  }

  double get totalDurationAmount {
    final int memberCount = int.tryParse(membersController.text.trim()) ?? 0;
    return monthlyCommitteeAmount * memberCount;
  }

  String _formatAmount(double amount) {
    return '${Formatters.code} ${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date'.tr;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  InputDecoration _inputDecoration({
    required String label,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      prefixText: prefixText,
      filled: true,
      fillColor: cardBackground,
      labelStyle: TextStyle(color: secondaryText),
      prefixStyle: TextStyle(
        color: isDark ? const Color(0xFF7DD6A8) : greenAccent,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outlineColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: outlineColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF7DD6A8) : greenAccent,
          width: 1.8,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(text: _formatDate(date)),
        onTap: readOnly ? null : onTap,
        style: TextStyle(color: primaryText),
        decoration: _inputDecoration(
          label: label,
          suffixIcon: Icon(
            readOnly ? Icons.event_rounded : Icons.calendar_month_rounded,
            color: readOnly
                ? purpleAccent
                : (isDark ? const Color(0xFF7DD6A8) : greenAccent),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SAVE COMMITTEE
  // --------------------------------------------------

  void saveCommittee() {
    final String name = nameController.text.trim();

    final String contributionText = contributionController.text
        .replaceAll(',', '')
        .trim();

    final String membersText = membersController.text.trim();
    if (name.isEmpty) {
      showMessage('Please enter committee name.'.tr);
      return;
    }

    if (contributionText.isEmpty) {
      showMessage('Please enter monthly contribution.'.tr);
      return;
    }

    if (membersText.isEmpty) {
      showMessage('Please enter number of members.'.tr);
      return;
    }

    if (startDate == null) {
      showMessage('Please select start date.'.tr);
      return;
    }

    final double? contribution = double.tryParse(contributionText);
    final int? members = int.tryParse(membersText);
    if (contribution == null || contribution <= 0) {
      showMessage('Please enter a valid monthly contribution.'.tr);
      return;
    }

    if (members == null || members <= 0) {
      showMessage('Please enter a valid number of members.'.tr);
      return;
    }

    _calculateEndingDate();

    if (endingDate == null) {
      showMessage('Please enter a valid number of members.'.tr);
      return;
    }

    committeeController.addCommittee(
      name: name,
      contribution: contribution,
      memberCount: members,
      committeeStartDate: startDate!,
      committeeEndingDate: endingDate!,
    );

    Navigator.pop(context, {
      'name': name,
      'contribution': contribution,
      'members': members,
      'duration': members,
      'durationUnit': 'Months',
      'startDate': startDate,
      'endingDate': endingDate,
      'monthlyCommitteeAmount': monthlyCommitteeAmount,
      'totalDurationAmount': totalDurationAmount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: cardBackground,
        foregroundColor: primaryText,
        elevation: 0,
        title: Text('Add Committee'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: primaryText),
              decoration: _inputDecoration(label: 'Committee Name'.tr),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: contributionController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
              ],
              style: TextStyle(color: primaryText),
              decoration: _inputDecoration(
                label: 'Monthly Contribution'.tr,
                prefixText: '${Formatters.code} ',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: membersController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: primaryText),
              decoration: _inputDecoration(label: 'Number of Members'.tr),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: summaryGreenBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? darkBorder : const Color(0xFFB8E5CC),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Committee Amount'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF7DD6A8) : greenAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatAmount(monthlyCommitteeAmount),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF7DD6A8) : greenAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: durationController,
              readOnly: true,
              style: TextStyle(color: primaryText),
              decoration: _inputDecoration(
                label: 'Duration'.tr,
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text('Months'.tr),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: summaryPurpleBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? darkBorder : const Color(0xFFD9C8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount for Duration'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFC7A7F4) : purpleAccent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatAmount(totalDurationAmount),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFC7A7F4) : purpleAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildDateField(
              label: 'Start Date'.tr,
              date: startDate,
              onTap: selectStartDate,
            ),

            _buildDateField(
              label: 'First Committee Payout'.tr,
              date: startDate == null
                  ? null
                  : committeeDateForCycle(startDate!, 1),
              onTap: () {},
              readOnly: true,
            ),

            _buildDateField(
              label: 'Ending Date'.tr,
              date: endingDate,
              onTap: () {},
              readOnly: true,
            ),

            const SizedBox(height: 8),
            Text(
              'The first installment is collected on the start date. The first payout happens after one month, then one member receives the committee each month until everyone has received it.'
                  .tr,
              style: TextStyle(color: secondaryText, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenAccent,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: saveCommittee,
                child: Text(
                  'Save Committee'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
