
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
  DateTime? dueDate;

  @override
  void dispose() {
    nameController.dispose();
    contributionController.dispose();
    membersController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Future<void> selectStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        startDate = pickedDate;

        if (dueDate != null && dueDate!.isBefore(pickedDate)) {
          dueDate = null;
        }
      });
    }
  }

  Future<void> selectDueDate() async {
    final DateTime minimumDate =
        startDate ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: minimumDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        dueDate = pickedDate;
      });
    }
  }

  void saveCommittee() {
    final String name = nameController.text.trim();
    final String contributionText =
        contributionController.text.trim();
    final String membersText =
        membersController.text.trim();
    final String durationText =
        durationController.text.trim();

    if (name.isEmpty) {
      showMessage('Please enter committee name.');
      return;
    }

    if (contributionText.isEmpty) {
      showMessage('Please enter monthly contribution.');
      return;
    }

    final double? contribution = double.tryParse(
      contributionText.replaceAll(',', ''),
    );

    if (contribution == null || contribution <= 0) {
      showMessage(
        'Please enter a valid monthly contribution.',
      );
      return;
    }

    if (membersText.isEmpty) {
      showMessage('Please enter number of members.');
      return;
    }

    final int? members = int.tryParse(membersText);

    if (members == null || members <= 0) {
      showMessage(
        'Please enter a valid number of members.',
      );
      return;
    }

    if (durationText.isEmpty) {
      showMessage('Please enter committee duration.');
      return;
    }

    final int? duration = int.tryParse(durationText);

    if (duration == null || duration <= 0) {
      showMessage(
        'Please enter a valid duration in months.',
      );
      return;
    }

    if (startDate == null) {
      showMessage('Please select start date.');
      return;
    }

    if (dueDate == null) {
      showMessage('Please select due date.');
      return;
    }

    if (dueDate!.isBefore(startDate!)) {
      showMessage(
        'Due date cannot be before start date.',
      );
      return;
    }

    Navigator.pop(
      context,
      {
        'name': name,
        'contribution': contribution,
        'members': members,
        'duration': duration,
        'startDate': startDate,
        'dueDate': dueDate,
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
        Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor =
        isDark ? Colors.black : const Color(0xFFF5F5F5);

    final Color cardColor =
        isDark ? const Color(0xFF0A0A0A) : Colors.white;

    final Color primaryTextColor =
        isDark ? Colors.white : Colors.black87;

    final Color secondaryTextColor =
        isDark ? Colors.white60 : Colors.black54;

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
            isDark ? Colors.black : Colors.white,
        foregroundColor: primaryTextColor,
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
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter the basic details of your committee.',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: nameController,
              label: 'Committee Name',
              hint: 'Enter committee name',
              icon: Icons.groups_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: contributionController,
              label: 'Monthly Contribution',
              hint: 'Enter amount',
              icon: Icons.currency_exchange_rounded,
              keyboardType: TextInputType.number,
              isDark: isDark,
              inputFormatters: [
                ThousandsSeparatorInputFormatter(),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: membersController,
              label: 'Number of Members',
              hint: 'Enter members',
              icon: Icons.people_alt_rounded,
              keyboardType: TextInputType.number,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: durationController,
              label: 'Duration',
              hint: 'Enter duration in months',
              icon: Icons.calendar_month_rounded,
              keyboardType: TextInputType.number,
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            _buildDateField(
              title: 'Start Date',
              date: startDate,
              icon: Icons.event_rounded,
              onTap: selectStartDate,
              isDark: isDark,
              cardColor: cardColor,
              textColor: primaryTextColor,
            ),
            const SizedBox(height: 16),
            _buildDateField(
              title: 'Due Date',
              date: dueDate,
              icon: Icons.event_available_rounded,
              onTap: selectDueDate,
              isDark: isDark,
              cardColor: cardColor,
              textColor: primaryTextColor,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: saveCommittee,
                icon: const Icon(Icons.save_rounded),
                label: const Text(
                  'Create Committee',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor:
            isDark ? const Color(0xFF0A0A0A) : Colors.white,
        labelStyle: TextStyle(
          color:
              isDark ? Colors.white70 : Colors.black54,
        ),
        hintStyle: TextStyle(
          color:
              isDark ? Colors.white38 : Colors.black38,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

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
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark
                  ? Colors.white70
                  : Colors.black54,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                date == null
                    ? title
                    : '${date.day}/${date.month}/${date.year}',
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: isDark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ],
        ),
      ),
    );
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
        newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    final String formatted =
        _formatWithCommas(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }

  String _formatWithCommas(String value) {
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        result.write(',');
      }

      result.write(value[i]);
    }

    return result.toString();
  }
}
