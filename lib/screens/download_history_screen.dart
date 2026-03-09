import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:open_filex/open_filex.dart';
import 'package:video_downloader/screens/settings_screen.dart';
import 'package:video_downloader/widgets/download_list_item.dart';
import 'package:video_downloader/widgets/history/history_header.dart';
import 'package:video_downloader/screens/video_player_screen.dart';

class DownloadHistoryScreen extends StatefulWidget {
  // Accepted from parent state
  final List<Map<String, String>> downloads;
  final VoidCallback onDownloadsChanged;

  const DownloadHistoryScreen({
    super.key, 
    required this.downloads,
    required this.onDownloadsChanged,
  });

  @override
  State<DownloadHistoryScreen> createState() => _DownloadHistoryScreenState();
}

class _DownloadHistoryScreenState extends State<DownloadHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Rebuild to update filtered results
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteItem(String id) {
    setState(() {
      widget.downloads.removeWhere((item) => item['id'] == id);
      widget.onDownloadsChanged();
    });
  }

  void _deleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All'),
        content: const Text('Are you sure you want to delete all downloads?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.downloads.clear();
                widget.onDownloadsChanged();
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _shareVideo(Map<String, String> item) async {
    final path = item['path'];
    if (path != null && await File(path).exists()) {
      await Share.shareXFiles([XFile(path)], text: 'Check out this video from ClipCatch!');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video file not found or already deleted.')),
        );
      }
    }
  }

  Future<void> _openFile(String? path) async {
    if (path != null && await File(path).exists()) {
      try {
        final result = await OpenFilex.open(path);
        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open file: ${result.message}')),
          );
        }
      } catch (e) {
        debugPrint('Error opening file: $e');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video file not found or already deleted.')),
        );
      }
    }
  }

  Future<void> _openGalleryApp() async {
    try {
      await Gal.open();
    } catch (e) {
      debugPrint('Error opening gallery: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = AppTheme.surfaceDark;

    final query = _searchController.text.toLowerCase();
    final filteredDownloads = widget.downloads
        .where((item) => item['title']!.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HistoryHeader(
              isEmpty: widget.downloads.isEmpty,
              onDeleteAll: _deleteAll,
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textDark),
                decoration: InputDecoration(
                  hintText: 'Search downloaded videos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  contentPadding: EdgeInsets.zero,
                  fillColor: surfaceColor,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Download list
            Expanded(
              child: filteredDownloads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                                  Icon(Icons.video_library_outlined,
                              size: 64, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No downloads yet'
                                : 'No results found',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredDownloads.length,
                      separatorBuilder: (_, _) => Padding(
                        padding: const EdgeInsets.only(left: 140),
                        child: Divider(color: surfaceColor, height: 1),
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredDownloads[index];
                        return DownloadListItem(
                          title: item['title']!,
                          resolution: item['resolution']!,
                          size: item['size']!,
                          date: item['date']!,
                          duration: item['duration']!,
                          imageUrl: item['image']!,
                          onTap: () {
                            // Open built-in video player if path exists
                            if (item.containsKey('path')) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoPlayerScreen(
                                    videoPath: item['path']!,
                                    title: item['title']!,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Video file path not found.')),
                              );
                            }
                          },
                          onMore: () {
                            _showMoreOptions(item);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(Map<String, String> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 16,
          left: 16,
          right: 16,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_outline_rounded),
              title: const Text('Play Video'),
              onTap: () {
                Navigator.pop(context);
                if (item.containsKey('path')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(
                        videoPath: item['path']!,
                        title: item['title']!,
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Video'),
              onTap: () {
                Navigator.pop(context);
                _shareVideo(item);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Open in Gallery'),
              onTap: () {
                Navigator.pop(context);
                _openFile(item['path']);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteItem(item['id']!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
