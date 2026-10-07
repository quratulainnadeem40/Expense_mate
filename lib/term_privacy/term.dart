import 'package:expense_mate/Core/theme/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class TermsView extends StatefulWidget {
  const TermsView({super.key});

  @override
  State<TermsView> createState() => _TermsViewState();
}

class _TermsViewState extends State<TermsView> {
  final List<GlobalKey> _sectionKeys = List<GlobalKey>.generate(
    _termsSections.length,
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
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
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
                      _Hero(isDark: isDark),
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, layoutConstraints) {
                          if (layoutConstraints.maxWidth <= 860) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _Contents(
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
                                child: _Contents(
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
          for (var index = 0; index < _termsSections.length; index++)
            _TermsSection(
              key: _sectionKeys[index],
              index: index,
              section: _termsSections[index],
              isDark: isDark,
              onCopyContact: _copyContact,
              isLast: index == _termsSections.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.isDark});

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
          'Terms & Conditions',
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
            'Please read these terms before using Expense Mate. They explain '
            'the rules for using the app and what you can expect from us.',
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
                _FeatureCard(
                  width: cardWidth,
                  isDark: isDark,
                  icon: Icons.menu_book_rounded,
                  title: 'A record-keeping tool',
                  description:
                      'The app tracks money. It does not hold or move it.',
                ),
                _FeatureCard(
                  width: cardWidth,
                  isDark: isDark,
                  icon: Icons.lock_outline_rounded,
                  title: 'Your account, your care',
                  description:
                      'Keep your password private and your details correct.',
                ),
                _FeatureCard(
                  width: cardWidth,
                  isDark: isDark,
                  icon: Icons.handshake_outlined,
                  title: 'Fair use',
                  description:
                      "Use the app lawfully and respect other "
                      "people's information.",
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
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

class _Contents extends StatelessWidget {
  const _Contents({
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
                for (var index = 0; index < _termsSections.length; index++)
                  ActionChip(
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: AppColors.border(isDark)),
                    backgroundColor: AppColors.card(isDark),
                    label: Text(
                      '${index + 1}. ${_termsSections[index].title}',
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
            for (var index = 0; index < _termsSections.length; index++)
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
                  '${index + 1}. ${_termsSections[index].title}',
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

class _TermsSection extends StatelessWidget {
  const _TermsSection({
    super.key,
    required this.index,
    required this.section,
    required this.isDark,
    required this.onCopyContact,
    required this.isLast,
  });

  final int index;
  final _TermsSectionData section;
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
              : Border(bottom: BorderSide(color: AppColors.border(isDark))),
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
            for (
              var paragraphIndex = 0;
              paragraphIndex < section.paragraphs.length;
              paragraphIndex++
            ) ...[
              if (index == 0 && paragraphIndex == 0)
                Text.rich(
                  TextSpan(
                    style: bodyStyle,
                    children: [
                      const TextSpan(
                        text:
                            'These Terms & Conditions ("Terms") are an '
                            'agreement between you and ',
                      ),
                      TextSpan(
                        text: 'Innovexa Technologies',
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(
                        text:
                            ' ("we", "us") for the use of Expense Mate '
                            '("the app"). By creating an account or using the '
                            'app you confirm that you have read and accepted '
                            'these Terms and our Privacy Policy. If you do '
                            'not agree, please do not use the app.',
                      ),
                    ],
                  ),
                )
              else
                Text(section.paragraphs[paragraphIndex], style: bodyStyle),
              const SizedBox(height: 8),
            ],
            if (section.note != null) ...[
              const SizedBox(height: 4),
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
                child: Text.rich(
                  TextSpan(
                    style: bodyStyle,
                    children: [
                      TextSpan(
                        text: '${section.noteTitle ?? ''} ',
                        style: TextStyle(
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: section.note),
                    ],
                  ),
                ),
              ),
            ],
            if (section.bullets.isNotEmpty) ...[
              if (section.paragraphs.isEmpty) const SizedBox(height: 1),
              for (final bullet in section.bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 9),
                        child: Icon(Icons.circle, size: 6, color: primary),
                      ),
                      const SizedBox(width: 11),
                      Expanded(child: Text(bullet, style: bodyStyle)),
                    ],
                  ),
                ),
            ],
            if (index == _termsSections.length - 1) ...[
              const SizedBox(height: 5),
              _ContactTile(
                isDark: isDark,
                icon: Icons.email_outlined,
                text: 'innovexa.technologies01@gmail.com',
                onTap: () => onCopyContact(
                  'innovexa.technologies01@gmail.com',
                  'Email address',
                ),
              ),
              const SizedBox(height: 9),
              _ContactTile(
                isDark: isDark,
                icon: Icons.language_rounded,
                text: 'innovexa-technologies.vercel.app',
                onTap: () => onCopyContact(
                  'https://innovexa-technologies.vercel.app',
                  'Website link',
                ),
              ),
              const SizedBox(height: 9),
              _ContactTile(
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

class _ContactTile extends StatelessWidget {
  const _ContactTile({
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
                color: onTap == null ? AppColors.textPrimary(isDark) : primary,
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

class _TermsSectionData {
  const _TermsSectionData({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
    this.noteTitle,
    this.note,
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  final String? noteTitle;
  final String? note;
}

const List<_TermsSectionData> _termsSections = [
  _TermsSectionData(
    title: 'Acceptance of terms',
    paragraphs: [
      'These Terms & Conditions ("Terms") are an agreement between you and '
          'Innovexa Technologies ("we", "us") for the use of Expense Mate '
          '("the app"). By creating an account or using the app you confirm '
          'that you have read and accepted these Terms and our Privacy Policy. '
          'If you do not agree, please do not use the app.',
    ],
  ),
  _TermsSectionData(
    title: 'Eligibility and your account',
    bullets: [
      'You must be at least 13 years old, and old enough to enter a binding '
          'agreement where you live, or have a parent or guardian\'s permission.',
      'You must give accurate information when you sign up and keep it up to date.',
      'You are responsible for your password and for everything done through '
          'your account. Tell us promptly if you think someone else has accessed it.',
      'One person should use one account. Do not share your login with others.',
    ],
  ),
  _TermsSectionData(
    title: 'What the app does',
    paragraphs: [
      'The app helps you record income and expenses, manage wallets, budgets, '
          'goals, bills and reminders, run a digital committee, and view reports.',
    ],
    noteTitle: 'Important:',
    note:
        'Expense Mate is a personal record-keeping tool. It is not a bank, '
        'payment service, wallet provider or lender, and it does not move real '
        'money. Wallet names such as cash, bank, JazzCash, Easypaisa or credit '
        'card are labels for your own records and are not linked to those companies.',
  ),
  _TermsSectionData(
    title: 'Not financial advice',
    paragraphs: [
      'Reports, budgets, charts and goals are shown only from the figures you '
          'enter. They are for general information and are not financial, tax, '
          'legal or investment advice. You are responsible for your own financial '
          'decisions and for checking that your records match your real accounts.',
    ],
  ),
  _TermsSectionData(
    title: 'Your content',
    paragraphs: [
      'You own the information you enter (transactions, notes, categories, '
          'committee details and so on). You give us permission to store, back '
          'up and process it only so that we can run the app for you, as explained '
          'in the Privacy Policy. You are responsible for the accuracy of what '
          'you enter and for having the right to enter it.',
    ],
  ),
  _TermsSectionData(
    title: 'Digital Committee',
    paragraphs: [
      'The Digital Committee feature is a record book only. We are not a party '
          'to any committee arrangement and we do not collect, hold, guarantee '
          'or pay out any committee money. Any dispute about payments, turns or '
          'payouts is between the committee members. You must have the consent '
          'of members whose details you add, and you should not rely on the app '
          'as proof of payment without other evidence.',
    ],
  ),
  _TermsSectionData(
    title: 'Reminders and notifications',
    paragraphs: [
      'Bill and goal reminders are a convenience. They depend on your phone '
          'settings, battery optimisation, internet connection and permissions, '
          'so we cannot guarantee that every reminder will arrive on time. '
          'Please do not rely on them as your only way to remember a payment.',
    ],
  ),
  _TermsSectionData(
    title: 'Acceptable use',
    paragraphs: ['You agree not to:'],
    bullets: [
      'use the app for anything unlawful, fraudulent or harmful, including '
          'money laundering or hiding illegal income',
      'try to access another person\'s account or data, or interfere with the '
          'app\'s security',
      'copy, reverse engineer, resell or misuse the app or its code, except '
          'where the law allows',
      'upload malicious code or overload our systems with automated requests',
      'enter other people\'s personal information without a right to do so',
    ],
  ),
  _TermsSectionData(
    title: 'Availability and updates',
    paragraphs: [
      'We work to keep the app running smoothly, but it is provided without a '
          'promise of uninterrupted or error-free service. We may update, change, '
          'add or remove features, or pause the service for maintenance. Some '
          'updates may be needed to keep using the app.',
    ],
  ),
  _TermsSectionData(
    title: 'Intellectual property',
    paragraphs: [
      'The app, its name, logo, design and software belong to Innovexa '
          'Technologies or its licensors and are protected by law. We give you '
          'a personal, limited, non-exclusive, non-transferable right to use '
          'the app for your own use. No other rights are granted.',
    ],
  ),
  _TermsSectionData(
    title: 'Suspension and termination',
    paragraphs: [
      'You may stop using the app and ask us to delete your account at any time '
          '(see the Privacy Policy). We may suspend or close an account that '
          'breaks these Terms or puts the app or other users at risk. After '
          'closure your data is handled as described in the Privacy Policy.',
    ],
  ),
  _TermsSectionData(
    title: 'Disclaimer and limit of liability',
    paragraphs: [
      'The app is provided "as is" and "as available". To the fullest extent '
          'allowed by law, we do not promise that it will be error-free, always '
          'available, or that calculations will meet your needs, and we are not '
          'responsible for losses caused by incorrect entries, lost devices, '
          'forgotten passwords, missed reminders, third-party services, or '
          'events outside our control.',
      'To the extent the law allows, our total liability for any claim connected '
          'with the app is limited to the amount you paid us for it (which may '
          'be nothing), and we are not liable for indirect or consequential loss. '
          'Nothing in these Terms limits any right you have that cannot be '
          'limited by law.',
    ],
  ),
  _TermsSectionData(
    title: 'Governing law',
    paragraphs: [
      'These Terms are governed by the laws of Pakistan. Any dispute will be '
          'handled by the competent courts of Pakistan, unless the law of your '
          'country gives you the right to bring a claim elsewhere. We encourage '
          'you to contact us first so we can try to sort it out.',
    ],
  ),
  _TermsSectionData(
    title: 'Changes to these terms',
    paragraphs: [
      'We may update these Terms from time to time. When we do, we will change '
          'the "Last updated" date above. If you keep using the app after a '
          'change, you accept the updated Terms.',
    ],
  ),
  _TermsSectionData(
    title: 'Contact us',
    paragraphs: ['Questions about these Terms? Get in touch:'],
  ),
];
