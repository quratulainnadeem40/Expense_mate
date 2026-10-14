
import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/wallets_controller.dart';
import '../widgets/wallet_type_selector.dart';

class AddWalletView extends StatefulWidget {
  const AddWalletView({super.key});

  @override
  State<AddWalletView> createState() => _AddWalletViewState();
}

class _AddWalletViewState extends State<AddWalletView> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  final customCurrencyController = TextEditingController();

  String selectedType = 'Cash';
  String selectedCurrency = 'PKR';

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    customCurrencyController.dispose();
    super.dispose();
  }

  Future<void> showCustomCurrencyDialog() async {
    customCurrencyController.clear();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Custom Currency'),
          content: TextField(
            controller: customCurrencyController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Currency',
              hintText: 'e.g. SAR, AED, CAD',
              prefixIcon: Icon(Icons.currency_exchange_rounded),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final currency = customCurrencyController.text.trim();

                if (currency.isNotEmpty) {
                  Navigator.of(dialogContext).pop(currency);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        selectedCurrency = result.trim().toUpperCase();
      });
    }
  }

  Future<void> saveWallet() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Remove commas before converting the amount to a number.
    final balance = double.tryParse(
      balanceController.text.trim().replaceAll(',', ''),
    );

    if (balance == null) {
      return;
    }

    final controller = Get.find<WalletsController>();

    await controller.addWallet(
      name: nameController.text.trim(),
      type: selectedType,
      balance: balance,
      currency: selectedCurrency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Wallet',
          style: AppTextStyles.headingMedium(isDark),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Details',
                  style: AppTextStyles.headingMedium(isDark),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Wallet Name',
                    hintText: 'e.g. Cash Wallet',
                    prefixIcon: Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter wallet name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                WalletTypeSelector(
                  selectedType: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });

                    if (nameController.text.trim().isEmpty) {
                      nameController.text = value;
                    }
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    IndianAmountFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter balance';
                    }

                    final amount = double.tryParse(
                      value.trim().replaceAll(',', ''),
                    );

                    if (amount == null) {
                      return 'Please enter a valid amount';
                    }

                    if (amount < 0) {
                      return 'Balance cannot be negative';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  initialValue: selectedCurrency,
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'PKR',
                      child: Text('PKR - Pakistani Rupee'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'USD',
                      child: Text('USD - US Dollar'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'EUR',
                      child: Text('EUR - Euro'),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'GBP',
                      child: Text('GBP - British Pound'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'MORE',
                      child: Row(
                        children: const [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text('More'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) async {
                    if (value == null) {
                      return;
                    }

                    if (value == 'MORE') {
                      await showCustomCurrencyDialog();
                      return;
                    }

                    setState(() {
                      selectedCurrency = value;
                    });
                  },
                  validator: (value) {
                    if (selectedCurrency.trim().isEmpty) {
                      return 'Please select currency';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: saveWallet,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Wallet'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Automatically adds commas using the Pakistani/Indian number format.
/// Examples: 10000 -> 10,000; 1000000 -> 10,00,000.
class IndianAmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawText = newValue.text.replaceAll(',', '');

    // Allow digits and a single decimal point only.
    if (RegExp(r'[^0-9.]').hasMatch(rawText) ||
        '.'.allMatches(rawText).length > 1) {
      return oldValue;
    }

    if (rawText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final parts = rawText.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : null;

    String formattedInteger = integerPart;

    if (integerPart.length > 3) {
      final lastThree = integerPart.substring(
        integerPart.length - 3,
      );

      var remaining = integerPart.substring(
        0,
        integerPart.length - 3,
      );

      final groups = <String>[];

      while (remaining.length > 2) {
        groups.insert(
          0,
          remaining.substring(remaining.length - 2),
        );

        remaining = remaining.substring(
          0,
          remaining.length - 2,
        );
      }

      if (remaining.isNotEmpty) {
        groups.insert(0, remaining);
      }

      formattedInteger = '${groups.join(',')},$lastThree';
    }

    var formattedText = formattedInteger;

    if (decimalPart != null) {
      formattedText += '.$decimalPart';
    }

    // Keep the cursor near its original logical position.
    final oldCursor = newValue.selection.baseOffset
        .clamp(0, newValue.text.length);

    final logicalCursor = newValue.text
        .substring(0, oldCursor)
        .replaceAll(',', '')
        .length;

    var newCursor = 0;
    var logicalCount = 0;

    while (newCursor < formattedText.length &&
        logicalCount < logicalCursor) {
      if (formattedText[newCursor] != ',') {
        logicalCount++;
      }
      newCursor++;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursor),
      composing: TextRange.empty,
    );
  }
}
