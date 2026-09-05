import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_wallet_view.dart';
import '../controller/wallets_controller.dart';
import '../model/wallet_model.dart';

class WalletDetailsView extends StatelessWidget {
  final WalletModel wallet;

  const WalletDetailsView({
    super.key,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final controller = Get.find<WalletsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wallet Details',
          style: AppTextStyles.headingMedium(isDark),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================================================
            // WALLET INFORMATION
            // ==================================================

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 56,
                    ),

                    const SizedBox(height: 14),

                    Text(
                      wallet.name,
                      style: AppTextStyles.headingMedium(isDark),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      wallet.type,
                      style: AppTextStyles.bodyMedium(isDark),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      '${wallet.currency} ${wallet.balance.toStringAsFixed(2)}',
                      style: AppTextStyles.headingMedium(isDark).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // EDIT WALLET
            // ==================================================

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
              onPressed: () {
  Get.to(
    () => EditWalletView(wallet: wallet),
  );
},
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Wallet'),
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // ADD MONEY
            // ==================================================

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showBalanceDialog(
                    context,
                    controller,
                    isAdd: true,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Money'),
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // WITHDRAW MONEY
            // ==================================================

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showBalanceDialog(
                    context,
                    controller,
                    isAdd: false,
                  );
                },
                icon: const Icon(Icons.remove),
                label: const Text('Withdraw Money'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBalanceDialog(
  BuildContext context,
  WalletsController controller, {
  required bool isAdd,
}) async {
  final amountController = TextEditingController();

  final amount = await Get.dialog<double>(
    AlertDialog(
      title: Text(
        isAdd ? 'Add Money' : 'Withdraw Money',
      ),
      content: TextField(
        controller: amountController,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: 'Amount',
          prefixText: '${wallet.currency} ',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final value = double.tryParse(
              amountController.text.trim(),
            );

            if (value == null || value <= 0) {
              Get.snackbar(
                'Invalid Amount',
                'Please enter a valid amount.',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }

            Get.back(result: value);
          },
          child: Text(
            isAdd ? 'Add' : 'Withdraw',
          ),
        ),
      ],
    ),
    barrierDismissible: false,
  );

  // Dispose only AFTER the dialog has completely closed.
  amountController.dispose();

  if (amount == null) {
    return;
  }

  final change = isAdd ? amount : -amount;

  await controller.changeBalance(
    walletId: wallet.id,
    amount: change,
  );

  Get.snackbar(
    isAdd ? 'Money Added' : 'Money Withdrawn',
    '${wallet.currency} ${amount.toStringAsFixed(2)}',
    snackPosition: SnackPosition.BOTTOM,
  );
}
}