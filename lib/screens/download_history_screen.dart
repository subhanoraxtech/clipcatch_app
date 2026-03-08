import 'package:flutter/material.dart';
import 'package:video_downloader/theme/app_theme.dart';
import 'package:video_downloader/screens/settings_screen.dart';
import 'package:video_downloader/widgets/download_list_item.dart';

class DownloadHistoryScreen extends StatefulWidget {
  const DownloadHistoryScreen({super.key});

  @override
  State<DownloadHistoryScreen> createState() => _DownloadHistoryScreenState();
}

class _DownloadHistoryScreenState extends State<DownloadHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _downloads = [
    {
      'id': '1',
      'title': 'Cinematic Nature Drone Shot',
      'resolution': '1080p',
      'size': '250MB',
      'date': 'Oct 24, 2023',
      'duration': '04:22',
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500&auto=format&fit=crop&q=60',
    },
    {
      'id': '2',
      'title': 'Urban City Night Timelapse',
      'resolution': '4K',
      'size': '1.2GB',
      'date': 'Oct 22, 2023',
      'duration': '12:05',
      'image': 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=500&auto=format&fit=crop&q=60',
    },
    {
      'id': '3',
      'title': 'Productivity Setup Tour 2023',
      'resolution': '1080p',
      'size': '420MB',
      'date': 'Oct 18, 2023',
      'duration': '08:45',
      'image': 'https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=500&auto=format&fit=crop&q=60',
    },
    {
      'id': '4',
      'title': 'Full-Stack Development Tutorial',
      'resolution': '1080p',
      'size': '890MB',
      'date': 'Oct 15, 2023',
      'duration': '15:30',
      'image': 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=500&auto=format&fit=crop&q=60',
    },
  ];

  List<Map<String, String>> _filteredDownloads = [];

  @override
  void initState() {
    super.initState();
    _filteredDownloads = List.from(_downloads);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDownloads = _downloads
          .where((item) => item['title']!.toLowerCase().contains(query))
          .toList();
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _downloads.removeWhere((item) => item['id'] == id);
      _onSearchChanged();
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
                _downloads.clear();
                _filteredDownloads.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('Downloads', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _downloads.isEmpty ? null : _deleteAll,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? AppTheme.textDark : AppTheme.textLight),
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
            child: _filteredDownloads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library_outlined,
                            size: 64, color: isDark ? Colors.white24 : Colors.black12),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No downloads yet'
                              : 'No results found',
                          style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _filteredDownloads.length,
                    separatorBuilder: (_, _) => Padding(
                      padding: const EdgeInsets.only(left: 140),
                      child: Divider(color: surfaceColor, height: 1),
                    ),
                    itemBuilder: (context, index) {
                      final item = _filteredDownloads[index];
                      return DownloadListItem(
                        title: item['title']!,
                        resolution: item['resolution']!,
                        size: item['size']!,
                        date: item['date']!,
                        duration: item['duration']!,
                        imageUrl: item['image']!,
                        onTap: () {
                          // Open built-in video player
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
    );
  }

  void _showMoreOptions(Map<String, String> item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Open in Gallery'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteItem(item['id']!);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
