import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../controller/wallets_controller.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_card.dart';
import 'add_wallet_view.dart';
import 'wallet_details_view.dart';

class WalletsView extends GetView<WalletsController> {
  const WalletsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wallets',
          style: AppTextStyles.headingMedium(isDark),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.loadWallets();
          },

          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),

            children: [
              WalletBalanceCard(
                totalBalance: controller.totalBalance,
                currency: controller.wallets.isNotEmpty
                    ? controller.wallets.first.currency
                    : 'PKR',
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Wallets',
                    style: AppTextStyles.headingMedium(isDark),
                  ),

                  Text(
                    '${controller.wallets.length} wallet(s)',
                    style: AppTextStyles.bodyMedium(isDark),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (controller.wallets.isEmpty)
                _EmptyWalletState(isDark: isDark)
              else
                ...controller.wallets.map(
                 (wallet) => WalletCard(
  wallet: wallet,
  onTap: () {
    Get.to(
      () => WalletDetailsView(wallet: wallet),
    );
  },
  onDelete: () {
    _showDeleteDialog(
      context,
      wallet.name,
      wallet.id,
    );
  },
),
                ),
            ],
          ),
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(
            () => const AddWalletView(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Wallet'),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String walletName,
    String walletId,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Wallet'),
        content: Text(
          'Are you sure you want to delete "$walletName"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteWallet(walletId);
              Get.back();
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWalletState extends StatelessWidget {
  final bool isDark;

  const _EmptyWalletState({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 18),

          Text(
            'No wallets yet',
            style: AppTextStyles.headingMedium(isDark),
          ),

          const SizedBox(height: 8),

          Text(
            'Add your first wallet to start tracking your money.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(isDark),
          ),
        ],
      ),
    );
  }
}