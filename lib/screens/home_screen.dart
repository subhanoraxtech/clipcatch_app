import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/widgets/home/home_header.dart';
import 'package:video_downloader/widgets/home/home_hero_section.dart';
import 'package:video_downloader/widgets/home/home_input_section.dart';
import 'package:video_downloader/widgets/home/supported_platforms_list.dart';
import 'package:video_downloader/widgets/active_download_card.dart';
import 'package:video_downloader/services/api_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class HomeScreen extends StatefulWidget {
  final Function(Map<String, String>)? onDownloadComplete;

  const HomeScreen({
    super.key,
    this.onDownloadComplete,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _showMockActiveDownload = false;
  String _downloadFileName = 'Downloading Video...';
  String _defaultResolution = '720p';
  bool _wifiOnly = true;

  List<String> _supportedServices = [];
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _requestInitialPermissions();
    _fetchServices();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _defaultResolution = prefs.getString('default_res') ?? '720p';
        _wifiOnly = prefs.getBool('wifi_only') ?? true;
      });
    }
  }

  Future<void> _fetchServices() async {
    final services = await _apiService.fetchSupportedServices();
    if (mounted) {
      setState(() {
        _supportedServices = services;
        _isLoadingServices = false;
      });
    }
  }

  Future<void> _requestInitialPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        await [
          Permission.storage,
          Permission.photos,
          Permission.videos,
        ].request();
      } catch (e) {
        debugPrint('Permission request error: $e');
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // ── Download logic ──────────────────────────────────────────────────────

  Future<void> _startDownload(String resolution) async {
    if (_urlController.text.isEmpty) return;

    // Load fresh settings
    final prefs = await SharedPreferences.getInstance();
    final wifiOnly = prefs.getBool('wifi_only') ?? true;

    // TODO: Implement real Wi-Fi check with connectivity_plus if needed
    // For now we just respect the flag by showing a warning if it's on
    // but we allow it for testing unless we add the package.
    if (wifiOnly) {
       debugPrint('Wi-Fi Only is enabled. Proceeding with caution.');
    }

    // Check permission
    if (Platform.isAndroid || Platform.isIOS) {
      bool isGranted = false;
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.status;
        final videoStatus = await Permission.videos.status;
        isGranted = storageStatus.isGranted || videoStatus.isGranted;
        
        if (!isGranted) {
          final statuses = await [Permission.storage, Permission.videos].request();
          isGranted = statuses[Permission.storage]!.isGranted || 
                      statuses[Permission.videos]!.isGranted;
        }
      } else {
        isGranted = await Permission.photos.request().isGranted;
      }

      if (!isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission required to save videos.'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.05;
      _showMockActiveDownload = true;
      _downloadFileName = 'Initializing...';
    });

    try {
      // Parse resolution for Cobalt API
      String parsedResolution = "1080";
      final resLower = resolution.toLowerCase();
      if (resLower.contains('4k') || resLower.contains('2160')) parsedResolution = "2160";
      else if (resLower.contains('2k') || resLower.contains('1440')) parsedResolution = "1440";
      else if (resLower.contains('1080')) parsedResolution = "1080";
      else if (resLower.contains('720')) parsedResolution = "720";
      else if (resLower.contains('480')) parsedResolution = "480";
      else if (resLower.contains('360')) parsedResolution = "360";
      else if (resLower.contains('240')) parsedResolution = "240";
      else if (resLower.contains('144')) parsedResolution = "144";

      setState(() {
        _downloadProgress = 0.15;
        _downloadFileName = 'Analyzing Link...';
      });
      
      final data = await _apiService.processMedia(
        url: _urlController.text,
        resolution: parsedResolution,
      );

      if (data == null) throw Exception("Could not process video link.");
      if (data['status'] != 'tunnel' && data['status'] != 'redirect') {
        throw Exception(data['text'] ?? "Unsupported download type: ${data['status']}");
      }

      String downloadUrl = data['url'];
      String fileName = data['filename'] ?? 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      // Ensure file has an extension to avoid gallery errors
      if (!fileName.contains('.')) {
        fileName = '$fileName.mp4';
      } else if (!fileName.toLowerCase().endsWith('.mp4') && 
                 !fileName.toLowerCase().endsWith('.mkv') && 
                 !fileName.toLowerCase().endsWith('.webm')) {
        // If it has an extension but it's not a common video one, append .mp4
        fileName = '$fileName.mp4';
      }
      
      // Download URL will use localhost if adb reverse is running

      setState(() {
        _downloadProgress = 0.3;
        _downloadFileName = fileName;
      });

      // Stream Download using http for chunk processing progress
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        throw Exception("Fetch failed: ${streamedResponse.statusCode}");
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      int bytesDownloaded = 0;
      
      final appDir = await getApplicationDocumentsDirectory();
      final saveFile = File('${appDir.path}/$fileName');
      final iosink = saveFile.openWrite();

      // Use addStream to ensure complete file writing
      await iosink.addStream(streamedResponse.stream.map((chunk) {
        bytesDownloaded += chunk.length;
        if (contentLength > 0 && mounted) {
          setState(() {
            _downloadProgress = 0.3 + (bytesDownloaded / contentLength) * 0.6;
          });
        }
        return chunk;
      }));

      await iosink.flush();
      await iosink.close();
      client.close();

      setState(() => _downloadProgress = 0.95);

      // Save to Gallery
      try {
        await Gal.putVideo(saveFile.path);
      } catch (e) {
        debugPrint('Gal save error: $e');
      }

      // Extract duration
      Duration videoDuration = Duration.zero;
      try {
        final tempController = VideoPlayerController.file(saveFile);
        await tempController.initialize();
        videoDuration = tempController.value.duration;
        await tempController.dispose();
      } catch (e) {
        debugPrint('Error getting duration: $e');
      }
      
      String durationStr = '${videoDuration.inMinutes.toString().padLeft(2, '0')}:${(videoDuration.inSeconds % 60).toString().padLeft(2, '0')}';
      if (videoDuration == Duration.zero) durationStr = '--:--';

      // Extract thumbnail
      String? thumbnailPath;
      try {
        final thumbDir = await getApplicationDocumentsDirectory();
        thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: saveFile.path,
          thumbnailPath: thumbDir.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 256,
          quality: 75,
        );
      } catch (e) {
        debugPrint('Error generating thumbnail: $e');
      }

      if (mounted) {
        setState(() {
          _downloadProgress = 1.0;
          _isDownloading = false;
          _showMockActiveDownload = false;
        });
        
        widget.onDownloadComplete?.call({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': fileName, 
          'resolution': resolution,
          'size': contentLength > 0 ? '${(contentLength / (1024 * 1024)).toStringAsFixed(1)}MB' : '---',
          'date': '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
          'duration': durationStr,
          'path': saveFile.path,
          'image': thumbnailPath ?? 'https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=500&auto=format&fit=crop', 
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video saved to gallery!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        _urlController.clear();
      }
    } catch (e) {
      debugPrint('Download error: $e');
      String msg = e.toString().replaceAll("Exception: ", "");
      if (e is TimeoutException) msg = "Connection timed out.";
      
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _showMockActiveDownload = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $msg'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const HomeHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const HomeHeroSection(),
                      const SizedBox(height: 48),
                      HomeInputSection(
                        controller: _urlController,
                        isDownloading: _isDownloading,
                        onDownloadTriggered: (res) {
                          // Update default res if changed (optional, but keep consistent)
                          _defaultResolution = res;
                          _startDownload(res);
                        },
                        initialResolution: _defaultResolution,
                      ),
                      if (_showMockActiveDownload) ...[
                        const SizedBox(height: 24),
                        ActiveDownloadCard(
                          progress: _downloadProgress,
                          filename: _downloadFileName,
                        ),
                      ],
                      const SizedBox(height: 64),
                      SupportedPlatformsList(
                        services: _supportedServices,
                        isLoading: _isLoadingServices,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
