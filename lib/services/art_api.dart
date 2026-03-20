import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artwork.dart';

class ArtApi {
  static const _baseUrl = 'https://collectionapi.metmuseum.org/public/collection/v1';

  /// Met Museum APIは画像URLを直接返すのでヘッダー不要
  static const imageHeaders = <String, String>{};

  /// JSONレスポンスかどうか判定
  static bool _isJson(String body) {
    final trimmed = body.trimLeft();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }

  /// 安全にJSONデコード（失敗時はnull）
  static dynamic _safeDecode(String body) {
    if (!_isJson(body)) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  /// HTTP GETリクエスト（Imperva CDNチャレンジ対策付き）
  /// JSONでないレスポンスが返ってきた場合は最大3回リトライ
  static Future<http.Response> _get(Uri url) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await http.get(url);
        if (response.statusCode != 200) return response;
        if (_isJson(response.body)) return response;
        // JSON以外（CDNチャレンジ等）の場合リトライ
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      } catch (_) {
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
    return await http.get(url);
  }

  /// 検索用: オブジェクトIDリストを取得
  static Future<List<int>> searchObjectIds({
    String? query,
    int? departmentId,
    bool hasImages = true,
    bool isPublicDomain = true,
    bool isHighlight = false,
  }) async {
    final params = <String, String>{};
    if (hasImages) params['hasImages'] = 'true';
    if (isPublicDomain) params['isPublicDomain'] = 'true';
    if (isHighlight) params['isHighlight'] = 'true';
    if (departmentId != null) params['departmentId'] = departmentId.toString();
    params['q'] = query ?? '*';

    final url = Uri.parse('$_baseUrl/search').replace(queryParameters: params);
    final response = await _get(url);

    if (response.statusCode != 200) {
      throw Exception('検索に失敗しました (${response.statusCode})');
    }

    final data = _safeDecode(response.body);
    if (data == null) {
      throw Exception('APIがブロックされています。しばらく待ってから再試行してください。');
    }

    final List<dynamic>? ids = data['objectIDs'];
    return ids?.cast<int>() ?? [];
  }

  /// 作品詳細を取得
  static Future<Artwork?> fetchArtworkDetail(int id) async {
    final url = Uri.parse('$_baseUrl/objects/$id');
    try {
      final response = await _get(url);
      if (response.statusCode != 200) return null;

      final data = _safeDecode(response.body);
      if (data == null || data['objectID'] == null) return null;

      return Artwork.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// メイン取得メソッド: ハイライト作品を並列取得
  static Future<List<Artwork>> fetchHighlights({
    int? departmentId,
    String? query,
    int limit = 80,
  }) async {
    final ids = await searchObjectIds(
      query: query ?? '*',
      departmentId: departmentId,
      isHighlight: true,
    );

    return _fetchArtworksByIds(ids, limit: limit);
  }

  /// 公開ドメイン作品を取得
  static Future<List<Artwork>> fetchPublicDomainWorks({
    String? query,
    int? departmentId,
    int limit = 100,
  }) async {
    final ids = await searchObjectIds(
      query: query ?? '*',
      departmentId: departmentId,
    );

    return _fetchArtworksByIds(ids, limit: limit);
  }

  /// IDリストから並列で作品詳細を取得（10件ずつバッチ）
  static Future<List<Artwork>> _fetchArtworksByIds(List<int> ids, {int limit = 80}) async {
    final targetIds = ids.take(limit).toList();
    final artworks = <Artwork>[];

    for (var i = 0; i < targetIds.length; i += 10) {
      final batch = targetIds.skip(i).take(10);
      final futures = batch.map((id) => fetchArtworkDetail(id));
      final results = await Future.wait(futures);
      for (final artwork in results) {
        if (artwork != null && artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty) {
          artworks.add(artwork);
        }
      }
    }

    return artworks;
  }
}
