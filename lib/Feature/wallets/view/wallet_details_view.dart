import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:expense_mate/Feature/wallets/model/wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/wallets_controller.dart';
import 'edit_wallet_view.dart';

class WalletDetailsView extends StatelessWidget {
  final WalletModel wallet;

  const WalletDetailsView({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final controller = Get.find<WalletsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wallet Details'.tr,
          style: AppTextStyles.headingMedium(isDark),
        ),
      ),

      body: Obx(() {
        final currentWallet = controller.wallets.firstWhereOrNull(
          (item) => item.id == wallet.id,
        );

        if (currentWallet == null) {
          return Center(child: Text('Wallet not found'.tr));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 56),

                      const SizedBox(height: 14),

                      Text(
                        currentWallet.name.tr,
                        style: AppTextStyles.headingMedium(isDark),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        currentWallet.displayType.tr,
                        style: AppTextStyles.bodyMedium(isDark),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        '${currentWallet.currency} '
                        '${currentWallet.balance.toStringAsFixed(2)}',
                        style: AppTextStyles.headingMedium(
                          isDark,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => EditWalletView(wallet: currentWallet));
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: Text('Edit Wallet'.tr),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showBalanceDialog(
                      context,
                      controller,
                      currentWallet,
                      isAdd: true,
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Add Money'.tr),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showBalanceDialog(
                      context,
                      controller,
                      currentWallet,
                      isAdd: false,
                    );
                  },
                  icon: const Icon(Icons.remove),
                  label: Text('Withdraw Money'.tr),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _showBalanceDialog(
    BuildContext context,
    WalletsController controller,
    WalletModel currentWallet, {
    required bool isAdd,
  }) async {
    final amountController = TextEditingController();

    final amount = await Get.dialog<double>(
      AlertDialog(
        title: Text(isAdd ? 'Add Money'.tr : 'Withdraw Money'.tr),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount'.tr,
            prefixText: '${currentWallet.currency} ',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(amountController.text.trim());

              if (value == null || value <= 0) {
                Get.snackbar(
                  'Invalid Amount'.tr,
                  'Please enter a valid amount.'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back(result: value);
            },
            child: Text(isAdd ? 'Add'.tr : 'Withdraw'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    amountController.dispose();

    if (amount == null) {
      return;
    }

    final change = isAdd ? amount : -amount;

    await controller.changeBalance(walletId: currentWallet.id, amount: change);

    Get.snackbar(
      isAdd ? 'Money Added'.tr : 'Money Withdrawn'.tr,
      '${currentWallet.currency} ${amount.toStringAsFixed(2)}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
