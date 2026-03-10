import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_downloader/theme/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _hasError = false;
  bool _showControls = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.videoPath.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
      } else {
        final file = File(widget.videoPath);
        if (!await file.exists()) {
          debugPrint('Video file does not exist at path: ${widget.videoPath}');
          if (mounted) setState(() => _hasError = true);
          return;
        }
        final size = await file.length();
        debugPrint('Initializing video file: ${widget.videoPath} (Size: $size bytes)');
        if (size == 0) {
          debugPrint('Error: Video file is empty (0 bytes)');
          if (mounted) setState(() => _hasError = true);
          return;
        }
        _controller = VideoPlayerController.file(file);
      }

      await _controller.initialize();
      _controller.play();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      _startHideTimer();
    } catch (e, stack) {
      debugPrint('CRITICAL: Error initializing video player: $e');
      debugPrint('Stack trace: $stack');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Timer? _hideTimer;

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _hasError 
          ? Center(child: _buildErrorWidget()) 
          : Stack(
              fit: StackFit.expand,
              children: [
                // 1. Video Player
                if (_isInitialized)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                else
                  const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),

                // 2. Control Layout
                if (_isInitialized)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: _toggleControls,
                        behavior: HitTestBehavior.translucent,
                        child: Stack(
                          children: [
                            // 2a. Center Play/Pause (Absorb taps so they're handled here, not toggling)
                            Center(
                              child: GestureDetector(
                                onTap: () {}, // Stop event propagation
                                child: IconButton(
                                  iconSize: 80,
                                  icon: Icon(
                                    _controller.value.isPlaying 
                                        ? Icons.pause_circle_filled_rounded 
                                        : Icons.play_circle_filled_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _controller.value.isPlaying 
                                          ? _controller.pause() 
                                          : _controller.play();
                                    });
                                    if (_controller.value.isPlaying) {
                                      _startHideTimer();
                                    }
                                  },
                                ),
                              ),
                            ),

                            // 2b. Bottom Controls (Absorb taps)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {}, // Stop event propagation
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).padding.bottom + 20,
                                    left: 16,
                                    right: 16,
                                    top: 40,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.95),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      VideoProgressIndicator(
                                        _controller,
                                        allowScrubbing: true,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        colors: const VideoProgressColors(
                                          playedColor: AppTheme.primaryColor,
                                          bufferedColor: Colors.white24,
                                          backgroundColor: Colors.white12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ValueListenableBuilder(
                                        valueListenable: _controller,
                                        builder: (context, VideoPlayerValue value, child) {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _formatDuration(value.position),
                                                style: const TextStyle(
                                                  color: Colors.white, 
                                                  fontSize: 14, 
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              Text(
                                                _formatDuration(value.duration),
                                                style: const TextStyle(
                                                  color: Colors.white, 
                                                  fontSize: 14, 
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 3. Toggle Gesture Layer (Only active when controls are NOT visible)
                if (!_showControls)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _toggleControls,
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),

                // 4. Back Button (Always accessible)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: SafeArea(
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "00:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  Widget _buildErrorWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.video_library_rounded, color: Colors.white12, size: 80),
        const SizedBox(height: 24),
        const Text(
          'Unable to play video',
          style: TextStyle(
            color: Colors.white, 
            fontSize: 18, 
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'The file may be corrupt or moved.',
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Go Back', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
