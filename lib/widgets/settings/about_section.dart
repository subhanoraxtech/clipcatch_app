import 'package:flutter/material.dart';
import 'package:video_downloader/screens/legal_content_screen.dart';
import 'package:video_downloader/theme/app_theme.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final mutedColor = AppTheme.textMutedFor(brightness);
    final cardBg = AppTheme.surfaceFor(brightness).withOpacity01(brightness == Brightness.dark ? 0.55 : 0.92);
    final dividerColor = AppTheme.borderFor(brightness).withOpacity01(brightness == Brightness.dark ? 0.9 : 0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'ABOUT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: mutedColor,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderFor(brightness)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity01(brightness == Brightness.dark ? 0.2 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAboutTile(
                context,
                icon: Icons.info_outline_rounded,
                title: 'App Version',
                trailing: Text(
                  '1.0.0 (Build 12)',
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
              ),
              Divider(height: 1, color: dividerColor, indent: 56),
              _buildAboutTile(
                context,
                icon: Icons.description_rounded,
                title: 'Terms of Service',
                trailing: Icon(Icons.open_in_new_rounded, size: 16, color: mutedColor),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalContentScreen(
                        title: 'Terms of Service',
                        content: _termsContent,
                      ),
                    ),
                  );
                },
              ),
              Divider(height: 1, color: dividerColor, indent: 56),
              _buildAboutTile(
                context,
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                trailing: Icon(Icons.open_in_new_rounded, size: 16, color: mutedColor),
                isLast: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalContentScreen(
                        title: 'Privacy Policy',
                        content: _privacyContent,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast 
        ? const BorderRadius.vertical(bottom: Radius.circular(24))
        : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppTheme.primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

const String _termsContent = '''
Welcome to ClipCatch! By using our service, you agree to these terms.

1. ACCEPTANCE OF TERMS
By accessing or using ClipCatch, you agree to be bound by these Terms of Service. If you do not agree, please do not use the app.

2. SERVICE DESCRIPTION
ClipCatch is a video downloader utility. You are solely responsible for the content you download and must ensure you have the legal right to do so.

3. USER CONDUCT
You agree not to use the service for any illegal purposes or to infringe upon the intellectual property rights of others.

4. INTELLECTUAL PROPERTY
The ClipCatch app and its original content, features, and functionality are owned by ClipCatch Inc. and protected by international laws.

5. TERMINATION
We may terminate or suspend access to our service immediately, without prior notice or liability, for any reason whatsoever.

6. LIMITATION OF LIABILITY
In no event shall ClipCatch be liable for any indirect, incidental, special, consequential, or punitive damages.

7. CHANGES TO TERMS
We reserve the right to modify or replace these terms at any time. Your continued use of the app after changes constitutes acceptance.
''';

const String _privacyContent = '''
Your privacy is important to us. This Privacy Policy explains how we handle your information.

1. INFORMATION COLLECTION
ClipCatch is designed to protect your privacy. We do not collect personally identifiable information from our users.

2. LOG DATA
When you use our service, we may collect information that your device sends, such as device model, OS version, and app performance data for optimization purposes.

3. SERVICE PROVIDERS
We may employ third-party companies and individuals to facilitate our service, perform service-related tasks, or assist us in analyzing how our service is used.

4. SECURITY
We value your trust in providing us your information, thus we are striving to use commercially acceptable means of protecting it.

5. LINKS TO OTHER SITES
Our service may contain links to other sites. If you click on a third-party link, you will be directed to that site.

6. CHILDREN'S PRIVACY
Our services do not address anyone under the age of 13. We do not knowingly collect personal identifiable information from children under 13.

7. CONTACT US
If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at support@clipcatch.app.
''';
