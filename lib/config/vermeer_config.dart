import 'package:flutter/material.dart';
import 'app_config.dart';

const vermeerConfig = AppConfig(
  appName: 'フェルメールさんぽ',
  appNameEn: 'Vermeer Walk',
  splashIcon: '\u{1F5BC}', // 🖼
  themeColor: Color(0xFF1565C0),
  museumUrl: 'https://www.wikidata.org/wiki',
  appUrl: 'https://sanpo-vermeer.vercel.app',
  hasTimeline: false,
  hasArtistProfiles: false,
  artworkLabel: '名画',
  filterCategories: [
    FilterCategory(label: 'すべて'),
    FilterCategory(label: '1650年代', query: '1650s'),
    FilterCategory(label: '1660年代', query: '1660s'),
    FilterCategory(label: '1670年代', query: '1670s'),
  ],
);
