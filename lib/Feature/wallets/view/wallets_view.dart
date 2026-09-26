import 'package:expense_mate/Core/theme/custom_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/wallets_controller.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_card.dart';
import 'add_wallet_view.dart';
import 'wallet_details_view.dart';

class WalletsView extends StatefulWidget {
  const WalletsView({super.key});

  @override
  State<WalletsView> createState() => _WalletsViewState();
}

class _WalletsViewState extends State<WalletsView> {
  late final WalletsController controller;

  final Set<String> selectedWalletIds = <String>{};

  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();

    controller = Get.find<WalletsController>();
  }

  // ============================================================
  // ENTER SELECTION MODE
  // ============================================================

  void _enterSelectionMode(String walletId) {
    setState(() {
      isSelectionMode = true;
      selectedWalletIds.add(walletId);
    });
  }

  // ============================================================
  // TOGGLE WALLET SELECTION
  // ============================================================

  void _toggleWalletSelection(String walletId) {
    setState(() {
      if (selectedWalletIds.contains(walletId)) {
        selectedWalletIds.remove(walletId);
      } else {
        selectedWalletIds.add(walletId);
      }

      if (selectedWalletIds.isEmpty) {
        isSelectionMode = false;
      }
    });
  }

  // ============================================================
  // EXIT SELECTION MODE
  // ============================================================

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedWalletIds.clear();
    });
  }

  // ============================================================
  // DELETE SELECTED WALLETS
  // ============================================================

  void _deleteSelectedWallets(BuildContext context) {
    if (selectedWalletIds.isEmpty) {
      return;
    }

    final int count = selectedWalletIds.length;

    Get.dialog(
      AlertDialog(
        title: const Text('Delete Wallets'),
        content: Text(
          count == 1
              ? 'Are you sure you want to delete this wallet?'
              : 'Are you sure you want to delete $count wallets?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();

              final idsToDelete = selectedWalletIds.toList();

              for (final walletId in idsToDelete) {
                await controller.deleteWallet(walletId);
              }

              if (mounted) {
                _exitSelectionMode();
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSelectionMode
              ? '${selectedWalletIds.length} selected'
              : 'Wallets',
          style: AppTextStyles.headingMedium(isDark),
        ),

        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _exitSelectionMode,
              )
            : null,

        actions: [
          if (isSelectionMode)
            IconButton(
              tooltip: 'Delete selected wallets',
              onPressed: selectedWalletIds.isEmpty
                  ? null
                  : () => _deleteSelectedWallets(context),
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
            ),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadWallets();
          },

          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),

            children: [
              // ==================================================
              // TOTAL BALANCE
              // ==================================================

              WalletBalanceCard(
                totalBalance: controller.totalBalance,
                currency: controller.wallets.isNotEmpty
                    ? controller.wallets.first.currency
                    : 'PKR',
              ),

              const SizedBox(height: 28),

              // ==================================================
              // MY WALLETS HEADER
              // ==================================================

              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      'My Wallets',
      style: AppTextStyles.headingMedium(isDark),
    ),

    if (!isSelectionMode)
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(() => const AddWalletView());
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 13,
    vertical: 8,
  ),
  decoration: BoxDecoration(
    color: const Color(0xFF2E7D32),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: Color(0xFFE8F5E9),
      width: 1,
    ),
  ),
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.add_rounded,
        size: 18,
        color:Color(0xFFE8F5E9),
      ),
      SizedBox(width: 5),
      Text(
        'Add',
        style: TextStyle(
          color:Color(0xFFE8F5E9),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
)
        ),
      ),
  ],
),

              const SizedBox(height: 14),

              // ==================================================
              // EMPTY STATE
              // ==================================================

              if (controller.wallets.isEmpty)
                _EmptyWalletState(isDark: isDark)

              // ==================================================
              // WALLET LIST
              // ==================================================

              else
                ...controller.wallets.map(
                  (wallet) {
                    final bool isSelected =
                        selectedWalletIds.contains(wallet.id);

                    return WalletCard(
                      wallet: wallet,

                      isSelectionMode: isSelectionMode,

                      isSelected: isSelected,

                      // Normal tap
                      onTap: () {
                        if (isSelectionMode) {
                          _toggleWalletSelection(wallet.id);
                        } else {
                          Get.to(
                            () => WalletDetailsView(
                              wallet: wallet,
                            ),
                          );
                        }
                      },

                      // Long press
                      onLongPress: () {
                        if (!isSelectionMode) {
                          _enterSelectionMode(wallet.id);
                        }
                      },
                    );
                  },
                ),

              const SizedBox(height: 80),
            ],
          ),
        );
      }),

      // ==========================================================
      // ADD WALLET FAB
      // ==========================================================

//       floatingActionButton: FloatingActionButton(
//   heroTag: 'walletAddFab',
//   onPressed: () {
//     Get.to(
//       () => const AddWalletView(),
//     );
//   },
//   backgroundColor: const Color(0xFF2E7D32),
//   foregroundColor: Colors.white,
//   elevation: 6,
//   shape: const CircleBorder(),
//   child: const Icon(
//     Icons.add,
//     size: 30,
//   ),
// ),

// floatingActionButtonLocation:
//     FloatingActionButtonLocation.centerFloat,

      // Bottom center
      
    );
  }
}

// ================================================================
// EMPTY WALLET STATE
// ================================================================

class _EmptyWalletState extends StatelessWidget {
  final bool isDark;

  const _EmptyWalletState({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 70,
      ),
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