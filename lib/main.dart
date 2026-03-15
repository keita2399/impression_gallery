import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'services/art_api.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Anonymous sign-in and sync favorites
  await FirestoreService.signInAnonymously();
  await FirestoreService.syncLocalToCloud();
  await FirestoreService.syncCloudToLocal();

  // URLパラメータから作品IDを取得（LINEからのディープリンク対応）
  int? artworkId;
  final uri = Uri.parse(html.window.location.href);
  final idParam = uri.queryParameters['id'];
  if (idParam != null) {
    artworkId = int.tryParse(idParam);
  }

  runApp(ImpressionGalleryApp(artworkId: artworkId));
}

class ImpressionGalleryApp extends StatelessWidget {
  final int? artworkId;
  const ImpressionGalleryApp({super.key, this.artworkId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '印象派さんぽ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: artworkId != null
          ? DeepLinkScreen(artworkId: artworkId!)
          : const HomeScreen(),
    );
  }
}

/// ディープリンクで作品IDを受け取った時の画面
class DeepLinkScreen extends StatefulWidget {
  final int artworkId;
  const DeepLinkScreen({super.key, required this.artworkId});

  @override
  State<DeepLinkScreen> createState() => _DeepLinkScreenState();
}

class _DeepLinkScreenState extends State<DeepLinkScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  Future<void> _loadArtwork() async {
    try {
      final artwork = await ArtApi.fetchArtworkDetail(widget.artworkId);
      if (artwork != null && mounted) {
        setState(() => _loading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(artwork: artwork),
          ),
        );
      } else if (mounted) {
        // 作品が見つからない場合はホームへ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
