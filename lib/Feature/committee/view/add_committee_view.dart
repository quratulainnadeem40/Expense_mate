import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCommitteeView extends StatefulWidget {
  const AddCommitteeView({super.key});

  @override
  State<AddCommitteeView> createState() => _AddCommitteeViewState();
}

class _AddCommitteeViewState extends State<AddCommitteeView> {
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

  // Automatically calculated total amount.
  double totalAmount = 0;

  @override
  void dispose() {
    nameController.dispose();
    contributionController.dispose();
    membersController.dispose();
    durationController.dispose();
    super.dispose();
  }

  // Calculate Total Amount automatically.
  void _calculateTotalAmount() {
    final String contributionText =
        contributionController.text
            .replaceAll(',', '')
            .trim();

    final String membersText =
        membersController.text.trim();

    final double? contribution =
        double.tryParse(contributionText);

    final int? members =
        int.tryParse(membersText);

    if (contribution == null ||
        contribution <= 0 ||
        members == null ||
        members <= 0) {
      totalAmount = 0;
      return;
    }

    totalAmount = contribution * members;
  }

  // User selects the Start Date.
  Future<void> selectStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        startDate = pickedDate;
        _calculateEndingDate();
      });
    }
  }

  // Ending Date is automatically calculated.
  void _calculateEndingDate() {
    if (startDate == null) {
      endingDate = null;
      return;
    }

    final String durationText =
        durationController.text
            .replaceAll(',', '')
            .trim();

    final int? duration =
        int.tryParse(durationText);

    if (duration == null || duration <= 0) {
      endingDate = null;
      return;
    }

    if (durationUnit == 'Days') {
      endingDate = startDate!.add(
        Duration(days: duration),
      );
    } else if (durationUnit == 'Weeks') {
      endingDate = startDate!.add(
        Duration(days: duration * 7),
      );
    } else {
      endingDate = _addMonths(
        startDate!,
        duration,
      );
    }
  }

  DateTime _addMonths(DateTime date, int months) {
    final int totalMonths =
        date.year * 12 + date.month - 1 + months;

    final int newYear =
        totalMonths ~/ 12;

    final int newMonth =
        totalMonths % 12 + 1;

    final int lastDayOfMonth =
        DateTime(
          newYear,
          newMonth + 1,
          0,
        ).day;

    final int newDay =
        date.day > lastDayOfMonth
            ? lastDayOfMonth
            : date.day;

    return DateTime(
      newYear,
      newMonth,
      newDay,
    );
  }

  void saveCommittee() {
    final String name =
        nameController.text.trim();

    final String contributionText =
        contributionController.text.trim();

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

    final double? contribution =
        double.tryParse(
      contributionText.replaceAll(',', ''),
    );

    if (contribution == null ||
        contribution <= 0) {
      showMessage(
        'Please enter a valid monthly contribution.',
      );
      return;
    }

    if (membersText.isEmpty) {
      showMessage(
        'Please enter number of members.',
      );
      return;
    }

    final int? members =
        int.tryParse(membersText);

    if (members == null ||
        members <= 0) {
      showMessage(
        'Please enter a valid number of members.',
      );
      return;
    }

    // Calculate total amount before saving.
    _calculateTotalAmount();

    if (totalAmount <= 0) {
      showMessage(
        'Unable to calculate total amount.',
      );
      return;
    }

    if (durationText.isEmpty) {
      showMessage(
        'Please enter committee duration.',
      );
      return;
    }

    final int? duration =
        int.tryParse(
      durationText.replaceAll(',', ''),
    );

    if (duration == null ||
        duration <= 0) {
      showMessage(
        'Please enter a valid duration.',
      );
      return;
    }

    if (startDate == null) {
      showMessage(
        'Please select start date.',
      );
      return;
    }

    // Calculate Ending Date automatically.
    _calculateEndingDate();

    if (endingDate == null) {
      showMessage(
        'Unable to calculate ending date.',
      );
      return;
    }

    Navigator.pop(
      context,
      {
        'name': name,
        'contribution': contribution,
        'members': members,

        // Automatically calculated total amount.
        'totalAmount': totalAmount,

        'duration': duration,
        'durationUnit': durationUnit,
        'startDate': startDate,
        'endingDate': endingDate,

        // Kept for compatibility.
        'dueDate': endingDate,
      },
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final Color backgroundColor =
        isDark
            ? Colors.black
            : const Color(0xFFF5F5F5);

    final Color cardColor =
        isDark
            ? const Color(0xFF0A0A0A)
            : Colors.white;

    final Color primaryTextColor =
        isDark
            ? Colors.white
            : Colors.black87;

    final Color secondaryTextColor =
        isDark
            ? Colors.white60
            : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Add Committee',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            isDark
                ? Colors.black
                : Colors.white,
        foregroundColor:
            primaryTextColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Committee Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color:
                    primaryTextColor,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Enter the basic details of your committee.',
              style: TextStyle(
                fontSize: 13,
                color:
                    secondaryTextColor,
              ),
            ),

            const SizedBox(height: 20),

            _buildTextField(
              controller:
                  nameController,
              label:
                  'Committee Name',
              hint:
                  'Enter committee name',
              icon:
                  Icons.groups_rounded,
              isDark:
                  isDark,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller:
                  contributionController,
              label:
                  'Monthly Contribution',
              hint:
                  'Enter amount',
              icon:
                  Icons.currency_exchange_rounded,
              keyboardType:
                  TextInputType.number,
              isDark:
                  isDark,
              inputFormatters: [
                ThousandsSeparatorInputFormatter(),
              ],
              onChanged: (_) {
                setState(() {
                  _calculateTotalAmount();
                });
              },
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller:
                  membersController,
              label:
                  'Number of Members',
              hint:
                  'Enter members',
              icon:
                  Icons.people_alt_rounded,
              keyboardType:
                  TextInputType.number,
              isDark:
                  isDark,
              onChanged: (_) {
                setState(() {
                  _calculateTotalAmount();
                });
              },
            ),

            const SizedBox(height: 16),

            // Automatically calculated Total Amount.
            _buildTotalAmountField(
              totalAmount:
                  totalAmount,
              icon:
                  Icons.account_balance_wallet_rounded,
              isDark:
                  isDark,
              cardColor:
                  cardColor,
              textColor:
                  primaryTextColor,
            ),

            const SizedBox(height: 16),

            // Duration
            _buildTextField(
              controller:
                  durationController,
              label:
                  'Duration',
              hint:
                  'Enter duration',
              icon:
                  Icons.calendar_month_rounded,
              keyboardType:
                  TextInputType.number,
              isDark:
                  isDark,
              onChanged: (_) {
                setState(() {
                  _calculateEndingDate();
                });
              },
            ),

            const SizedBox(height: 12),

            // Duration Unit
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration:
                  BoxDecoration(
                color:
                    cardColor,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child:
                  DropdownButtonHideUnderline(
                child:
                    DropdownButton<String>(
                  value:
                      durationUnit,
                  isExpanded:
                      true,
                  icon:
                      Icon(
                    Icons
                        .arrow_drop_down_rounded,
                    color:
                        isDark
                            ? Colors.white70
                            : Colors.black54,
                  ),
                  style:
                      TextStyle(
                    fontSize:
                        15,
                    color:
                        primaryTextColor,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value:
                          'Days',
                      child:
                          Text('Days'),
                    ),
                    DropdownMenuItem(
                      value:
                          'Weeks',
                      child:
                          Text('Weeks'),
                    ),
                    DropdownMenuItem(
                      value:
                          'Months',
                      child:
                          Text('Months'),
                    ),
                  ],
                  onChanged:
                      (String? value) {
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
            ),

            const SizedBox(height: 20),

            // User selects Start Date.
            _buildDateField(
              title:
                  'Start Date',
              date:
                  startDate,
              icon:
                  Icons.event_rounded,
              onTap:
                  selectStartDate,
              isDark:
                  isDark,
              cardColor:
                  cardColor,
              textColor:
                  primaryTextColor,
            ),

            const SizedBox(height: 16),

            // Ending Date is automatic.
            _buildEndingDateField(
              date:
                  endingDate,
              icon:
                  Icons.event_available_rounded,
              isDark:
                  isDark,
              cardColor:
                  cardColor,
              textColor:
                  primaryTextColor,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width:
                  double.infinity,
              height:
                  52,
              child:
                  ElevatedButton.icon(
                onPressed:
                    saveCommittee,
                icon:
                    const Icon(
                  Icons.save_rounded,
                ),
                label:
                    const Text(
                  'Create Committee',
                  style:
                      TextStyle(
                    fontSize:
                        16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController
        controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>?
        inputFormatters,
    ValueChanged<String>?
        onChanged,
  }) {
    return TextField(
      controller:
          controller,
      keyboardType:
          keyboardType,
      inputFormatters:
          inputFormatters,
      onChanged:
          onChanged,
      style:
          TextStyle(
        color:
            isDark
                ? Colors.white
                : Colors.black87,
      ),
      decoration:
          InputDecoration(
        labelText:
            label,
        hintText:
            hint,
        prefixIcon:
            Icon(icon),
        filled:
            true,
        fillColor:
            isDark
                ? const Color(0xFF0A0A0A)
                : Colors.white,
        labelStyle:
            TextStyle(
          color:
              isDark
                  ? Colors.white70
                  : Colors.black54,
        ),
        hintStyle:
            TextStyle(
          color:
              isDark
                  ? Colors.white38
                  : Colors.black38,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  // Automatically calculated Total Amount field.
  Widget _buildTotalAmountField({
    required double totalAmount,
    required IconData icon,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
  }) {
    final String formattedAmount =
        totalAmount <= 0
            ? 'Total Amount'
            : 'Total Amount: PKR ${_formatAmount(totalAmount)}';

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration:
          BoxDecoration(
        color:
            cardColor,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            color:
                isDark
                    ? Colors.white70
                    : Colors.black54,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              formattedAmount,
              style:
                  TextStyle(
                fontSize:
                    15,
                fontWeight:
                    totalAmount <= 0
                        ? FontWeight.normal
                        : FontWeight.w600,
                color:
                    textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Start Date field.
  Widget _buildDateField({
    required String title,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap:
          onTap,
      borderRadius:
          BorderRadius.circular(
        14,
      ),
      child:
          Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        decoration:
            BoxDecoration(
          color:
              cardColor,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
        child:
            Row(
          children: [
            Icon(
              icon,
              color:
                  isDark
                      ? Colors.white70
                      : Colors.black54,
            ),

            const SizedBox(width: 14),

            Expanded(
              child:
                  Text(
                date == null
                    ? title
                    : '${date.day}/${date.month}/${date.year}',
                style:
                    TextStyle(
                  fontSize:
                      15,
                  color:
                      textColor,
                ),
              ),
            ),

            Icon(
              Icons
                  .arrow_drop_down_rounded,
              color:
                  isDark
                      ? Colors.white70
                      : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  // Ending Date field.
  // User cannot edit this field.
  Widget _buildEndingDateField({
    required DateTime? date,
    required IconData icon,
    required bool isDark,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      decoration:
          BoxDecoration(
        color:
            cardColor,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            color:
                isDark
                    ? Colors.white70
                    : Colors.black54,
          ),

          const SizedBox(width: 14),

          Expanded(
            child:
                Text(
              date == null
                  ? 'Ending Date'
                  : 'Ending Date: ${date.day}/${date.month}/${date.year}',
              style:
                  TextStyle(
                fontSize:
                    15,
                fontWeight:
                    date == null
                        ? FontWeight.normal
                        : FontWeight.w600,
                color:
                    textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final int value =
        amount.round();

    final String digits =
        value.toString();

    final StringBuffer result =
        StringBuffer();

    for (int i = 0;
        i < digits.length;
        i++) {
      if (i > 0 &&
          (digits.length - i) % 3 == 0) {
        result.write(',');
      }

      result.write(
        digits[i],
      );
    }

    return result.toString();
  }
}

class ThousandsSeparatorInputFormatter
    extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digitsOnly =
        newValue.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    final String formatted =
        _formatWithCommas(
      digitsOnly,
    );

    return TextEditingValue(
      text:
          formatted,
      selection:
          TextSelection.collapsed(
        offset:
            formatted.length,
      ),
    );
  }

  String _formatWithCommas(
    String value,
  ) {
    final StringBuffer result =
        StringBuffer();

    for (int i = 0;
        i < value.length;
        i++) {
      if (i > 0 &&
          (value.length - i) % 3 == 0) {
        result.write(',');
      }

      result.write(
        value[i],
      );
    }

    return result.toString();
  }
}