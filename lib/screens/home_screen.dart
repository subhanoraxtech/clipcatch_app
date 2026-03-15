import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/widgets/home/home_header.dart';
import 'package:video_downloader/widgets/home/home_hero_section.dart';
import 'package:video_downloader/widgets/home/home_input_section.dart';
import 'package:video_downloader/widgets/home/supported_platforms_list.dart';
import 'package:video_downloader/widgets/active_download_card.dart';
import 'package:video_downloader/services/api_service.dart';
import 'package:video_downloader/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_downloader/services/ad_service.dart';
import 'package:video_downloader/theme/subscription_notifier.dart';

class HomeScreen extends StatefulWidget {
  final Function(Map<String, String>)? onDownloadComplete;

  const HomeScreen({super.key, this.onDownloadComplete});

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
  final int _notificationId = 101;
  final NotificationService _notificationService = NotificationService();

  List<String> _supportedServices = [];
  bool _isLoadingServices = true;

  http.Client? _currentDownloadClient;
  bool _isCancelledByUser = false;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _requestInitialPermissions();
    _fetchServices();
    _loadSettings();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _loadBannerAd() {
    if (subscriptionNotifier.isPro) return;

    _bannerAd = BannerAd(
      adUnitId: AdService().bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    if (subscriptionNotifier.isPro) return;

    InterstitialAd.load(
      adUnitId: AdService().interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          debugPrint('InterstitialAd failed to load: $err');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd(VoidCallback onDismissed) {
    if (_interstitialAd == null) {
      onDismissed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd(); // Load next one
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _loadInterstitialAd(); // Try again
        onDismissed();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _defaultResolution = prefs.getString('default_res') ?? '720p';
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

  void _cancelDownload() {
    setState(() {
      _isCancelledByUser = true;
    });
    _currentDownloadClient?.close();
    _notificationService.cancelNotification(_notificationId);
    setState(() {
      _isDownloading = false;
      _showMockActiveDownload = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download cancelled'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _currentDownloadClient?.close();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  // ── Download logic ──────────────────────────────────────────────────────

  Future<void> _startDownload(String resolution) async {
    if (_urlController.text.isEmpty) return;

    if (!subscriptionNotifier.isPro) {
      _showInterstitialAd(() => _processDownload(resolution));
    } else {
      _processDownload(resolution);
    }
  }

  Future<void> _processDownload(String resolution) async {
    // Load fresh settings
    final prefs = await SharedPreferences.getInstance();
    final wifiOnly = prefs.getBool('wifi_only') ?? true;

    // Connectivity check
    final connectivityResult = await Connectivity().checkConnectivity();
    if (wifiOnly && !connectivityResult.contains(ConnectivityResult.wifi)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wi-Fi Only is enabled. Please connect to Wi-Fi.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // Check permission
    if (Platform.isAndroid || Platform.isIOS) {
      bool isGranted = false;
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.status;
        final videoStatus = await Permission.videos.status;
        isGranted = storageStatus.isGranted || videoStatus.isGranted;

        if (!isGranted) {
          final statuses = await [
            Permission.storage,
            Permission.videos,
          ].request();
          isGranted =
              statuses[Permission.storage]!.isGranted ||
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
              action: SnackBarAction(
                label: 'Settings',
                onPressed: openAppSettings,
              ),
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
      if (resLower.contains('4k') || resLower.contains('2160')) {
        parsedResolution = "2160";
      } else if (resLower.contains('2k') || resLower.contains('1440')) {
        parsedResolution = "1440";
      } else if (resLower.contains('1080')) {
        parsedResolution = "1080";
      } else if (resLower.contains('720')) {
        parsedResolution = "720";
      } else if (resLower.contains('480')) {
        parsedResolution = "480";
      } else if (resLower.contains('360')) {
        parsedResolution = "360";
      } else if (resLower.contains('240')) {
        parsedResolution = "240";
      } else if (resLower.contains('144')) {
        parsedResolution = "144";
      }

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
        throw Exception(
          data['text'] ?? "Unsupported download type: ${data['status']}",
        );
      }

      String downloadUrl = data['url'];
      String fileName =
          data['filename'] ??
          'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Replace localhost with actual machine IP for downloads
      if (downloadUrl.contains('localhost:9000')) {
        downloadUrl = downloadUrl.replaceFirst(
          'localhost:9000',
          '192.168.10.245:9000',
        );
      }

      debugPrint('Download URL: $downloadUrl');

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

      await _notificationService.showDownloadProgress(
        id: _notificationId,
        title: fileName,
        progress: 0,
      );

      // Stream Download using http for chunk processing progress
      final client = http.Client();
      _currentDownloadClient = client; // Store for cancellation
      _isCancelledByUser = false;

      final request = http.Request('GET', Uri.parse(downloadUrl));

      debugPrint('Starting download from: $downloadUrl');

      // Get response with shorter timeout (30 seconds for headers)
      debugPrint('Waiting for response headers...');
      late final http.StreamedResponse streamedResponse;
      try {
        streamedResponse = await client
            .send(request)
            .timeout(
              const Duration(minutes: 10),
              onTimeout: () {
                client.close();
                throw TimeoutException(
                  'Server not responding. The tunnel endpoint may be unavailable.',
                  const Duration(minutes: 10),
                );
              },
            );
      } catch (e) {
        debugPrint('Failed to get response: $e');
        client.close();
        rethrow;
      }

      debugPrint('Response received: ${streamedResponse.statusCode}');
      debugPrint('Content-Length: ${streamedResponse.contentLength}');

      if (streamedResponse.statusCode != 200) {
        client.close();
        throw Exception("Fetch failed: ${streamedResponse.statusCode}");
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      int bytesDownloaded = 0;

      final appDir = await getApplicationDocumentsDirectory();
      final saveFile = File('${appDir.path}/$fileName');
      final iosink = saveFile.openWrite();

      debugPrint('Saving to: ${saveFile.path}');
      debugPrint('Content-Length: $contentLength bytes');

      // Use addStream to ensure complete file writing
      try {
        debugPrint(
          'Starting stream download with ${contentLength > 0 ? contentLength : 'unknown'} bytes...',
        );

        // Create a timeout-aware stream
        final streamWithTimeout = streamedResponse.stream.timeout(
          const Duration(minutes: 10),
          onTimeout: (sink) {
            debugPrint('Stream timeout - no data received for 10 minutes');
            sink.addError(
              TimeoutException(
                'Download stream stalled - no data for 10 minutes. Server may be slow.',
                const Duration(minutes: 10),
              ),
            );
          },
        );

        await iosink.addStream(
          streamWithTimeout.map((chunk) {
            if (_isCancelledByUser) {
              throw Exception('Download cancelled by user');
            }
            bytesDownloaded += chunk.length;
            debugPrint('Downloaded: $bytesDownloaded bytes');
            if (contentLength > 0 && mounted) {
              final progressValue = 30 + (bytesDownloaded / contentLength * 60).toInt();
              setState(() {
                _downloadProgress =
                    0.3 + (bytesDownloaded / contentLength) * 0.6;
              });
              _notificationService.showDownloadProgress(
                id: _notificationId,
                title: fileName,
                progress: progressValue,
              );
            } else if (contentLength == 0 && mounted) {
              // Fallback: assume average video size and show progress
              final estimatedSize = 100 * 1024 * 1024; // 100MB estimate
              final progressValue = 30 + (bytesDownloaded / estimatedSize * 60).toInt();
              setState(() {
                _downloadProgress =
                    0.3 + (bytesDownloaded / estimatedSize) * 0.6;
              });
              if (progressValue < 95) {
                _notificationService.showDownloadProgress(
                  id: _notificationId,
                  title: fileName,
                  progress: progressValue,
                );
              }
            }
            return chunk;
          }),
        );
        debugPrint('Stream completed successfully');
      } catch (e) {
        debugPrint('Stream error: $e');
        await iosink.close();
        client.close();
        rethrow;
      }

      await iosink.flush();
      await iosink.close();
      client.close();

      debugPrint('Download completed: $bytesDownloaded bytes');
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

      String durationStr =
          '${videoDuration.inMinutes.toString().padLeft(2, '0')}:${(videoDuration.inSeconds % 60).toString().padLeft(2, '0')}';
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
          'size': contentLength > 0
              ? '${(contentLength / (1024 * 1024)).toStringAsFixed(1)}MB'
              : '---',
          'date':
              '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
          'duration': durationStr,
          'path': saveFile.path,
          'image':
              thumbnailPath ??
              'https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=500&auto=format&fit=crop',
        });

        _notificationService.showDownloadComplete(
          id: _notificationId,
          title: fileName,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video saved to gallery!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        _urlController.clear();

        // Show ad after download finishes (non-pro only)
        if (!subscriptionNotifier.isPro) {
          _showInterstitialAd(() {});
        }
      }
    } catch (e) {
      debugPrint('Download error: $e');
      String msg = e.toString().replaceAll("Exception: ", "");
      if (e is TimeoutException) msg = "Connection timed out.";

      _notificationService.showDownloadError(
        id: _notificationId,
        title: _downloadFileName,
        error: msg,
      );

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
    final brightness = Theme.of(context).brightness;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.systemUiFor(brightness),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (_isAdLoaded && !subscriptionNotifier.isPro)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              const HomeHeader(),
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const HomeHeroSection(),
                          const SizedBox(height: 48),
                          HomeInputSection(
                            controller: _urlController,
                            isDownloading: _isDownloading,
                            onDownloadTriggered: (res) {
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
                              onCancel: _cancelDownload,
                            ),
                          ],
                          const SizedBox(height: 64),
                          SupportedPlatformsList(
                            services: _supportedServices,
                            isLoading: _isLoadingServices,
                          ),
                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: null,
      ),
    );
  }
}
