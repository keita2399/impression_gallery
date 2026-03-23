import 'package:flutter/material.dart';
import 'app_config.dart';

const clevelandConfig = AppConfig(
  appName: 'クリーブランド美術館さんぽ',
  appNameEn: 'Cleveland Museum of Art Walk',
  splashIcon: '\u{1F3DB}', // 🏛
  themeColor: Color(0xFF006B3F),
  museumUrl: 'https://clevelandart.org/art',
  appUrl: 'https://sanpo-cleveland.vercel.app',
  hasTimeline: false,
  hasArtistProfiles: false,
  artworkLabel: '名作',
  filterCategories: [
    FilterCategory(label: 'すべて'),
    FilterCategory(label: 'モネ', query: 'monet'),
    FilterCategory(label: 'ゴッホ', query: 'van gogh'),
    FilterCategory(label: 'ピカソ', query: 'picasso'),
    FilterCategory(label: 'ルノワール', query: 'renoir'),
    FilterCategory(label: 'ターナー', query: 'turner'),
    FilterCategory(label: '日本美術', query: 'japanese'),
    FilterCategory(label: '中国美術', query: 'chinese'),
    FilterCategory(label: '絵画', query: 'painting'),
    FilterCategory(label: '彫刻', query: 'sculpture'),
  ],
);
