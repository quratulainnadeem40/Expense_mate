import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:expense_mate/Core/Database/sync/sync_manager.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({
    super.key,
    this.showLabel = true,
  });

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final syncManager = Get.find<SyncManager>();

    return Obx(() {
      final status = syncManager.syncStatus.value;
      final pending = syncManager.pendingCount.value;

      IconData icon;
      Color color;

      switch (status) {
        case 'Syncing...':
          icon = Icons.sync;
          color = Colors.orange;
          break;

        case 'Pending':
          icon = Icons.cloud_upload_outlined;
          color = Colors.orange;
          break;

        case 'Sync failed':
          icon = Icons.cloud_off_outlined;
          color = Colors.red;
          break;

        case 'Not signed in':
          icon = Icons.person_off_outlined;
          color = Colors.grey;
          break;

        case 'Synced':
        default:
          icon = Icons.cloud_done_outlined;
          color = Colors.green;
      }

      if (!showLabel) {
        return Icon(
          icon,
          color: color,
          size: 22,
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            pending > 0 && status == 'Pending'
                ? 'Pending ($pending)'
                : status,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    });
  }
}