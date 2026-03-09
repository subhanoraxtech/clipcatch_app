import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_downloader/screens/home_screen.dart';
import 'package:video_downloader/screens/download_history_screen.dart';
import 'package:video_downloader/screens/settings_screen.dart';
import 'package:video_downloader/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Map<String, String>> _downloads = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('download_history');
    if (historyJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        setState(() {
          _downloads = decoded.map((e) => Map<String, String>.from(e)).toList();
        });
      } catch (e) {
        debugPrint('Error loading history: $e');
      }
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('download_history', jsonEncode(_downloads));
  }

  void _addDownload(Map<String, String> download) {
    setState(() {
      _downloads = [download, ..._downloads];
    });
    _saveHistory();
  }

  void _onDownloadsChanged() {
    setState(() {});
    _saveHistory();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild screens with shared state
    final List<Widget> screens = <Widget>[
      HomeScreen(onDownloadComplete: _addDownload),
      DownloadHistoryScreen(downloads: _downloads, onDownloadsChanged: _onDownloadsChanged),
      const SettingsScreen(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppTheme.borderDark,
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
