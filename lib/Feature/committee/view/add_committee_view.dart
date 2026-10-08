import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/committe_controller.dart';

class AddCommitteeView extends StatefulWidget {
  const AddCommitteeView({super.key});

  @override
  State<AddCommitteeView> createState() =>
      _AddCommitteeViewState();
}

class _AddCommitteeViewState
    extends State<AddCommitteeView> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController contributionController =
      TextEditingController();

  final TextEditingController membersController =
      TextEditingController();

  final TextEditingController durationController =
      TextEditingController();

  DateTime? startDate;

  DateTime? endingDate;

  String durationUnit = 'Months';

  final CommitteeController committeeController =
      CommitteeController.instance;

  @override
  void initState() {
    super.initState();

    durationController.addListener(_onInputChanged);

    contributionController
        .addListener(_onContributionChanged);

    membersController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    nameController.dispose();

    contributionController
        .removeListener(_onContributionChanged);

    membersController.removeListener(_onInputChanged);

    durationController.removeListener(_onInputChanged);

    contributionController.dispose();

    membersController.dispose();

    durationController.dispose();

    super.dispose();
  }

  void _onInputChanged() {
    _calculateEndingDate();

    if (mounted) {
      setState(() {});
    }
  }

  void _onContributionChanged() {
    final String text =
        contributionController.text;

    if (text.isEmpty) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    final String digitsOnly =
        text.replaceAll(',', '');

    if (digitsOnly.isEmpty) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    final String formatted =
        _formatNumberWithCommas(digitsOnly);

    if (formatted != text) {
      final int oldOffset =
          contributionController
              .selection
              .baseOffset;

      final int difference =
          formatted.length - text.length;

      int newOffset =
          oldOffset + difference;

      if (newOffset < 0) {
        newOffset = 0;
      }

      if (newOffset > formatted.length) {
        newOffset = formatted.length;
      }

      contributionController.value =
          TextEditingValue(
        text: formatted,
        selection:
            TextSelection.collapsed(
          offset: newOffset,
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  String _formatNumberWithCommas(
    String value,
  ) {
    final String digits =
        value.replaceAll(',', '');

    if (digits.isEmpty) {
      return '';
    }

    final StringBuffer result =
        StringBuffer();

    int count = 0;

    for (
      int i = digits.length - 1;
      i >= 0;
      i--
    ) {
      result.write(digits[i]);

      count++;

      if (count == 3 && i != 0) {
        result.write(',');

        count = 0;
      }
    }

    return result
        .toString()
        .split('')
        .reversed
        .join();
  }

  double _parseContribution() {
    final String value =
        contributionController.text
            .replaceAll(',', '')
            .trim();

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

    final int duration =
        int.tryParse(
              durationController.text.trim(),
            ) ??
            0;

    if (duration <= 0) {
      endingDate = null;
      return;
    }

    DateTime calculatedDate;

    switch (durationUnit) {
      case 'Days':
        calculatedDate =
            startDate!.add(
          Duration(days: duration),
        );
        break;

      case 'Weeks':
        calculatedDate =
            startDate!.add(
          Duration(days: duration * 7),
        );
        break;

      case 'Months':
        final int targetYear =
            startDate!.year +
                ((startDate!.month -
                            1 +
                        duration) ~/
                    12);

        final int targetMonth =
            ((startDate!.month -
                        1 +
                    duration) %
                12) +
            1;

        final int lastDay =
            DateTime(
              targetYear,
              targetMonth + 1,
              0,
            ).day;

        final int targetDay =
            startDate!.day > lastDay
                ? lastDay
                : startDate!.day;

        calculatedDate = DateTime(
          targetYear,
          targetMonth,
          targetDay,
        );

        break;

      case 'Years':
        final int targetYear =
            startDate!.year + duration;

        final int lastDay =
            DateTime(
              targetYear,
              startDate!.month + 1,
              0,
            ).day;

        final int targetDay =
            startDate!.day > lastDay
                ? lastDay
                : startDate!.day;

        calculatedDate = DateTime(
          targetYear,
          startDate!.month,
          targetDay,
        );

        break;

      default:
        calculatedDate =
            startDate!.add(
          Duration(days: duration),
        );
    }

    endingDate = calculatedDate;
  }

  Future<void> selectStartDate() async {
    final DateTime? pickedDate =
        await showDatePicker(
      context: context,
      initialDate:
          startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      startDate = pickedDate;

      _calculateEndingDate();
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // --------------------------------------------------
  // AMOUNT CALCULATIONS
  // --------------------------------------------------

  double get monthlyCommitteeAmount {
    final double contribution =
        _parseContribution();

    final int members =
        int.tryParse(
              membersController.text.trim(),
            ) ??
            0;

    return contribution * members;
  }

  double get durationInMonths {
    final int duration =
        int.tryParse(
              durationController.text.trim(),
            ) ??
            0;

    if (duration <= 0) {
      return 0;
    }

    switch (durationUnit) {
      case 'Days':
        return duration / 30;

      case 'Weeks':
        return duration / 4.345;

      case 'Months':
        return duration.toDouble();

      case 'Years':
        return duration * 12;

      default:
        return duration.toDouble();
    }
  }

  double get totalDurationAmount {
    return monthlyCommitteeAmount *
        durationInMonths;
  }

  String _formatAmount(double amount) {
    return 'PKR ${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select Date';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        readOnly: true,
        controller:
            TextEditingController(
          text: _formatDate(date),
        ),
        onTap:
            readOnly ? null : onTap,
        decoration:
            InputDecoration(
          labelText: label,
          suffixIcon: Icon(
            readOnly
                ? Icons.event
                : Icons.calendar_today,
          ),
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SAVE COMMITTEE
  // --------------------------------------------------

  void saveCommittee() {
    final String name =
        nameController.text.trim();

    final String contributionText =
        contributionController.text
            .replaceAll(',', '')
            .trim();

    final String membersText =
        membersController.text.trim();

    final String durationText =
        durationController.text.trim();

    if (name.isEmpty) {
      showMessage(
        'Please enter committee name.',
      );
      return;
    }

    if (contributionText.isEmpty) {
      showMessage(
        'Please enter monthly contribution.',
      );
      return;
    }

    if (membersText.isEmpty) {
      showMessage(
        'Please enter number of members.',
      );
      return;
    }

    if (durationText.isEmpty) {
      showMessage(
        'Please enter duration.',
      );
      return;
    }

    if (startDate == null) {
      showMessage(
        'Please select start date.',
      );
      return;
    }

    final double? contribution =
        double.tryParse(
      contributionText,
    );

    final int? members =
        int.tryParse(membersText);

    final int? duration =
        int.tryParse(durationText);

    if (contribution == null ||
        contribution <= 0) {
      showMessage(
        'Please enter a valid monthly contribution.',
      );
      return;
    }

    if (members == null ||
        members <= 0) {
      showMessage(
        'Please enter a valid number of members.',
      );
      return;
    }

    if (duration == null ||
        duration <= 0) {
      showMessage(
        'Please enter a valid duration.',
      );
      return;
    }

    _calculateEndingDate();

    if (endingDate == null) {
      showMessage(
        'Please enter a valid duration.',
      );
      return;
    }

    // ------------------------------------------------
    // IMPORTANT:
    // SAVE DIRECTLY INTO SHARED CONTROLLER
    // ------------------------------------------------

    committeeController.addCommittee(
      name: name,
      contribution: contribution,
      memberCount: members,
      committeeDuration: duration,
      unit: durationUnit,
      committeeStartDate: startDate!,
      committeeEndingDate: endingDate!,
    );

    // Also return the result so existing navigation
    // code continues to work.
    Navigator.pop(
      context,
      {
        'name': name,
        'contribution': contribution,
        'members': members,
        'duration': duration,
        'durationUnit': durationUnit,
        'startDate': startDate,
        'endingDate': endingDate,
        'monthlyCommitteeAmount':
            monthlyCommitteeAmount,
        'totalDurationAmount':
            totalDurationAmount,
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Add Committee'),
      ),
      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller:
                  nameController,
              decoration:
                  const InputDecoration(
                labelText:
                    'Committee Name',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  contributionController,
              keyboardType:
                  TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter
                    .allow(
                  RegExp(r'[0-9,]'),
                ),
              ],
              decoration:
                  const InputDecoration(
                labelText:
                    'Monthly Contribution',
                prefixText: 'PKR ',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  membersController,
              keyboardType:
                  TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter
                    .digitsOnly,
              ],
              decoration:
                  const InputDecoration(
                labelText:
                    'Number of Members',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(12),
                border:
                    Border.all(
                  color: Colors.black12,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Committee Amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    _formatAmount(
                      monthlyCommitteeAmount,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        durationController,
                    keyboardType:
                        TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter
                          .digitsOnly,
                    ],
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Duration',
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child:
                      DropdownButtonFormField<
                          String>(
                    value:
                        durationUnit,
                    decoration:
                        const InputDecoration(
                      labelText: 'Unit',
                      border:
                          OutlineInputBorder(),
                    ),
                    items:
                        const [
                      DropdownMenuItem(
                        value: 'Days',
                        child:
                            Text('Days'),
                      ),
                      DropdownMenuItem(
                        value: 'Weeks',
                        child:
                            Text('Weeks'),
                      ),
                      DropdownMenuItem(
                        value: 'Months',
                        child:
                            Text('Months'),
                      ),
                      DropdownMenuItem(
                        value: 'Years',
                        child:
                            Text('Years'),
                      ),
                    ],
                    onChanged:
                        (value) {
                      if (value ==
                          null) {
                        return;
                      }

                      setState(() {
                        durationUnit =
                            value;

                        _calculateEndingDate();
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(16),
              decoration:
                  BoxDecoration(
                borderRadius:
                    BorderRadius.circular(12),
                border:
                    Border.all(
                  color: Colors.black12,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount for Duration',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    _formatAmount(
                      totalDurationAmount,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildDateField(
              label: 'Start Date',
              date: startDate,
              onTap:
                  selectStartDate,
            ),

            _buildDateField(
              label: 'Ending Date',
              date: endingDate,
              onTap: () {},
              readOnly: true,
            ),

            const SizedBox(height: 8),

            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                onPressed:
                    saveCommittee,
                child:
                    const Text(
                  'Save Committee',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}