import '../models/artwork.dart';
import 'wikidata_artist_api.dart';

/// モネ全作品API（WikidataArtistApiのモネ設定）
class MonetApi extends WikidataArtistApi {
  MonetApi()
      : super(
          artistQid: 'Q296',
          artistNameJa: 'クロード・モネ',
          artistCountry: 'フランス',
          filters: {
            '1860s': (Artwork w) => w.date.startsWith('186'),
            '1870s': (Artwork w) => w.date.startsWith('187'),
            '1880s': (Artwork w) => w.date.startsWith('188'),
            '1890s': (Artwork w) => w.date.startsWith('189'),
            '1900s': (Artwork w) => w.date.startsWith('190'),
            '1910s': (Artwork w) => w.date.startsWith('191'),
            '1920s': (Artwork w) => w.date.startsWith('192'),
          },
        );
}
