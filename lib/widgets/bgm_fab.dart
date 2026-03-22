import 'package:flutter/material.dart';
import '../services/bgm_service.dart';

/// 全画面で使えるフローティングBGMボタン
class BgmFab extends StatefulWidget {
  const BgmFab({super.key});

  @override
  State<BgmFab> createState() => _BgmFabState();
}

class _BgmFabState extends State<BgmFab> {
  @override
  Widget build(BuildContext context) {
    final playing = BgmService.instance.isPlaying;

    return Positioned(
      bottom: 16,
      right: 16,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            await BgmService.instance.toggle();
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: playing
                  ? Colors.amber.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: playing
                  ? Border.all(color: Colors.amber.withValues(alpha: 0.5))
                  : Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(
              playing ? Icons.music_note : Icons.music_off,
              color: playing ? Colors.amber : Colors.white54,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
