import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslateService {
  static final Map<String, String> _cache = {};

  static const Map<String, String> artistNames = {
    // 印象派
    'Claude Monet': 'クロード・モネ',
    'Pierre-Auguste Renoir': 'ピエール＝オーギュスト・ルノワール',
    'Edgar Degas': 'エドガー・ドガ',
    'Camille Pissarro': 'カミーユ・ピサロ',
    'Alfred Sisley': 'アルフレッド・シスレー',
    'Berthe Morisot': 'ベルト・モリゾ',
    'Gustave Caillebotte': 'ギュスターヴ・カイユボット',
    // ポスト印象派
    'Vincent van Gogh': 'フィンセント・ファン・ゴッホ',
    'Paul Cézanne': 'ポール・セザンヌ',
    'Paul Gauguin': 'ポール・ゴーギャン',
    'Georges Seurat': 'ジョルジュ・スーラ',
    'Henri de Toulouse-Lautrec': 'アンリ・ド・トゥールーズ＝ロートレック',
    'Paul Signac': 'ポール・シニャック',
    'Édouard Manet': 'エドゥアール・マネ',
    'Mary Cassatt': 'メアリー・カサット',
  };

  static String translateArtist(String name) {
    return artistNames[name] ?? name;
  }

  static Future<String> toJapanese(String text) async {
    if (text.trim().isEmpty) return text;

    // Check cache
    if (_cache.containsKey(text)) return _cache[text]!;

    try {
      final encoded = Uri.encodeComponent(text);
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=ja&dt=t&q=$encoded',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return text;

      final data = jsonDecode(response.body);
      final sentences = data[0] as List<dynamic>;
      final translated = sentences.map((s) => s[0] as String).join();

      _cache[text] = translated;
      return translated;
    } catch (e) {
      return text;
    }
  }
}
