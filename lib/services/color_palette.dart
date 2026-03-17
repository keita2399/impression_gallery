import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ColorInfo {
  final Color color;
  final double percentage;
  const ColorInfo(this.color, this.percentage);
}

class ColorPaletteExtractor {
  /// Extract dominant colors with percentages from an image URL
  static Future<List<ColorInfo>> extract(String imageUrl, {int count = 5}) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) return [];

      final codec = await ui.instantiateImageCodec(response.bodyBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final pixels = await _samplePixels(image, sampleSize: 1000);
      image.dispose();

      if (pixels.isEmpty) return [];

      return _kMeans(pixels, count);
    } catch (_) {
      return [];
    }
  }

  static Future<List<_Pixel>> _samplePixels(ui.Image image, {int sampleSize = 1000}) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return [];

    final pixels = <_Pixel>[];
    final data = byteData.buffer.asUint8List();
    final totalPixels = image.width * image.height;
    final step = max(1, totalPixels ~/ sampleSize);

    for (int i = 0; i < totalPixels; i += step) {
      final offset = i * 4;
      if (offset + 3 >= data.length) break;

      final r = data[offset];
      final g = data[offset + 1];
      final b = data[offset + 2];
      final a = data[offset + 3];

      if (a < 128) continue;
      final brightness = (r + g + b) / 3;
      if (brightness < 15 || brightness > 245) continue;

      pixels.add(_Pixel(r.toDouble(), g.toDouble(), b.toDouble()));
    }

    return pixels;
  }

  static List<ColorInfo> _kMeans(List<_Pixel> pixels, int k, {int maxIterations = 20}) {
    if (pixels.length < k) {
      return pixels.map((p) => ColorInfo(p.toColor(), 100.0 / pixels.length)).toList();
    }

    final random = Random(42);

    // Initialize centroids with k-means++
    final centroids = <_Pixel>[];
    centroids.add(pixels[random.nextInt(pixels.length)]);

    for (int i = 1; i < k; i++) {
      double totalDist = 0;
      final distances = <double>[];
      for (final p in pixels) {
        double minDist = double.infinity;
        for (final c in centroids) {
          final d = p.distanceTo(c);
          if (d < minDist) minDist = d;
        }
        distances.add(minDist);
        totalDist += minDist;
      }
      double target = random.nextDouble() * totalDist;
      for (int j = 0; j < pixels.length; j++) {
        target -= distances[j];
        if (target <= 0) {
          centroids.add(pixels[j]);
          break;
        }
      }
      if (centroids.length <= i) centroids.add(pixels[random.nextInt(pixels.length)]);
    }

    // Iterate
    final assignments = List<int>.filled(pixels.length, 0);
    for (int iter = 0; iter < maxIterations; iter++) {
      bool changed = false;
      for (int i = 0; i < pixels.length; i++) {
        int nearest = 0;
        double minDist = pixels[i].distanceTo(centroids[0]);
        for (int j = 1; j < k; j++) {
          final d = pixels[i].distanceTo(centroids[j]);
          if (d < minDist) {
            minDist = d;
            nearest = j;
          }
        }
        if (assignments[i] != nearest) {
          assignments[i] = nearest;
          changed = true;
        }
      }
      if (!changed) break;

      for (int j = 0; j < k; j++) {
        double sumR = 0, sumG = 0, sumB = 0;
        int count = 0;
        for (int i = 0; i < pixels.length; i++) {
          if (assignments[i] == j) {
            sumR += pixels[i].r;
            sumG += pixels[i].g;
            sumB += pixels[i].b;
            count++;
          }
        }
        if (count > 0) {
          centroids[j] = _Pixel(sumR / count, sumG / count, sumB / count);
        }
      }
    }

    // Calculate cluster sizes and percentages
    final clusterSizes = List<int>.filled(k, 0);
    for (final a in assignments) {
      clusterSizes[a]++;
    }
    final total = pixels.length;

    // Sort by size (most dominant first)
    final indices = List.generate(k, (i) => i);
    indices.sort((a, b) => clusterSizes[b].compareTo(clusterSizes[a]));

    return indices.map((i) {
      final pct = (clusterSizes[i] / total * 100);
      return ColorInfo(centroids[i].toColor(), pct);
    }).toList();
  }
}

class _Pixel {
  final double r, g, b;
  const _Pixel(this.r, this.g, this.b);

  double distanceTo(_Pixel other) {
    final dr = r - other.r;
    final dg = g - other.g;
    final db = b - other.b;
    return dr * dr + dg * dg + db * db;
  }

  Color toColor() => Color.fromARGB(255, r.round().clamp(0, 255), g.round().clamp(0, 255), b.round().clamp(0, 255));
}
