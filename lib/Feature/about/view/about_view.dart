import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:expense_mate/Core/theme/custom_colors.dart';

/// About screen for Expense Mate.
///
/// Update the constants below before you publish — they are the only
/// values you need to change.
class AboutView extends StatelessWidget {
  const AboutView({super.key});

  // -----------------------------------------------------------------
  // EDIT THESE BEFORE PUBLISHING
  // -----------------------------------------------------------------
  static const String appName = 'Expense Mate';
  static const String tagline = 'Track • Save • Grow';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  static const String developerName = '[YOUR NAME OR COMPANY]';
  static const String supportEmail = '[YOUR SUPPORT EMAIL]';
  static const String websiteUrl = '[YOUR WEBSITE]';
  static const String privacyPolicyUrl = '[YOUR PRIVACY POLICY URL]';
  static const String termsUrl = '[YOUR TERMS URL]';
  static const String packageName = '[YOUR PACKAGE NAME]';
  static const int copyrightYear = 2026;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary(isDark),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          physics: const BouncingScrollPhysics(),
          children: [
            _Header(isDark: isDark),

            const SizedBox(height: 28),

            _Section(
              isDark: isDark,
              title: 'What is Expense Mate?',
              child: Text(
                'Expense Mate is a personal money manager that helps you see '
                'exactly where your money goes. Record every income and '
                'expense, set a budget for the month, keep your cash and '
                'bank accounts separate, and get a clear picture of your '
                'spending at the end of every month.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.65,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _Section(
              isDark: isDark,
              title: 'What you can do',
              child: Column(
                children: const [
                  _Feature(
                    icon: Icons.swap_horiz_rounded,
                    colour: Color(0xFF2EA44F),
                    title: 'Income & expenses',
                    detail:
                        'Record every transaction with a category, wallet '
                        'and note.',
                  ),
                  _Feature(
                    icon: Icons.pie_chart_rounded,
                    colour: Color(0xFFFF9800),
                    title: 'Monthly budgets',
                    detail:
                        'Set a limit for the month and watch how much is '
                        'left as you spend.',
                  ),
                  _Feature(
                    icon: Icons.account_balance_wallet_rounded,
                    colour: Color(0xFF2B82FB),
                    title: 'Multiple wallets',
                    detail:
                        'Cash, bank account, JazzCash, Easypaisa, credit '
                        'card — each with its own balance.',
                  ),
                  _Feature(
                    icon: Icons.category_rounded,
                    colour: Color(0xFF7E57C2),
                    title: 'Custom categories',
                    detail:
                        'Build your own income and expense categories to '
                        'match how you actually spend.',
                  ),
                  _Feature(
                    icon: Icons.stars_rounded,
                    colour: Color(0xFFE91E63),
                    title: 'Savings goals',
                    detail:
                        'Set a target amount and track how close you are '
                        'to reaching it.',
                  ),
                  _Feature(
                    icon: Icons.notifications_active_rounded,
                    colour: Color(0xFF9C27B0),
                    title: 'Bills & reminders',
                    detail:
                        'Get notified before a bill is due so nothing is '
                        'missed.',
                  ),
                  _Feature(
                    icon: Icons.bar_chart_rounded,
                    colour: Color(0xFF00BCD4),
                    title: 'Reports & charts',
                    detail:
                        'See your spending broken down by category and by '
                        'month.',
                  ),
                  _Feature(
                    icon: Icons.dark_mode_rounded,
                    colour: Color(0xFF607D8B),
                    title: 'Light & dark mode',
                    detail:
                        'A true black dark theme that is easy on the eyes '
                        'and on the battery.',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _Section(
              isDark: isDark,
              title: 'Your data',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your transactions are tied to your account and synced '
                    'securely to the cloud, so you keep your history even if '
                    'you change your phone. Only you can see your data — it '
                    'is never sold or shared with advertisers.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.65,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _MiniRow(
                    isDark: isDark,
                    icon: Icons.lock_outline_rounded,
                    text: 'Password protected account',
                  ),
                  _MiniRow(
                    isDark: isDark,
                    icon: Icons.cloud_done_outlined,
                    text: 'Automatic cloud backup',
                  ),
                  _MiniRow(
                    isDark: isDark,
                    icon: Icons.block_outlined,
                    text: 'No ads, no data selling',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _Section(
              isDark: isDark,
              title: 'App information',
              padded: false,
              child: Column(
                children: [
                  _InfoTile(
                    isDark: isDark,
                    label: 'Version',
                    value: '$appVersion ($buildNumber)',
                  ),
                  _InfoTile(
                    isDark: isDark,
                    label: 'Currency',
                    value: 'PKR — Pakistani Rupee',
                  ),
                  _InfoTile(
                    isDark: isDark,
                    label: 'Developer',
                    value: developerName,
                  ),
                  _InfoTile(
                    isDark: isDark,
                    label: 'Package',
                    value: packageName,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _Section(
              isDark: isDark,
              title: 'Support & legal',
              padded: false,
              child: Column(
                children: [
                  _ActionTile(
                    isDark: isDark,
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact support',
                    subtitle: supportEmail,
                    onTap: () => _copy(supportEmail, 'Email address copied'),
                  ),
                  _ActionTile(
                    isDark: isDark,
                    icon: Icons.language_rounded,
                    title: 'Website',
                    subtitle: websiteUrl,
                    onTap: () => _copy(websiteUrl, 'Link copied'),
                  ),
                  _ActionTile(
                    isDark: isDark,
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy policy',
                    subtitle: privacyPolicyUrl,
                    onTap: () => _copy(privacyPolicyUrl, 'Link copied'),
                  ),
                  _ActionTile(
                    isDark: isDark,
                    icon: Icons.description_outlined,
                    title: 'Terms of service',
                    subtitle: termsUrl,
                    onTap: () => _copy(termsUrl, 'Link copied'),
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Center(
              child: Text(
                'Made with Flutter',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '© $copyrightYear $developerName. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copy(String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    Get.snackbar(
      'Copied',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}

// =====================================================================
// HEADER
// =====================================================================
class _Header extends StatelessWidget {
  const _Header({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.card(isDark),
            border: Border.all(color: AppColors.border(isDark)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          // Swap this for your final icon asset if the name changes.
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.account_balance_wallet_rounded,
              size: 44,
              color: Color(0xFF2EA44F),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AboutView.appName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(isDark),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AboutView.tagline,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
            color: Color(0xFF2EA44F),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF2EA44F).withOpacity(isDark ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Version ${AboutView.appVersion}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2EA44F),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// SECTION SHELL
// =====================================================================
class _Section extends StatelessWidget {
  const _Section({
    required this.isDark,
    required this.title,
    required this.child,
    this.padded = true,
  });

  final bool isDark;
  final String title;
  final Widget child;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: padded ? const EdgeInsets.all(18) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: AppColors.card(isDark),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border(isDark)),
          ),
          child: child,
        ),
      ],
    );
  }
}

// =====================================================================
// FEATURE ROW
// =====================================================================
class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.colour,
    required this.title,
    required this.detail,
    this.isLast = false,
  });

  final IconData icon;
  final Color colour;
  final String title;
  final String detail;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colour.withOpacity(isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: colour),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SMALL BULLET ROW
// =====================================================================
class _MiniRow extends StatelessWidget {
  const _MiniRow({
    required this.isDark,
    required this.icon,
    required this.text,
    this.isLast = false,
  });

  final bool isDark;
  final IconData icon;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Icon(icon, size: 17, color: const Color(0xFF2EA44F)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// LABEL / VALUE ROW
// =====================================================================
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.isDark,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final bool isDark;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.border(isDark))),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// TAPPABLE ROW
// =====================================================================
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
  });

  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: AppColors.border(isDark))),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2EA44F)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.textSecondary(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}