import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artwork.dart';

class ArtApi {
  static const _baseUrl = 'https://api.artic.edu/api/v1';
  static const _fields = 'id,title,artist_title,date_display,image_id,thumbnail,style_titles';

  /// IIIF画像サーバーのCloudflare制限を回避するためのヘッダー
  static const imageHeaders = <String, String>{
    'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  };

  static const impressionistArtists = [
    // 印象派
    'Claude Monet',
    'Pierre-Auguste Renoir',
    'Edgar Degas',
    'Camille Pissarro',
    'Alfred Sisley',
    'Berthe Morisot',
    'Gustave Caillebotte',
    // ポスト印象派
    'Vincent van Gogh',
    'Paul Cézanne',
    'Paul Gauguin',
    'Georges Seurat',
    'Henri de Toulouse-Lautrec',
    'Paul Signac',
    'Édouard Manet',
    'Mary Cassatt',
  ];

  static Future<List<Artwork>> fetchImpressionistWorks({
    int page = 1,
    int limit = 100,
    String? artistFilter,
  }) async {
    final url = Uri.parse('$_baseUrl/artworks/search?fields=$_fields&page=$page&limit=$limit');

    final artists = artistFilter != null ? [artistFilter] : impressionistArtists;

    final body = jsonEncode({
      "query": {
        "bool": {
          "must": [
            {"terms": {"artist_title.keyword": artists}},
            {"term": {"is_public_domain": true}},
            {"exists": {"field": "image_id"}},
          ]
        }
      }
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'ImpressionGallery/1.0 (Flutter App)',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch artworks: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final List<dynamic> items = data['data'] ?? [];

    return items
        .map((json) => Artwork.fromJson(json as Map<String, dynamic>))
        .where((a) => a.imageId != null)
        .toList();
  }

  static Future<Artwork?> fetchArtworkDetail(int id) async {
    final url = Uri.parse('$_baseUrl/artworks/$id?fields=$_fields,description,publication_history,exhibition_history,place_of_origin,medium_display,dimensions,credit_line');

    final response = await http.get(url, headers: {
      'User-Agent': 'ImpressionGallery/1.0 (Flutter App)',
    });
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final artData = data['data'] as Map<String, dynamic>?;
    if (artData == null) return null;

    return Artwork.fromDetailJson(artData);
  }
}
