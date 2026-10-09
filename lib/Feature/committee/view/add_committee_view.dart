
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCommitteeView extends StatefulWidget {
  const AddCommitteeView({super.key});

  @override
  State<AddCommitteeView> createState() => _AddCommitteeViewState();
}

class _AddCommitteeViewState extends State<AddCommitteeView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contributionController =
      TextEditingController();
  final TextEditingController membersController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  DateTime? startDate;
  DateTime? endingDate;
  DateTime? dueDate;

  String durationUnit = 'Months';

  @override
  void initState() {
    super.initState();
    durationController.addListener(_calculateEndingDate);
  }

  @override
  void dispose() {
    nameController.dispose();
    contributionController.dispose();
    membersController.dispose();
    durationController.removeListener(_calculateEndingDate);
    durationController.dispose();
    super.dispose();
  }

  void _calculateEndingDate() {
    if (startDate == null) {
      if (endingDate != null) {
        setState(() {
          endingDate = null;
        });
      }
      return;
    }

    // Same date, next year.
    // Example:
    // 05/10/2026 -> 05/10/2027
    final DateTime calculatedDate = DateTime(
      startDate!.year + 1,
      startDate!.month,
      startDate!.day,
    );

    if (endingDate == null ||
        endingDate!.year != calculatedDate.year ||
        endingDate!.month != calculatedDate.month ||
        endingDate!.day != calculatedDate.day) {
      setState(() {
        endingDate = calculatedDate;
      });
    }
  }

  Future<void> selectStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      startDate = pickedDate;

      // Automatically set Ending Date to the same date
      // in the following year.
      //
      // 05/10/2026 -> 05/10/2027
      endingDate = DateTime(
        pickedDate.year + 1,
        pickedDate.month,
        pickedDate.day,
      );

      if (dueDate != null && dueDate!.isBefore(pickedDate)) {
        dueDate = null;
      }
    });
  }

  Future<void> selectDueDate() async {
    final DateTime minimumDate = startDate ?? DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? minimumDate,
      firstDate: minimumDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    setState(() {
      dueDate = pickedDate;
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void saveCommittee() {
    final String name = nameController.text.trim();
    final String contributionText =
        contributionController.text.trim();
    final String membersText = membersController.text.trim();
    final String durationText = durationController.text.trim();

    if (name.isEmpty) {
      showMessage('Please enter committee name.');
      return;
    }

    if (contributionText.isEmpty) {
      showMessage('Please enter monthly contribution.');
      return;
    }

    if (membersText.isEmpty) {
      showMessage('Please enter number of members.');
      return;
    }

    if (durationText.isEmpty) {
      showMessage('Please enter duration.');
      return;
    }

    if (startDate == null) {
      showMessage('Please select start date.');
      return;
    }

    final int? contribution = int.tryParse(contributionText);
    final int? members = int.tryParse(membersText);
    final int? duration = int.tryParse(durationText);

    if (contribution == null || contribution <= 0) {
      showMessage('Please enter a valid monthly contribution.');
      return;
    }

    if (members == null || members <= 0) {
      showMessage('Please enter a valid number of members.');
      return;
    }

    if (duration == null || duration <= 0) {
      showMessage('Please enter a valid duration.');
      return;
    }

    // Keep Ending Date automatically generated.
    // Same date in the next year.
    endingDate = DateTime(
      startDate!.year + 1,
      startDate!.month,
      startDate!.day,
    );

    setState(() {});

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
        'dueDate': dueDate,
      },
    );
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
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
          text: date == null && readOnly ? '' : _formatDate(date),
        ),
        onTap: readOnly ? null : onTap,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(
            readOnly
                ? Icons.event
                : Icons.calendar_today,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Committee'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Committee Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: contributionController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Monthly Contribution',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: membersController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Number of Members',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: durationUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Days',
                        child: Text('Days'),
                      ),
                      DropdownMenuItem(
                        value: 'Weeks',
                        child: Text('Weeks'),
                      ),
                      DropdownMenuItem(
                        value: 'Months',
                        child: Text('Months'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        durationUnit = value;
                      });

                      _calculateEndingDate();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // START DATE
            _buildDateField(
              label: 'Start Date',
              date: startDate,
              onTap: selectStartDate,
            ),

            // ENDING DATE
            // Automatically filled.
            // User cannot select or edit it.
            _buildDateField(
              label: 'Ending Date',
              date: endingDate,
              onTap: () {},
              readOnly: true,
            ),

            // DUE DATE
            _buildDateField(
              label: 'Due Date',
              date: dueDate,
              onTap: selectDueDate,
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveCommittee,
                child: const Text('Save Committee'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

