import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PrivacyView extends StatefulWidget {
  const PrivacyView({super.key});

  @override
  State<PrivacyView> createState() => _PrivacyViewState();
}

class _PrivacyViewState extends State<PrivacyView> {
  final List<GlobalKey> _sectionKeys = List<GlobalKey>.generate(
    _privacySections.length,
    (_) => GlobalKey(),
  );

  Future<void> _scrollToSection(int index) async {
    final targetContext = _sectionKeys[index].currentContext;
    if (targetContext == null) return;

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.04,
    );
  }

  Future<void> _copyContact(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    Get.snackbar(
      label,
      'Copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Privacy Policy'), centerTitle: true),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 12.0 : 20.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PrivacyHero(isDark: isDark),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, layoutConstraints) {
                          if (layoutConstraints.maxWidth <= 860) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _PrivacyContents(
                                  isDark: isDark,
                                  compact: true,
                                  onSelect: _scrollToSection,
                                ),
                                const SizedBox(height: 16),
                                _document(isDark),
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 240,
                                child: _PrivacyContents(
                                  isDark: isDark,
                                  compact: false,
                                  onSelect: _scrollToSection,
                                ),
                              ),
                              const SizedBox(width: 28),
                              Expanded(child: _document(isDark)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '© ${DateTime.now().year} Innovexa Technologies. '
                        'All rights reserved.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _document(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        border: Border.all(color: AppColors.border(isDark)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.035),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < _privacySections.length; index++)
            _PrivacySection(
              key: _sectionKeys[index],
              index: index,
              section: _privacySections[index],
              isDark: isDark,
              onCopyContact: _copyContact,
              isLast: index == _privacySections.length - 1,
            ),
        ],
      ),
    );
  }
}

class _PrivacyHero extends StatelessWidget {
  const _PrivacyHero({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: isDark ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            'Last updated: 4 October 2026',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Your money, your data.',
          style: TextStyle(
            color: AppColors.textPrimary(isDark),
            fontSize: 38,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            'This policy explains what information Expense Mate collects, '
            'why we collect it, and the choices you have. We have kept it '
            'short and in plain language.',
            style: TextStyle(
              color: AppColors.textSecondary(isDark),
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 700
                ? 3
                : constraints.maxWidth >= 450
                ? 2
                : 1;
            final cardWidth =
                (constraints.maxWidth - 14 * (columns - 1)) / columns;

            return Wrap(
              spacing: 14,
              runSpacing: 12,
              children: [
                _PrivacyFeatureCard(
                  width: cardWidth,
                  isDark: isDark,
                  icon: Icons.lock_outline_rounded,
                  title: 'Password protected',
                  description: 'Your account is secured with your own login.',
                ),
                _PrivacyFeatureCard(
                  width: cardWidth,
                  isDark: isDark,
                  icon: Icons.cloud_done_outlined,
                  title: 'Automatic cloud backup',
                  description: 'Your history stays safe if you change phones.',
                ),
                _PrivacyFeatureCard(
                  width: cardWidth,
                  isDark: isDark,
                  icon: Icons.block_outlined,
                  title: 'No ads, no data selling',
                  description:
                      'We never sell or share data with advertisers.',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PrivacyFeatureCard extends StatelessWidget {
  const _PrivacyFeatureCard({
    required this.width,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.description,
  });

  final double width;
  final bool isDark;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: width,
      child: Container(
        constraints: const BoxConstraints(minHeight: 104),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          border: Border.all(color: AppColors.border(isDark)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyContents extends StatelessWidget {
  const _PrivacyContents({
    required this.isDark,
    required this.compact,
    required this.onSelect,
  });

  final bool isDark;
  final bool compact;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        border: Border.all(color: AppColors.border(isDark)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'CONTENTS',
              style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (compact)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (var index = 0; index < _privacySections.length; index++)
                  ActionChip(
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: AppColors.border(isDark)),
                    backgroundColor: AppColors.card(isDark),
                    label: Text(
                      '${index + 1}. ${_privacySections[index].title}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                    onPressed: () => onSelect(index),
                  ),
              ],
            )
          else
            for (var index = 0; index < _privacySections.length; index++)
              TextButton(
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  foregroundColor: AppColors.textSecondary(isDark),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                onPressed: () => onSelect(index),
                child: Text(
                  '${index + 1}. ${_privacySections[index].title}',
                  style: const TextStyle(fontSize: 13, height: 1.3),
                ),
              ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Divider(color: AppColors.border(isDark)),
            Text(
              'Jump to any section',
              style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
    super.key,
    required this.index,
    required this.section,
    required this.isDark,
    required this.onCopyContact,
    required this.isLast,
  });

  final int index;
  final _PrivacySectionData section;
  final bool isDark;
  final Future<void> Function(String value, String label) onCopyContact;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bodyStyle = TextStyle(
      color: AppColors.textSecondary(isDark),
      fontSize: 14,
      height: 1.65,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
      child: Container(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: AppColors.border(isDark)),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      color: AppColors.textPrimary(isDark),
                      fontSize: 19,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final subsection in section.subsections) ...[
              Text(
                subsection.title,
                style: TextStyle(
                  color: AppColors.textPrimary(isDark),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              for (final paragraph in subsection.paragraphs) ...[
                Text(paragraph, style: bodyStyle),
                const SizedBox(height: 8),
              ],
              for (final bullet in subsection.bullets)
                _PrivacyBullet(text: bullet, style: bodyStyle),
              const SizedBox(height: 6),
            ],
            for (final paragraph in section.paragraphs) ...[
              Text(paragraph, style: bodyStyle),
              const SizedBox(height: 8),
            ],
            for (final bullet in section.bullets)
              _PrivacyBullet(text: bullet, style: bodyStyle),
            if (section.note != null) ...[
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.15 : 0.08),
                  border: Border(left: BorderSide(color: primary, width: 4)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(section.note!, style: bodyStyle),
              ),
            ],
            if (index == _privacySections.length - 1) ...[
              const SizedBox(height: 5),
              _PrivacyContactTile(
                isDark: isDark,
                icon: Icons.email_outlined,
                text: 'innovexa.technologies01@gmail.com',
                onTap: () => onCopyContact(
                  'innovexa.technologies01@gmail.com',
                  'Email address',
                ),
              ),
              const SizedBox(height: 9),
              _PrivacyContactTile(
                isDark: isDark,
                icon: Icons.language_rounded,
                text: 'innovexa-technologies.vercel.app',
                onTap: () => onCopyContact(
                  'https://innovexa-technologies.vercel.app',
                  'Website link',
                ),
              ),
              const SizedBox(height: 9),
              _PrivacyContactTile(
                isDark: isDark,
                icon: Icons.business_outlined,
                text: 'Innovexa Technologies',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrivacyBullet extends StatelessWidget {
  const _PrivacyBullet({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Icon(
              Icons.circle,
              size: 6,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

class _PrivacyContactTile extends StatelessWidget {
  const _PrivacyContactTile({
    required this.isDark,
    required this.icon,
    required this.text,
    this.onTap,
  });

  final bool isDark;
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background(isDark),
        border: Border.all(color: AppColors.border(isDark)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: primary),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: TextStyle(
                color: onTap == null
                    ? AppColors.textPrimary(isDark)
                    : primary,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.copy_rounded,
              size: 16,
              color: AppColors.textSecondary(isDark),
            ),
          ],
        ],
      ),
    );

    return onTap == null
        ? child
        : Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: child,
            ),
          );
  }
}

class _PrivacySubsectionData {
  const _PrivacySubsectionData({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}

class _PrivacySectionData {
  const _PrivacySectionData({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
    this.subsections = const [],
    this.note,
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  final List<_PrivacySubsectionData> subsections;
  final String? note;
}

const List<_PrivacySectionData> _privacySections = [
  _PrivacySectionData(
    title: 'Introduction',
    paragraphs: [
      'Expense Mate ("the app") is a personal money manager provided by '
          'Innovexa Technologies ("we", "us"). By creating an account and '
          'using the app, you agree to the practices described in this Privacy '
          'Policy. If you do not agree, please do not use the app.',
    ],
  ),
  _PrivacySectionData(
    title: 'Information we collect',
    subsections: [
      _PrivacySubsectionData(
        title: 'Account information',
        paragraphs: [
          'When you sign up we collect your email address and the details '
              'needed to secure your account, such as your password (stored in '
              'protected form) and the name you add to your profile.',
        ],
      ),
      _PrivacySubsectionData(
        title: 'Financial records you enter',
        paragraphs: ['The app only holds what you choose to record:'],
        bullets: [
          'Transactions (income and expenses), notes, categories and dates',
          'Wallets and their balances (cash, bank, JazzCash, Easypaisa, credit card)',
          'Budgets, goals, bills and reminders',
          'Digital Committee details, such as member names and payment status',
        ],
      ),
      _PrivacySubsectionData(
        title: 'Settings and device permissions',
        paragraphs: [
          'We store your preferences (currency, light or dark theme, '
              'notification choices). If you allow notifications, the app uses '
              'them to remind you about bills and due dates. You can turn this '
              'off at any time in your phone settings.',
        ],
      ),
    ],
    paragraphs: [
      'We do not ask for your bank login, card numbers, PINs or mobile-wallet '
          'passwords. The app does not move real money; it is a record-keeping tool.',
    ],
  ),
  _PrivacySectionData(
    title: 'How we use your information',
    bullets: [
      'To run the app: show your balances, budgets, goals, reports and reminders',
      'To back up your data and sync it to your account so you keep your '
          'history on a new phone',
      'To keep your account secure and prevent misuse',
      'To reply when you contact support',
      'To fix problems and improve the app',
    ],
    note: 'We do not use your financial records for advertising, and we do not '
        'build advertising profiles about you.',
  ),
  _PrivacySectionData(
    title: 'Cloud storage and sharing',
    paragraphs: [
      'Your data is stored in your account on secure cloud infrastructure so '
          'it can sync and be backed up. Only you can see your records.',
      'We never sell your personal information and we do not share it with '
          'advertisers. We may share limited information only:',
    ],
    bullets: [
      'With service providers who host or secure the app for us, and only as '
          'needed to provide the service',
      'When required by law, or to protect our users, our rights or the safety '
          'of others',
    ],
  ),
  _PrivacySectionData(
    title: 'Data security',
    paragraphs: [
      'We use reasonable technical and organisational measures to protect '
          'your information, including account authentication and encrypted '
          'connections. No method of storage or transmission is completely '
          'secure, so we cannot guarantee absolute security. Please choose a '
          'strong password and keep it private.',
    ],
  ),
  _PrivacySectionData(
    title: 'Data retention and deletion',
    paragraphs: [
      'We keep your data for as long as your account is active. You can edit '
          'or delete individual transactions and other records inside the app '
          'at any time.',
      'To delete your account and the data linked to it, email us at '
          'innovexa.technologies01@gmail.com from the address you registered '
          'with. We will remove your data within a reasonable time, except for '
          'anything we are legally required to keep.',
    ],
  ),
  _PrivacySectionData(
    title: 'Your choices and rights',
    bullets: [
      'Access and correction: view and edit your records in the app',
      'Deletion: delete records yourself or ask us to delete your account',
      'Notifications: switch reminders off in the app or your phone settings',
      'Questions: contact us any time about how your data is handled',
    ],
  ),
  _PrivacySectionData(
    title: 'Information about other people',
    paragraphs: [
      'Features such as Digital Committee let you enter names and payment '
          'details of other people. Please add only information you are allowed '
          'to share, and use it only for managing your own committee or records.',
    ],
  ),
  _PrivacySectionData(
    title: "Children's privacy",
    paragraphs: [
      'The app is not intended for children under 13, and we do not knowingly '
          'collect their information. If you believe a child has given us '
          'personal data, contact us and we will delete it.',
    ],
  ),
  _PrivacySectionData(
    title: 'Changes to this policy',
    paragraphs: [
      'We may update this policy from time to time. When we do, we will change '
          'the "Last updated" date at the top. Continued use of the app after a '
          'change means you accept the updated policy.',
    ],
  ),
  _PrivacySectionData(
    title: 'Contact us',
    paragraphs: ['Questions about this policy or your data? Reach us here:'],
  ),
];
