import 'package:flutter/material.dart';

class TimelineEvent {
  final int year;
  final String title;
  final String description;
  final TimelineEventType type;
  final String? imageId;
  final String? artist;
  final String? worldContext; // 同時代の世界史

  const TimelineEvent({
    required this.year,
    required this.title,
    required this.description,
    required this.type,
    this.imageId,
    this.artist,
    this.worldContext,
  });

  static const List<TimelineEvent> all = [
    // 印象派前夜
    // 印象派前夜
    TimelineEvent(year: 1863, title: '落選展', description: 'マネ「草上の昼食」がサロンで拒否され、落選展に出品。アカデミズムへの挑戦の始まり。', type: TimelineEventType.exhibition, artist: 'マネ', worldContext: 'アメリカ南北戦争の最中'),
    TimelineEvent(year: 1865, title: 'オランピア', description: 'マネ「オランピア」がサロンで大スキャンダルに。近代美術の扉を開く。', type: TimelineEventType.masterpiece, artist: 'マネ', worldContext: '南北戦争終結、リンカーン暗殺'),
    TimelineEvent(year: 1869, title: 'ラ・グルヌイエール', description: 'モネとルノワールがセーヌ河畔で並んで制作。印象派の技法が生まれた瞬間。', type: TimelineEventType.milestone, artist: 'モネ', worldContext: 'スエズ運河開通'),

    TimelineEvent(year: 1872, title: '印象・日の出', description: 'モネがル・アーヴルの港を描く。後に「印象派」の名前の由来となる。', type: TimelineEventType.masterpiece, artist: 'モネ', worldContext: '普仏戦争・パリコミューン直後'),
    TimelineEvent(year: 1874, title: '第1回印象派展', description: 'モネ、ルノワール、ドガ、ピサロら30名がナダール写真館で独自の展覧会を開催。', type: TimelineEventType.exhibition, artist: 'ルノワール', worldContext: 'フランス第三共和政の安定期'),
    TimelineEvent(year: 1876, title: '第2回印象派展', description: 'カイユボット「パリの通り、雨の日」が注目を集める。', type: TimelineEventType.exhibition, artist: 'カイユボット', worldContext: 'ベルの電話機が発明された年'),
    TimelineEvent(year: 1877, title: '第3回印象派展', description: 'ルノワール「ムーラン・ド・ラ・ギャレット」を出品。', type: TimelineEventType.exhibition, artist: 'ルノワール', worldContext: 'エジソンが蓄音機を発明'),

    TimelineEvent(year: 1879, title: 'カサットの参加', description: 'メアリー・カサットがドガの招きで印象派展に参加。', type: TimelineEventType.milestone, artist: 'カサット', worldContext: 'エジソンが白熱電球を実用化'),
    TimelineEvent(year: 1881, title: 'ルノワールのイタリア旅行', description: 'ラファエロに感銘を受け、画風が変化。「アングル期」の始まり。', type: TimelineEventType.milestone, artist: 'ルノワール'),
    TimelineEvent(year: 1883, title: 'マネ死去', description: '印象派の父エドゥアール・マネが51歳で死去。', type: TimelineEventType.milestone, artist: 'マネ', worldContext: 'オリエント急行が開通'),

    TimelineEvent(year: 1884, title: 'グランド・ジャット島', description: 'スーラが点描技法による記念碑的大作の制作を開始。新印象派の誕生。', type: TimelineEventType.masterpiece, artist: 'スーラ', worldContext: '自由の女神像が完成間近'),
    TimelineEvent(year: 1886, title: '第8回（最後の）印象派展', description: '最後の印象派展。スーラの「グランド・ジャット島」が出品され、新しい時代の幕開けに。', type: TimelineEventType.exhibition, artist: 'スーラ', worldContext: '自由の女神像がNYに完成'),
    TimelineEvent(year: 1888, title: 'ゴッホとゴーギャン', description: 'アルルでの共同生活。わずか2ヶ月で破綻し、ゴッホの耳切り事件に。', type: TimelineEventType.milestone, artist: 'ゴッホ'),
    TimelineEvent(year: 1889, title: '星月夜', description: 'ゴッホがサン＝レミの精神病院で「星月夜」を制作。', type: TimelineEventType.masterpiece, artist: 'ゴッホ', worldContext: 'パリ万博でエッフェル塔が完成'),
    TimelineEvent(year: 1890, title: 'ゴッホ死去', description: 'フィンセント・ファン・ゴッホがオーヴェル＝シュル＝オワーズで37歳で死去。', type: TimelineEventType.milestone, artist: 'ゴッホ'),
    TimelineEvent(year: 1891, title: 'スーラ死去・ゴーギャンのタヒチ', description: 'スーラが31歳で夭折。ゴーギャンが初めてタヒチに渡る。', type: TimelineEventType.milestone, artist: 'ゴーギャン'),

    TimelineEvent(year: 1895, title: 'セザンヌ初個展', description: 'セザンヌがパリで初の個展を開催。若い画家たちに衝撃を与える。', type: TimelineEventType.exhibition, artist: 'セザンヌ', worldContext: 'リュミエール兄弟が映画を発明'),
    TimelineEvent(year: 1899, title: 'モネの睡蓮', description: 'モネがジヴェルニーの庭で「睡蓮」シリーズの制作を本格化。', type: TimelineEventType.masterpiece, artist: 'モネ', worldContext: 'ドレフュス事件がフランスを二分'),
    TimelineEvent(year: 1903, title: 'ゴーギャン・ピサロ死去', description: 'ゴーギャンがマルキーズ諸島で、ピサロがパリで死去。', type: TimelineEventType.milestone, artist: 'ゴーギャン', worldContext: 'ライト兄弟が初飛行に成功'),
    TimelineEvent(year: 1906, title: 'セザンヌ死去', description: '「近代絵画の父」セザンヌが67歳で死去。キュビスムへの道を開いた。', type: TimelineEventType.milestone, artist: 'セザンヌ', worldContext: 'サンフランシスコ大地震'),
  ];
}

enum TimelineEventType {
  exhibition,  // 展覧会
  masterpiece, // 名作誕生
  milestone,   // 歴史的出来事
}

extension TimelineEventTypeExt on TimelineEventType {
  String get label {
    switch (this) {
      case TimelineEventType.exhibition: return '展覧会';
      case TimelineEventType.masterpiece: return '名作';
      case TimelineEventType.milestone: return '出来事';
    }
  }

  Color get color {
    switch (this) {
      case TimelineEventType.exhibition: return const Color(0xFF4FC3F7);
      case TimelineEventType.masterpiece: return const Color(0xFFFFD54F);
      case TimelineEventType.milestone: return const Color(0xFFE0E0E0);
    }
  }

  IconData get icon {
    switch (this) {
      case TimelineEventType.exhibition: return Icons.museum;
      case TimelineEventType.masterpiece: return Icons.palette;
      case TimelineEventType.milestone: return Icons.star;
    }
  }
}
