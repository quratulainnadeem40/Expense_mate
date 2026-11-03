import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Core/utils/formatters.dart';
import 'package:expense_mate/Feature/settings/controller/settings_controller.dart';
import 'package:expense_mate/Feature/wallets/model/wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/wallets_controller.dart';
import '../widgets/wallet_type_selector.dart';

class EditWalletView extends StatefulWidget {
  final WalletModel wallet;

  const EditWalletView({super.key, required this.wallet});

  @override
  State<EditWalletView> createState() => _EditWalletViewState();
}

class _EditWalletViewState extends State<EditWalletView> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController balanceController;

  late String selectedType;
  late String selectedCurrency;
  late bool usesAppCurrency;

  static const _currencyNames = {
    'PKR': 'Pakistani Rupees',
    'SAR': 'Saudi Riyal',
    'TRY': 'Turkish Lira',
    'AED': 'UAE Dirham',
    'USD': 'US Dollar',
    'AUD': 'Australian Dollar',
    'GBP': 'British Pound',
    'EUR': 'Euro',
  };

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.wallet.name);

    balanceController = TextEditingController(
      text: widget.wallet.balance.toStringAsFixed(2),
    );

    selectedType = widget.wallet.type;
    selectedCurrency = widget.wallet.currency;
    usesAppCurrency = selectedCurrency == Formatters.code;
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  Future<void> updateWallet() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final balance = double.tryParse(balanceController.text.trim());

    if (balance == null) {
      return;
    }

    final controller = Get.find<WalletsController>();

    await controller.updateWallet(
      walletId: widget.wallet.id,
      name: nameController.text.trim(),
      type: selectedType,
      balance: balance,
      currency: selectedCurrency,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletCurrencies = {
      ...SettingsController.defaultCurrencies,
      'EUR',
      selectedCurrency,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Wallet'.tr,
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
                  },
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Balance'.tr,
                    hintText: '0.00',
                    prefixText:
                        '${Formatters.currencySymbol(selectedCurrency)} ',
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
                      return 'Balance cannot be negative'.tr;
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  key: ValueKey(
                    usesAppCurrency ? 'APP_CURRENCY' : selectedCurrency,
                  ),
                  initialValue: usesAppCurrency
                      ? 'APP_CURRENCY'
                      : selectedCurrency,
                  decoration: InputDecoration(
                    labelText: 'Currency'.tr,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'APP_CURRENCY',
                      child: Text('Uses the app currency'.tr),
                    ),
                    ...walletCurrencies.map(
                      (currency) => DropdownMenuItem(
                        value: currency,
                        child: Text(
                          '$currency - ${_currencyNames[currency] ?? currency}',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        usesAppCurrency = value == 'APP_CURRENCY';
                        selectedCurrency = usesAppCurrency
                            ? Formatters.code
                            : value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: updateWallet,
                    icon: const Icon(Icons.save_outlined),
                    label: Text('Update Wallet'.tr),
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
