import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/screens/settings_screen.dart';
import 'package:video_downloader/widgets/resolution_modal.dart';
import 'package:video_downloader/widgets/active_download_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _showMockActiveDownload = false;

  @override
  void initState() {
    super.initState();
    _requestInitialPermissions();
  }

  Future<void> _requestInitialPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await [
        Permission.storage,
        Permission.photos,
        Permission.videos,
      ].request();
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // ── Download logic ──────────────────────────────────────────────────────

  Future<void> _startDownload() async {
    // Check permission again just in case
    if (Platform.isAndroid || Platform.isIOS) {
      bool isGranted = false;
      
      // On Android 13+ (SDK 33+), we need to check Permission.videos
      // On older versions, we check Permission.storage
      if (Platform.isAndroid) {
        // We'll request both to be safe, permission_handler handles SDK checks internally
        final storageStatus = await Permission.storage.status;
        final videoStatus = await Permission.videos.status;
        
        isGranted = storageStatus.isGranted || videoStatus.isGranted;
        
        if (!isGranted) {
          final Map<Permission, PermissionStatus> statuses = await [
            Permission.storage,
            Permission.videos,
          ].request();
          
          isGranted = statuses[Permission.storage]!.isGranted || 
                      statuses[Permission.videos]!.isGranted;
        }
      } else {
        // iOS
        isGranted = await Permission.photos.request().isGranted;
      }

      if (!isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission required. Please grant storage/media access to save videos.'),
              action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _showMockActiveDownload = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _downloadProgress = 0.38);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() => _downloadProgress = 0.7);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            _downloadProgress = 1.0;
            _isDownloading = false;
            _showMockActiveDownload = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download complete! Saved to gallery.')),
          );
        });
      });
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroSection(isDark),
                    const SizedBox(height: 40),
                    _buildInputSection(isDark),
                    if (_showMockActiveDownload)
                      ActiveDownloadCard(progress: _downloadProgress),
                    const SizedBox(height: 60),
                    _buildSupportedPlatforms(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-builders ──────────────────────────────────────────────────────

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          Text(
            'InstaVibe',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textDark : AppTheme.textLight,
              letterSpacing: -0.5,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.settings, color: isDark ? AppTheme.textDark : AppTheme.textLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.cloud_download, size: 36, color: AppTheme.primaryColor),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Download Any Video',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textDark : AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Paste a URL from YouTube, Instagram, or TikTok',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight,
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _urlController,
          style: TextStyle(color: isDark ? AppTheme.textDark : AppTheme.textLight),
          decoration: InputDecoration(
            hintText: 'Paste video link here...',
            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            suffixIcon: IconButton(
              icon: const Icon(Icons.paste),
              color: AppTheme.primaryColor,
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  setState(() => _urlController.text = data!.text!);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          onPressed: _isDownloading
              ? null
              : () {
                  if (_urlController.text.isNotEmpty) {
                    showResolutionModal(context, _startDownload);
                  }
                },
          child: const Text('Download Now', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildSupportedPlatforms(bool isDark) {
    final mutedColor = isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight;

    return Column(
      children: [
        Text(
          'SUPPORTED PLATFORMS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, color: mutedColor),
            const SizedBox(width: 24),
            Icon(Icons.play_circle, color: mutedColor),
            const SizedBox(width: 24),
            Icon(Icons.camera, color: mutedColor),
            const SizedBox(width: 24),
            Icon(Icons.share, color: mutedColor),
          ],
        ),
      ],
    );
  }
}
