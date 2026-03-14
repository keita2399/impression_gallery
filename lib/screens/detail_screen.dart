import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/artwork.dart';
import '../services/art_api.dart';
import '../services/translate_service.dart';

class DetailScreen extends StatefulWidget {
  final Artwork artwork;

  const DetailScreen({super.key, required this.artwork});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Artwork? _detail;
  bool _loading = true;
  String? _translatedDescription;
  String? _translatedTitle;
  String? _translatedMedium;
  String? _translatedOrigin;
  String? _translatedCredit;
  bool _translating = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final detail = await ArtApi.fetchArtworkDetail(widget.artwork.id);
    setState(() {
      _detail = detail ?? widget.artwork;
      _loading = false;
    });
    _translateContent();
  }

  Future<void> _translateContent() async {
    final artwork = _detail ?? widget.artwork;
    setState(() => _translating = true);

    try {
      final futures = <Future>[];

      futures.add(
        TranslateService.toJapanese(artwork.title).then((t) {
          if (mounted) setState(() => _translatedTitle = t);
        }),
      );

      if (artwork.description != null) {
        final cleanDesc = artwork.description!.replaceAll(RegExp(r'<[^>]*>'), '');
        futures.add(
          TranslateService.toJapanese(cleanDesc).then((t) {
            if (mounted) setState(() => _translatedDescription = t);
          }),
        );
      }

      if (artwork.medium != null) {
        futures.add(
          TranslateService.toJapanese(artwork.medium!).then((t) {
            if (mounted) setState(() => _translatedMedium = t);
          }),
        );
      }

      if (artwork.placeOfOrigin != null) {
        futures.add(
          TranslateService.toJapanese(artwork.placeOfOrigin!).then((t) {
            if (mounted) setState(() => _translatedOrigin = t);
          }),
        );
      }

      if (artwork.creditLine != null) {
        futures.add(
          TranslateService.toJapanese(artwork.creditLine!).then((t) {
            if (mounted) setState(() => _translatedCredit = t);
          }),
        );
      }

      await Future.wait(futures);
    } catch (_) {}

    if (mounted) setState(() => _translating = false);
  }

  @override
  Widget build(BuildContext context) {
    final artwork = _detail ?? widget.artwork;
    final jaArtist = TranslateService.translateArtist(artwork.artist);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.5,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  final jaArtist = TranslateService.translateArtist(artwork.artist);
                  final jaTitle = _translatedTitle ?? artwork.title;
                  SharePlus.instance.share(
                    ShareParams(
                      text: '$jaTitle\n$jaArtist（${artwork.date}）\n\nhttps://www.artic.edu/artworks/${artwork.id}',
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: artwork.imageUrl != null
                  ? InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 8.0,
                      child: Image.network(
                        artwork.imageUrlHigh ?? artwork.imageUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  if (_translatedTitle != null) ...[
                    Text(
                      _translatedTitle!,
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artwork.title,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ] else ...[
                    Text(
                      artwork.title,
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.3),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Artist & Date
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(jaArtist, style: const TextStyle(color: Colors.white, fontSize: 14)),
                            if (jaArtist != artwork.artist)
                              Text(artwork.artist, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(artwork.date, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                    ],
                  ),
                  // Description
                  if (artwork.description != null) ...[
                    const SizedBox(height: 24),
                    if (_translatedDescription != null)
                      Text(
                        _translatedDescription!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15, height: 1.7),
                      )
                    else if (_translating)
                      Row(
                        children: [
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 8),
                          Text('翻訳中...', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                        ],
                      )
                    else
                      _removeHtmlTags(artwork.description!),
                  ],
                  if (_loading) ...[
                    const SizedBox(height: 24),
                    const Center(child: CircularProgressIndicator()),
                  ],
                  if (!_loading) ...[
                    if (artwork.medium != null) ...[
                      const SizedBox(height: 24),
                      _infoRow('技法・素材', _translatedMedium ?? artwork.medium!),
                    ],
                    if (artwork.dimensions != null) ...[
                      const SizedBox(height: 12),
                      _infoRow('サイズ', artwork.dimensions!),
                    ],
                    if (artwork.placeOfOrigin != null) ...[
                      const SizedBox(height: 12),
                      _infoRow('制作地', _translatedOrigin ?? artwork.placeOfOrigin!),
                    ],
                    if (artwork.creditLine != null) ...[
                      const SizedBox(height: 12),
                      _infoRow('所蔵', _translatedCredit ?? artwork.creditLine!),
                    ],
                  ],
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'ピンチで筆のタッチを拡大できます',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _removeHtmlTags(String html) {
    final text = html.replaceAll(RegExp(r'<[^>]*>'), '');
    return Text(
      text,
      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15, height: 1.7),
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.4)),
      ],
    );
  }
}
