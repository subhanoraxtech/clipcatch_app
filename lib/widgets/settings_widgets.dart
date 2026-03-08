import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/main.dart';

/// The subscription status card with upgrade / cancel toggle.
class SubscriptionCard extends StatefulWidget {
  const SubscriptionCard({super.key});

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  bool _isPremium = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.card_membership, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Subscription Status',
              style: TextStyle(
                color: isDark ? AppTheme.textDark : AppTheme.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isPremium
                  ? [
                      AppTheme.primaryColor.withValues(alpha: 0.6),
                      AppTheme.primaryColor.withValues(alpha: 0.2),
                      AppTheme.primaryColor.withValues(alpha: 0.6),
                    ]
                  : [
                      Colors.grey.withValues(alpha: 0.3),
                      Colors.grey.withValues(alpha: 0.1),
                      Colors.grey.withValues(alpha: 0.3),
                    ],
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              children: [
                // Plan info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPremium ? 'CURRENT PLAN' : 'UPGRADE TO PREMIUM',
                          style: TextStyle(
                            color: _isPremium ? AppTheme.primaryColor : Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isPremium ? 'Premium Plus' : 'Free Tier',
                          style: TextStyle(
                            color: isDark ? AppTheme.textDark : AppTheme.textLight,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _isPremium ? '₹1000' : '₹0',
                              style: TextStyle(
                                color: isDark ? AppTheme.textDark : AppTheme.textLight,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('/month', style: TextStyle(color: secondaryTextColor, fontSize: 14)),
                          ],
                        ),
                        if (_isPremium)
                          const Text(
                            'Active until Nov 2024',
                            style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action buttons
                if (_isPremium) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Status', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppTheme.surfaceDark : const Color(0xFFF1F5F9),
                        foregroundColor: isDark ? AppTheme.textMutedLight : const Color(0xFF334155),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () => setState(() => _isPremium = false),
                      child: const Text('Cancel Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      onPressed: () => setState(() => _isPremium = true),
                      child: const Text('Upgrade to Premium', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A single row in the General settings section.
class SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  const SettingRow({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: secondaryTextColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: isDark ? AppTheme.textDark : AppTheme.textLight,
                ),
              ),
            ),
            if (trailingText != null)
              Text(trailingText!, style: TextStyle(color: secondaryTextColor, fontSize: 12))
            else
              Icon(Icons.chevron_right, color: secondaryTextColor.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }
}

/// The theme mode selector row with a segmented button (Light / System / Dark).
class ThemeModeRow extends StatelessWidget {
  const ThemeModeRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(Icons.dark_mode, color: secondaryTextColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Theme Mode',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: isDark ? AppTheme.textDark : AppTheme.textLight,
              ),
            ),
          ),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16)),
              ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto, size: 16)),
              ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16)),
            ],
            selected: {themeNotifier.themeMode},
            onSelectionChanged: (Set<ThemeMode> newSelection) {
              themeNotifier.setThemeMode(newSelection.first);
            },
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              iconSize: WidgetStatePropertyAll(16),
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
            ),
          ),
        ],
      ),
    );
  }
}
