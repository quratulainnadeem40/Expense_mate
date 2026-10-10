import 'package:expense_mate/Feature/committee/view/committe_history_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/committe_controller.dart';
import 'add_committee_view.dart';
import 'committee_details_view.dart';
import 'monthly_schedule_view.dart';
import 'payment_tracking_view.dart';
import 'committee_reminders_view.dart';

class CommitteeView extends StatefulWidget {
  const CommitteeView({super.key});

  @override
  State<CommitteeView> createState() => _CommitteeViewState();
}

class _CommitteeViewState extends State<CommitteeView> {
  final CommitteeController committeeController = CommitteeController.instance;

  // Theme-aware neutral colors
  static const Color lightBackground = Color(0xFFF5F6F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF252B35);
  static const Color lightSecondary = Color(0xFF626B78);
  static const Color lightBorder = Color(0xFFDDE1E7);

  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCard = Color(0xFF202124);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkSecondary = Color(0xFFBDBDBD);
  static const Color darkBorder = Color(0xFF383838);

  static const Color greenAccent = Color(0xFF27845D);
  static const Color lightGreen = Color(0xFFE1F3EA);
  static const Color darkGreen = Color(0xFF29483B);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get pageColor => isDark ? darkBackground : lightBackground;

  Color get appBarColor => isDark ? darkBackground : lightCard;

  Color get appBarTextColor => isDark ? darkText : lightText;

  Color get cardColor => isDark ? darkCard : lightCard;

  Color get headingColor => isDark ? darkText : lightText;

  Color get mainTextColor => isDark ? darkText : lightText;

  Color get secondaryColor => isDark ? darkSecondary : lightSecondary;

  Color get borderColor => isDark ? darkBorder : lightBorder;

  Color get greenBackground => isDark ? darkGreen : lightGreen;

  Color get greenText => isDark ? const Color(0xFF9DE0BC) : greenAccent;

  void _openAddCommittee() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCommitteeView()),
    );
  }

  void _openMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommitteeDetailsView(membersOnly: true),
      ),
    );
  }

  void _openCommitteeDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommitteeDetailsView()),
    );
  }

  void _openPaymentTracking() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentTrackingView()),
    );
  }

  void _openMonthlySchedule() {
    if (!committeeController.hasCommittee) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cardColor,
          content: Text(
            'Please add a committee first.',
            style: TextStyle(color: mainTextColor),
          ),
        ),
      );
      return;
    }

    final DateTime? startDate = committeeController.startDate.value;
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cardColor,
          content: Text(
            'Please add a committee first.',
            style: TextStyle(color: mainTextColor),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthlyScheduleView(
          monthlyContribution: committeeController.monthlyContribution.value,
          totalMembers: committeeController.totalMembers.value,
          durationMonths: committeeController.durationInMonths.ceil(),
          startDate: startDate,
        ),
      ),
    );
  }

  void _openReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommitteeRemindersView()),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CommitteeHistoryView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: appBarTextColor,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.groups_rounded),
            SizedBox(width: 8),
            Text('Committee'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digital Committee',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your monthly money pool easily.',
              style: TextStyle(color: secondaryColor),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenAccent,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _openAddCommittee,
                icon: const Icon(Icons.add),
                label: const Text('Add Committee'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Committees',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final committees = committeeController.committees.toList();

              if (committees.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.20 : 0.04,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.groups_rounded, size: 45, color: greenText),
                      const SizedBox(height: 10),
                      Text(
                        'No committee added yet.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: mainTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create your first committee to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryColor),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: committees.map((committee) {
                  return Card(
                    color: cardColor,
                    elevation: 2,
                    shadowColor: Colors.black.withValues(
                      alpha: isDark ? 0.20 : 0.06,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: borderColor),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: greenBackground,
                        foregroundColor: greenText,
                        child: const Icon(Icons.groups_rounded),
                      ),
                      title: Text(
                        committee['name']?.toString() ?? 'Committee',
                        style: TextStyle(
                          color: mainTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'PKR ${committee['contribution'] ?? '0'} monthly',
                        style: TextStyle(color: secondaryColor),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: greenText,
                      ),
                      onTap: () {
                        final String? id = committee['id']?.toString();
                        if (id != null) {
                          committeeController.selectCommittee(id);
                        }
                        _openCommitteeDetails();
                      },
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 28),
            Text(
              'Committee Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              icon: '👥',
              title: 'Members',
              description: 'Manage committee members and their details.',
              onTap: _openMembers,
              iconBackground: isDark
                  ? const Color(0xFF263746)
                  : const Color(0xFFE5F1F7),
              iconColor: isDark
                  ? const Color(0xFF9ED5E8)
                  : const Color(0xFF32758D),
            ),
            _buildFeatureCard(
              icon: '💳',
              title: 'Payment Tracking',
              description:
                  'Track paid, pending and overdue committee payments.',
              onTap: _openPaymentTracking,
              iconBackground: greenBackground,
              iconColor: greenText,
            ),
            _buildFeatureCard(
              icon: '📅',
              title: 'Monthly Schedule',
              description: 'Manage monthly schedule and receiving order.',
              onTap: _openMonthlySchedule,
              iconBackground: isDark
                  ? const Color(0xFF393020)
                  : const Color(0xFFFFF0D8),
              iconColor: isDark
                  ? const Color(0xFFFFD18A)
                  : const Color(0xFF99600D),
            ),
            _buildFeatureCard(
              icon: '🔔',
              title: 'Reminders & Notifications',
              description: 'Manage payment due dates and monthly reminders.',
              onTap: _openReminders,
              iconBackground: isDark
                  ? const Color(0xFF332941)
                  : const Color(0xFFF0E8FA),
              iconColor: isDark
                  ? const Color(0xFFD3B8FF)
                  : const Color(0xFF7650A5),
            ),
            _buildFeatureCard(
              icon: '🕘',
              title: 'Committee History',
              description: 'View completed committees and payment history.',
              onTap: _openHistory,
              iconBackground: isDark
                  ? const Color(0xFF40292A)
                  : const Color(0xFFFBE8E7),
              iconColor: isDark
                  ? const Color(0xFFFFB2AD)
                  : const Color(0xFFAD4944),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Card(
      color: cardColor,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 28)),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: mainTextColor),
        ),
        subtitle: Text(description, style: TextStyle(color: secondaryColor)),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: iconColor,
        ),
        onTap: onTap,
      ),
    );
  }
}
