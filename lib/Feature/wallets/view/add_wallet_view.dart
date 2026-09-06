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

  String selectedType = 'Cash';
  String selectedCurrency = 'PKR';

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  Future<void> saveWallet() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final balance = double.tryParse(
      balanceController.text.trim(),
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

    Get.back();
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
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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

                    if (double.tryParse(value.trim()) == null) {
                      return 'Please enter a valid amount';
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
                  items: const [
                    DropdownMenuItem(
                      value: 'PKR',
                      child: Text('PKR - Pakistani Rupee'),
                    ),
                    DropdownMenuItem(
                      value: 'USD',
                      child: Text('USD - US Dollar'),
                    ),
                    DropdownMenuItem(
                      value: 'EUR',
                      child: Text('EUR - Euro'),
                    ),
                    DropdownMenuItem(
                      value: 'GBP',
                      child: Text('GBP - British Pound'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCurrency = value;
                      });
                    }
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