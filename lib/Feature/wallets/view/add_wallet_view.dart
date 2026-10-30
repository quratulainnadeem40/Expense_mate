import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';
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
          title: Text('Add Custom Currency'.tr),
          content: TextField(
            controller: customCurrencyController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Currency'.tr,
              hintText: 'e.g. SAR, AED, CAD'.tr,
              prefixIcon: const Icon(Icons.currency_exchange_rounded),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                final currency = customCurrencyController.text.trim();

                if (currency.isNotEmpty) {
                  Navigator.of(dialogContext).pop(currency);
                }
              },
              child: Text('Add'.tr),
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

    final balance = double.tryParse(balanceController.text.trim());

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
        title: Text('Add Wallet'.tr, style: AppTextStyles.headingMedium(isDark)),
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
                  'Wallet Details'.tr,
                  style: AppTextStyles.headingMedium(isDark),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Wallet Name'.tr,
                    hintText: 'e.g. Cash Wallet'.tr,
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter wallet name'.tr;
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
                  decoration: InputDecoration(
                    labelText: 'Initial Balance'.tr,
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter balance'.tr;
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null) {
                      return 'Please enter a valid amount'.tr;
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
                  decoration: InputDecoration(
                    labelText: 'Currency'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: 'PKR',
                      child: Text('Uses the app currency'.tr),
                    ),
                    DropdownMenuItem<String>(
                      value: 'USD',
                      child: Text('USD - US Dollar'.tr),
                    ),
                    DropdownMenuItem<String>(
                      value: 'EUR',
                      child: Text('EUR - Euro'.tr),
                    ),
                    DropdownMenuItem<String>(
                      value: 'GBP',
                      child: Text('GBP - British Pound'.tr),
                    ),
                    DropdownMenuItem<String>(
                      value: 'MORE',
                      child: Row(
                        children: [
                          const Icon(Icons.add, size: 20),
                          const SizedBox(width: 8),
                          Text('More'.tr),
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
                    label: Text('Save Wallet'.tr),
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
