import 'package:flutter/foundation.dart' show kIsWeb;

class Artwork {
  final int id;
  final String title;
  final String artist;
  final String date;
  final String? imageId;
  final String? description;
  final String? medium;
  final String? dimensions;
  final String? creditLine;
  final String? placeOfOrigin;

  Artwork({
    required this.id,
    required this.title,
    required this.artist,
    required this.date,
    this.imageId,
    this.description,
    this.medium,
    this.dimensions,
    this.creditLine,
    this.placeOfOrigin,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      artist: json['artist_title'] as String? ?? 'Unknown',
      date: json['date_display'] as String? ?? '',
      imageId: json['image_id'] as String?,
      description: json['thumbnail']?['alt_text'] as String?,
    );
  }

  factory Artwork.fromDetailJson(Map<String, dynamic> json) {
    final desc = json['description'] as String?;
    final altText = json['thumbnail']?['alt_text'] as String?;
    return Artwork(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled',
      artist: json['artist_title'] as String? ?? 'Unknown',
      date: json['date_display'] as String? ?? '',
      imageId: json['image_id'] as String?,
      description: desc ?? altText,
      medium: json['medium_display'] as String?,
      dimensions: json['dimensions'] as String?,
      creditLine: json['credit_line'] as String?,
      placeOfOrigin: json['place_of_origin'] as String?,
    );
  }

  static const _proxyBase = 'https://impressionist-bot.vercel.app/api/image';

  String? get imageUrl {
    if (imageId == null) return null;
    if (kIsWeb) {
      return 'https://www.artic.edu/iiif/2/$imageId/full/843,/0/default.jpg';
    }
    return '$_proxyBase?id=$imageId&w=843';
  }

  String? get imageUrlHigh {
    if (imageId == null) return null;
    if (kIsWeb) {
      return 'https://www.artic.edu/iiif/2/$imageId/full/1686,/0/default.jpg';
    }
    return '$_proxyBase?id=$imageId&w=1686';
  }
}
