import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/artwork.dart';
import '../services/art_api.dart';
import '../services/firestore_service.dart';
import '../services/translate_service.dart';
import 'detail_screen.dart';

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> with SingleTickerProviderStateMixin {
  List<Artwork> _allWorks = [];
  Artwork? _result;
  bool _loading = true;
  bool _rolling = false;
  bool _alreadyDrawnToday = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  String? _translatedTitle;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('gacha_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    try {
      final works = await ArtApi.fetchImpressionistWorks(limit: 100);
      setState(() {
        _allWorks = works;
        _loading = false;
      });

      if (lastDate == today) {
        final savedId = prefs.getInt('gacha_result');
        if (savedId != null) {
          final saved = works.where((w) => w.id == savedId).toList();
          if (saved.isNotEmpty) {
            setState(() {
              _result = saved.first;
              _alreadyDrawnToday = true;
            });
            _animController.forward();
            _translateResult(saved.first);
          }
        }
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _translateResult(Artwork artwork) async {
    final title = await TranslateService.toJapanese(artwork.title);
    if (mounted) setState(() => _translatedTitle = title);
  }

  Future<void> _drawGacha() async {
    if (_allWorks.isEmpty || _rolling) return;

    setState(() {
      _rolling = true;
      _translatedTitle = null;
    });
    _animController.reset();

    await Future.delayed(const Duration(milliseconds: 800));

    final random = Random();
    final artwork = _allWorks[random.nextInt(_allWorks.length)];

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString('gacha_date', today);
    await prefs.setInt('gacha_result', artwork.id);

    // Add to favorites automatically
    await FirestoreService.addFavorite(artwork.id);

    setState(() {
      _result = artwork;
      _rolling = false;
      _alreadyDrawnToday = true;
    });
    _animController.forward();
    _translateResult(artwork);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 32),
          const Text(
            '今日の名画ガチャ',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '毎日ひとつ、新しい名画と出会おう',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _result != null ? _buildResult() : _buildDrawButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawButton() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_rolling) ...[
            const SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.amber),
            ),
            const SizedBox(height: 24),
            const Text('抽選中...', style: TextStyle(color: Colors.white70, fontSize: 16)),
          ] else ...[
            GestureDetector(
              onTap: _drawGacha,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.palette, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text('引く', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'タップして今日の名画を引こう',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult() {
    final artwork = _result!;
    return ScaleTransition(
      scale: _scaleAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(artwork: artwork)),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: artwork.imageUrl != null
                      ? Image.network(
                          artwork.imageUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                        )
                      : const SizedBox(height: 200),
                ),
              ),
              const SizedBox(height: 20),
              if (_translatedTitle != null) ...[
                Text(
                  _translatedTitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  artwork.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ] else ...[
                Text(
                  artwork.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '${TranslateService.translateArtist(artwork.artist)}  •  ${artwork.date}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _alreadyDrawnToday ? 'コレクションに追加済み！' : '新しい発見！',
                  style: const TextStyle(color: Colors.amber, fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'タップで詳細を見る',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }
}
