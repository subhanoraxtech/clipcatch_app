import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_downloader/widgets/settings/settings_header.dart';
import 'package:video_downloader/widgets/settings/subscription_card.dart';
import 'package:video_downloader/widgets/settings/preferences_section.dart';
import 'package:video_downloader/widgets/settings/about_section.dart';
import 'package:video_downloader/widgets/settings/review_section.dart';
import 'package:video_downloader/widgets/resolution_modal.dart';
import 'package:video_downloader/theme/subscription_notifier.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _wifiOnly = true;
  bool _notificationsEnabled = true;
  String _selectedRes = '720p';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _wifiOnly = prefs.getBool('wifi_only') ?? true;
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _selectedRes = prefs.getString('default_res') ?? '720p';
      });
    }
  }

  Future<void> _updateWifi(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wifi_only', value);
    setState(() => _wifiOnly = value);
  }

  Future<void> _updateNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _updateRes(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_res', value);
    setState(() => _selectedRes = value);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemUiFor(brightness),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SettingsHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  children: [
                    ListenableBuilder(
                      listenable: subscriptionNotifier,
                      builder: (context, _) => const SubscriptionCard(),
                    ),
                    const SizedBox(height: 32),
                    PreferencesSection(
                      wifiOnly: _wifiOnly,
                      notificationsEnabled: _notificationsEnabled,
                      selectedRes: _selectedRes,
                      onWifiChanged: _updateWifi,
                      onNotificationsChanged: _updateNotifications,
                      onResolutionTap: () {
                        showResolutionModal(
                          context,
                          (res) {
                            _updateRes(res);
                          },
                          initialSelection: _selectedRes,
                          buttonLabel: 'Select Quality',
                          buttonIcon: LucideIcons.circleCheck,
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    const ReviewSection(),
                    const SizedBox(height: 32),
                    const AboutSection(),
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        '© 2024 ClipCatch Inc.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMutedFor(brightness),
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
      ),
    );
  }
}
