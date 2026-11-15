import 'package:flutter/material.dart';

import '../../screens/about_screen.dart';
import '../../screens/contact_screen.dart';
import '../theme/app_colors.dart';

class StorefrontFooter extends StatefulWidget {
  const StorefrontFooter({super.key});

  @override
  State<StorefrontFooter> createState() => _StorefrontFooterState();
}

class _StorefrontFooterState extends State<StorefrontFooter> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    padding: const EdgeInsets.fromLTRB(28, 48, 28, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 700 ? 2 : 4;
            final width = (constraints.maxWidth - 36) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 28,
              children: [
                SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SONICFLOW',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sound, considered. Tools for people who listen closely.',
                        style: TextStyle(color: AppColors.muted, height: 1.6),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email address',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _subscribe,
                          child: const Text('Join the listening list'),
                        ),
                      ),
                    ],
                  ),
                ),
                _footerColumn(width, 'PRODUCTS', [
                  'Over-Ear',
                  'True Wireless',
                  'Studio',
                  'Gaming',
                ]),
                _footerColumn(width, 'SUPPORT', [
                  'Warranty',
                  'Frequency Charts',
                  'Burn-in Guide',
                  'Contact',
                ]),
                _footerColumn(width, 'STAY IN TUNE', [
                  'About SonicFlow',
                  'Craft & materials',
                  'Sonic journal',
                  'Instagram',
                ]),
              ],
            );
          },
        ),
        const SizedBox(height: 38),
        const Divider(),
        const SizedBox(height: 14),
        Text(
          '© 2026 SONICFLOW AUDIO. BUILT FOR THE WAY YOU LISTEN.',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    ),
  );

  Widget _footerColumn(
    double width,
    String title,
    List<String> links,
  ) => SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextButton(
              onPressed: () => _openLink(link),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              child: Text(link, style: TextStyle(color: AppColors.muted)),
            ),
          ),
      ],
    ),
  );

  void _openLink(String link) {
    final Widget? page = switch (link) {
      'Contact' => const ContactScreen(),
      'About SonicFlow' || 'Craft & materials' || 'Sonic journal' =>
        const AboutScreen(),
      _ => null,
    };

    if (page != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => page),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$link information is available through our support team.',
        ),
      ),
    );
  }

  void _subscribe() {
    final valid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(_email.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          valid
              ? 'You are on the list. Watch your inbox.'
              : 'Enter a valid email address to subscribe.',
        ),
      ),
    );
    if (valid) _email.clear();
  }
}
