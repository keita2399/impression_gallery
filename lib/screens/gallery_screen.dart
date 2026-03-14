import 'package:flutter/material.dart';
import '../models/artwork.dart';
import '../services/art_api.dart';
import '../services/firestore_service.dart';
import '../services/translate_service.dart';
import 'detail_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final PageController _pageController = PageController();
  List<Artwork> _artworks = [];
  Set<int> _favoriteIds = {};
  bool _loading = true;
  int _currentPage = 0;
  String? _selectedArtist;
  final Map<int, String> _translatedTitles = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    _favoriteIds = await FirestoreService.getFavoriteIds();

    try {
      final works = await ArtApi.fetchImpressionistWorks(
        limit: 100,
        artistFilter: _selectedArtist,
      );
      setState(() {
        _artworks = works;
        _loading = false;
        _currentPage = 0;
      });
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      if (works.isNotEmpty) {
        _translateTitle(works[0]);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _translateTitle(Artwork artwork) async {
    if (_translatedTitles.containsKey(artwork.id)) return;
    final translated = await TranslateService.toJapanese(artwork.title);
    if (mounted) {
      setState(() => _translatedTitles[artwork.id] = translated);
    }
  }

  Future<void> _toggleFavorite(int id) async {
    final isFav = await FirestoreService.toggleFavorite(id);
    setState(() {
      if (isFav) {
        _favoriteIds.add(id);
      } else {
        _favoriteIds.remove(id);
      }
    });
  }

  void _showArtistFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('画家で絞り込み', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _filterChip('すべての画家', null),
              ...ArtApi.impressionistArtists.map((a) => _filterChip(TranslateService.translateArtist(a), a)),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, String? artist) {
    final selected = _selectedArtist == artist;
    return ListTile(
      title: Text(label, style: TextStyle(color: selected ? Colors.amber : Colors.white70)),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? Colors.amber : Colors.white30,
      ),
      onTap: () {
        Navigator.pop(context);
        if (_selectedArtist != artist) {
          _selectedArtist = artist;
          _loadData();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_artworks.isEmpty) {
      return const Center(child: Text('作品が見つかりません', style: TextStyle(color: Colors.white)));
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _artworks.length,
          onPageChanged: (i) {
            setState(() => _currentPage = i);
            _translateTitle(_artworks[i]);
            // Pre-translate next page
            if (i + 1 < _artworks.length) {
              _translateTitle(_artworks[i + 1]);
            }
          },
          itemBuilder: (context, index) => _buildArtworkPage(_artworks[index]),
        ),
        // Top bar
        Positioned(
          top: 50,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1} / ${_artworks.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              GestureDetector(
                onTap: _showArtistFilter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _selectedArtist != null
                        ? Colors.amber.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: _selectedArtist != null
                        ? Border.all(color: Colors.amber.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_list, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _selectedArtist != null ? TranslateService.translateArtist(_selectedArtist!) : 'すべて',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArtworkPage(Artwork artwork) {
    final isFav = _favoriteIds.contains(artwork.id);
    final translatedTitle = _translatedTitles[artwork.id];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(artwork: artwork)),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (artwork.imageUrl != null)
            InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Image.network(
                artwork.imageUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stack) {
                  return const Center(child: Icon(Icons.broken_image, color: Colors.white54, size: 64));
                },
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Right side buttons
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              children: [
                _sideButton(
                  icon: isFav ? Icons.favorite : Icons.favorite_outline,
                  color: isFav ? Colors.redAccent : Colors.white,
                  label: isFav ? '保存済' : '保存',
                  onTap: () => _toggleFavorite(artwork.id),
                ),
                const SizedBox(height: 20),
                _sideButton(
                  icon: Icons.info_outline,
                  color: Colors.white,
                  label: '詳細',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailScreen(artwork: artwork)),
                    );
                  },
                ),
              ],
            ),
          ),
          // Bottom info
          Positioned(
            bottom: 40,
            left: 24,
            right: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (translatedTitle != null) ...[
                  Text(
                    translatedTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artwork.title,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ] else ...[
                  Text(
                    artwork.title,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${TranslateService.translateArtist(artwork.artist)}  •  ${artwork.date}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
