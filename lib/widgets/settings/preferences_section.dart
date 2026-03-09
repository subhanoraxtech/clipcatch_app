import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_downloader/theme/app_theme.dart';

class PreferencesSection extends StatelessWidget {
  final bool wifiOnly;
  final bool notificationsEnabled;
  final String selectedRes;
  final VoidCallback onResolutionTap;
  final ValueChanged<bool> onWifiChanged;
  final ValueChanged<bool> onNotificationsChanged;

  const PreferencesSection({
    super.key,
    required this.wifiOnly,
    required this.notificationsEnabled,
    required this.selectedRes,
    required this.onResolutionTap,
    required this.onWifiChanged,
    required this.onNotificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = AppTheme.textMutedDark;
    final textColor = Colors.white;
    final cardBg = const Color(0xFF0F172A).withOpacity(0.5);
    final dividerColor = AppTheme.surfaceDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'PREFERENCES',
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
            border: Border.all(color: AppTheme.borderDark),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.wifi_rounded,
                title: 'Download via Wi-Fi only',
                trailing: Switch(
                  value: wifiOnly,
                  onChanged: (v) {
                    HapticFeedback.lightImpact();
                    onWifiChanged(v);
                  },
                  activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              Divider(height: 1, color: dividerColor, indent: 56),
              _buildSettingTile(
                icon: Icons.high_quality_rounded,
                title: 'Default Quality',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedRes,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 20, color: mutedColor),
                  ],
                ),
                onTap: onResolutionTap,
              ),
              Divider(height: 1, color: dividerColor, indent: 56),
              _buildSettingTile(
                icon: Icons.notifications_active_rounded,
                title: 'Download Notifications',
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (v) {
                    HapticFeedback.lightImpact();
                    onNotificationsChanged(v);
                  },
                  activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
                  activeColor: AppTheme.primaryColor,
                ),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast 
        ? const BorderRadius.vertical(bottom: Radius.circular(24))
        : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
