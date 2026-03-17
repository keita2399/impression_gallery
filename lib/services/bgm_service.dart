import 'bgm_audio_stub.dart' if (dart.library.js_interop) 'bgm_audio_web.dart';

class BgmTrack {
  final String title;
  final String composer;
  final String url;
  const BgmTrack({required this.title, required this.composer, required this.url});
}

class BgmService {
  static final BgmService _instance = BgmService._();
  static BgmService get instance => _instance;
  BgmService._();

  int _currentIndex = 0;
  bool _playing = false;

  // Archive.org public domain recordings
  static const tracks = <BgmTrack>[
    BgmTrack(
      title: 'ジムノペディ 第1番',
      composer: 'エリック・サティ',
      url: 'https://archive.org/download/SatieGymnopedieNo.1./Satie-Gymnopedie%20No.%201..mp3',
    ),
    BgmTrack(
      title: '月の光',
      composer: 'クロード・ドビュッシー',
      url: 'https://archive.org/download/ClairDeLune_201412/Clair%20de%20Lune.mp3',
    ),
    BgmTrack(
      title: 'アラベスク 第1番・第2番',
      composer: 'クロード・ドビュッシー',
      url: 'https://archive.org/download/DebussyArabesqueNo.1AndNo.2/Debussy%20-%20Arabesque%20No.1%20and%20No.2.mp3',
    ),
  ];

  BgmTrack get currentTrack => tracks[_currentIndex];
  bool get isPlaying => _playing;

  Future<void> play() async {
    _playing = true;
    playAudioWeb(tracks[_currentIndex].url);
  }

  Future<void> pause() async {
    _playing = false;
    pauseAudioWeb();
  }

  Future<void> toggle() async {
    if (_playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    _currentIndex = (_currentIndex + 1) % tracks.length;
    _playing = true;
    playAudioWeb(tracks[_currentIndex].url);
  }

  Future<void> previous() async {
    _currentIndex = (_currentIndex - 1 + tracks.length) % tracks.length;
    _playing = true;
    playAudioWeb(tracks[_currentIndex].url);
  }
}
