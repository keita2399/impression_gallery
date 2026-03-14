import 'package:flutter/material.dart';
import '../models/artwork.dart';
import '../services/art_api.dart';
import '../services/translate_service.dart';
import 'gallery_screen.dart';
import 'favorites_screen.dart';
import 'gacha_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Artwork? _todayArtwork;
  bool _loading = true;
  String? _error;
  int _currentIndex = 0;
  String? _translatedTitle;
  String? _translatedDescription;

  @override
  void initState() {
    super.initState();
    _loadTodayArtwork();
  }

  Future<void> _loadTodayArtwork() async {
    try {
      final works = await ArtApi.fetchImpressionistWorks(limit: 50);
      if (works.isNotEmpty) {
        final dayIndex = DateTime.now().day % works.length;
        setState(() {
          _todayArtwork = works[dayIndex];
          _loading = false;
        });
        _translateArtwork(works[dayIndex]);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _translateArtwork(Artwork artwork) async {
    final title = await TranslateService.toJapanese(artwork.title);
    if (mounted) setState(() => _translatedTitle = title);

    if (artwork.description != null) {
      final desc = await TranslateService.toJapanese(artwork.description!);
      if (mounted) setState(() => _translatedDescription = desc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHome(),
      const GalleryScreen(),
      const GachaScreen(),
      const FavoritesScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '今日'),
          NavigationDestination(icon: Icon(Icons.collections_outlined), selectedIcon: Icon(Icons.collections), label: 'ギャラリー'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'ガチャ'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'コレクション'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('エラー: $_error', style: const TextStyle(color: Colors.white)));
    }
    if (_todayArtwork == null) {
      return const Center(child: Text('作品が見つかりません', style: TextStyle(color: Colors.white)));
    }

    final artwork = _todayArtwork!;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (artwork.imageUrl != null)
          Image.network(
            artwork.imageUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stack) {
              return const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 64));
            },
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.85),
              ],
              stops: const [0.3, 0.6, 1.0],
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 24,
          right: 24,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.palette, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text("今日の名画",
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 100,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_translatedTitle != null) ...[
                Text(
                  _translatedTitle!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  artwork.title,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ] else ...[
                Text(
                  artwork.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                TranslateService.translateArtist(artwork.artist),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                artwork.date,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
              ),
              if (_translatedDescription != null) ...[
                const SizedBox(height: 16),
                Text(
                  _translatedDescription!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
                ),
              ] else if (artwork.description != null) ...[
                const SizedBox(height: 16),
                Text(
                  artwork.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, height: 1.5),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
