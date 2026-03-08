import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/main.dart';
import 'package:video_downloader/theme/subscription_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _wifiOnly = true;
  String _selectedRes = '720p';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;
    final cardBg = isDark ? const Color(0xFF0F172A).withValues(alpha: 0.5) : const Color(0xFFF8FAFC);
    final dividerColor = isDark ? AppTheme.surfaceDark : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            _buildHeader(isDark),

            // ── Content ─────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                children: [
                  ListenableBuilder(
                    listenable: subscriptionNotifier,
                    builder: (context, _) => _buildSubscriptionCard(),
                  ),
                  const SizedBox(height: 32),
                  _buildPreferencesSection(isDark, mutedColor, cardBg, dividerColor),
                  const SizedBox(height: 32),
                  _buildThemeSection(isDark, mutedColor, dividerColor),
                  const SizedBox(height: 32),
                  _buildAboutSection(isDark, mutedColor, cardBg, dividerColor),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      '© 2024 InstaVibe Media Inc.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.surfaceDark : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          if (Navigator.canPop(context))
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Icon(Icons.arrow_back,
                    color: isDark ? AppTheme.textDark : AppTheme.textLight),
              ),
            )
          else
            const SizedBox(width: 40),
          Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? AppTheme.textDark : AppTheme.textLight,
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  // ── Subscription Card ─────────────────────────────────────────────────

  Widget _buildSubscriptionCard() {
    final isPro = subscriptionNotifier.isPro;
    
    return _SectionLabel(
      label: 'Membership',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isPro ? null : AppTheme.primaryColor, // Solid color for Free to avoid gradient blur
          gradient: isPro 
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFDB931),
                  Color(0xFFEAB308),
                ],
              )
            : null,
          boxShadow: isPro 
            ? [
                BoxShadow(
                  color: const Color(0xFFEAB308).withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ]
            : null, // NO shadow for Free to avoid any blur perceived by the user
          border: Border.all(
            color: isPro ? Colors.black.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                          child: Text(
                            isPro ? 'PREMIUM STATUS' : 'UPGRADE TO PREMIUM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: isPro ? Colors.black : Colors.white, // Solid white for sharpness
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        isPro ? 'Gold Member' : 'InstaVibe Plus',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isPro ? Colors.black : Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPro ? Colors.black.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPro ? Icons.diamond_rounded : Icons.workspace_premium_rounded,
                      color: isPro ? Colors.black : Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              if (isPro) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 16, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      'All Premium Features Unlocked',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time_filled_rounded, size: 16, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      'Expires: ${subscriptionNotifier.expiryDate?.toString().substring(0, 10) ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
              if (!isPro) ...[
                const SizedBox(height: 24),
                // Pricing Options
                _buildPlanOption(
                  title: 'Gold Membership',
                  price: '1200 PKR',
                  description: 'Unlock 4K, Fast Download',
                  onTap: () => _handlePurchase('Gold Membership'),
                ),
                const SizedBox(height: 12),
                _buildPlanOption(
                  title: 'Platinum Membership',
                  price: '1500 PKR',
                  description: 'Ad-Free + 4K Fast Download',
                  onTap: () => _handlePurchase('Platinum Membership'),
                  accent: true,
                ),
              ] else ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => subscriptionNotifier.cancelSubscription(),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.1),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.black.withValues(alpha: 0.2)),
                    ),
                    child: const Text(
                      'Manage Subscription', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanOption({
    required String title,
    required String price,
    required String description,
    required VoidCallback onTap,
    bool accent = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: accent ? Colors.black.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)), // More defined border
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9), // Higher contrast for small text
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                price,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePurchase(String plan) {
    subscriptionNotifier.purchasePlan(plan);
    _showCongratulationsDialog(plan);
  }

  void _showCongratulationsDialog(String plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Congratulations!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'You are now a $plan member.\nAll features have been unlocked.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Resolution Picker Bottom Sheet ────────────────────────────────────

  void _showResolutionPicker(bool isDark) {
    final resolutions = [
      {'label': '144p', 'sub': 'Minimum quality', 'premium': false},
      {'label': '240p', 'sub': 'Low quality', 'premium': false},
      {'label': '360p', 'sub': 'Standard definition', 'premium': false},
      {'label': '480p', 'sub': 'Enhanced definition', 'premium': false},
      {'label': '720p', 'sub': 'High definition', 'premium': false},
      {'label': '1080p', 'sub': 'Full HD', 'premium': true},
      {'label': '2K', 'sub': 'Quad HD (1440p)', 'premium': true},
      {'label': '4K', 'sub': 'Ultra HD (2160p)', 'premium': true},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final divider = isDark ? AppTheme.surfaceDark : const Color(0xFFE2E8F0);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Resolution',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textDark : AppTheme.textLight,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: divider),

                  // Resolution list
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: resolutions.length,
                      separatorBuilder: (_, _) => Divider(height: 1, indent: 56, color: divider),
                      itemBuilder: (context, index) {
                        final res = resolutions[index];
                        final label = res['label'] as String;
                        final sub = res['sub'] as String;
                        final isPremium = res['premium'] as bool;
                        final isSelected = _selectedRes == label;

                        return InkWell(
                          onTap: () {
                            setModalState(() {});
                            setState(() => _selectedRes = label);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: Row(
                              children: [
                                // Radio dot
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                      width: 2,
                                    ),
                                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Center(child: Icon(Icons.circle, size: 8, color: Colors.white))
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                // Label
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            label,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? AppTheme.textDark : AppTheme.textLight,
                                            ),
                                          ),
                                          if (isPremium) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'PRO',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        sub,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isPremium)
                                  Icon(Icons.workspace_premium,
                                      size: 20, color: Colors.amber.withValues(alpha: 0.7)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Preferences Section ───────────────────────────────────────────────

  Widget _buildPreferencesSection(
      bool isDark, Color mutedColor, Color cardBg, Color dividerColor) {
    return _SectionLabel(
      label: 'Preferences',
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor),
        ),
        child: Column(
          children: [
            // Video Resolution row
            InkWell(
              onTap: () => _showResolutionPicker(isDark),
              splashFactory: InkRipple.splashFactory,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.hd, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Video Resolution',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppTheme.textDark : AppTheme.textLight,
                            ),
                          ),
                          Text(
                            'Preferred quality for downloads',
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                        ],
                      ),
                    ),
                    Text(_selectedRes,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500, color: mutedColor)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 18, color: mutedColor),
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: dividerColor),

            // Wi-Fi Only row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.wifi, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wi-Fi Only',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.textDark : AppTheme.textLight,
                          ),
                        ),
                        Text(
                          'Save your mobile data',
                          style: TextStyle(fontSize: 12, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _wifiOnly,
                    onChanged: (v) => setState(() => _wifiOnly = v),
                    activeThumbColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Theme Section ─────────────────────────────────────────────────────

  Widget _buildThemeSection(bool isDark, Color mutedColor, Color dividerColor) {
    final currentMode = themeNotifier.themeMode;

    return _SectionLabel(
      label: 'Theme',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor),
        ),
        child: Row(
          children: [
            _ThemePill(
              icon: Icons.light_mode,
              label: 'Light',
              isActive: currentMode == ThemeMode.light,
              onTap: () {
                setState(() => themeNotifier.setThemeMode(ThemeMode.light));
              },
            ),
            _ThemePill(
              icon: Icons.dark_mode,
              label: 'Dark',
              isActive: currentMode == ThemeMode.dark,
              onTap: () {
                setState(() => themeNotifier.setThemeMode(ThemeMode.dark));
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── About Section ─────────────────────────────────────────────────────

  Widget _buildAboutSection(
      bool isDark, Color mutedColor, Color cardBg, Color dividerColor) {
    return _SectionLabel(
      label: 'About',
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor),
        ),
        child: Column(
          children: [
            // App Version
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'App Version',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.textDark : AppTheme.textLight,
                    ),
                  ),
                  Text('v2.4.0',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500, color: mutedColor)),
                ],
              ),
            ),
            Divider(height: 1, color: dividerColor),

            // Privacy Policy
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.textDark : AppTheme.textLight,
                      ),
                    ),
                    Icon(Icons.open_in_new, size: 18, color: mutedColor),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: dividerColor),

            // Reset All Settings
            InkWell(
              onTap: () {},
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reset All Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ──────────────────────────────────────────────────────────

/// A section with an uppercase label above the content.
class _SectionLabel extends StatelessWidget {
  final String label;
  final Widget child;

  const _SectionLabel({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: mutedColor,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// A single theme toggle pill button (Light / Dark).
class _ThemePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ThemePill({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? Colors.white : AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? Colors.white
                      : (Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.textDark
                          : AppTheme.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
