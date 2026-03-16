class ArtistProfile {
  final String name;
  final String nameJa;
  final String born;
  final String died;
  final String nationality;
  final String movement;
  final String description;

  const ArtistProfile({
    required this.name,
    required this.nameJa,
    required this.born,
    required this.died,
    required this.nationality,
    required this.movement,
    required this.description,
  });

  static const List<ArtistProfile> all = [
    ArtistProfile(
      name: 'Claude Monet',
      nameJa: 'クロード・モネ',
      born: '1840',
      died: '1926',
      nationality: 'フランス',
      movement: '印象派',
      description: '印象派の創始者の一人。光と色彩の変化を追求し、「睡蓮」「印象・日の出」など自然の一瞬を捉えた作品で知られる。ジヴェルニーの庭園で晩年まで制作を続けた。',
    ),
    ArtistProfile(
      name: 'Pierre-Auguste Renoir',
      nameJa: 'ピエール＝オーギュスト・ルノワール',
      born: '1841',
      died: '1919',
      nationality: 'フランス',
      movement: '印象派',
      description: '人物画の名手。柔らかな色彩と光に満ちた幸福な日常を描いた。「ムーラン・ド・ラ・ギャレットの舞踏会」「舟遊びをする人々の昼食」が代表作。',
    ),
    ArtistProfile(
      name: 'Edgar Degas',
      nameJa: 'エドガー・ドガ',
      born: '1834',
      died: '1917',
      nationality: 'フランス',
      movement: '印象派',
      description: '踊り子や競馬など動きのある瞬間を独特の構図で切り取った画家。パステル画の名手でもあり、写真的なアングルと大胆なトリミングが特徴。',
    ),
    ArtistProfile(
      name: 'Vincent van Gogh',
      nameJa: 'フィンセント・ファン・ゴッホ',
      born: '1853',
      died: '1890',
      nationality: 'オランダ',
      movement: 'ポスト印象派',
      description: '激しい筆致と鮮烈な色彩で内面の感情を表現した。「星月夜」「ひまわり」が有名。画家としての活動はわずか10年だが、約2000点もの作品を残した。',
    ),
    ArtistProfile(
      name: 'Paul Cézanne',
      nameJa: 'ポール・セザンヌ',
      born: '1839',
      died: '1906',
      nationality: 'フランス',
      movement: 'ポスト印象派',
      description: '「近代絵画の父」と呼ばれ、キュビスムへの道を開いた。自然を円筒・球・円錐に還元する独自の理論で、サント・ヴィクトワール山を繰り返し描いた。',
    ),
    ArtistProfile(
      name: 'Paul Gauguin',
      nameJa: 'ポール・ゴーギャン',
      born: '1848',
      died: '1903',
      nationality: 'フランス',
      movement: 'ポスト印象派',
      description: 'タヒチに渡り、原始的な美と精神性を追求した。平面的な色面と力強い輪郭線が特徴。ゴッホとの共同生活でも知られる。',
    ),
    ArtistProfile(
      name: 'Édouard Manet',
      nameJa: 'エドゥアール・マネ',
      born: '1832',
      died: '1883',
      nationality: 'フランス',
      movement: '印象派の先駆者',
      description: '印象派の父と称される。「草上の昼食」「オランピア」で当時のアカデミズムに衝撃を与え、近代美術の扉を開いた。',
    ),
    ArtistProfile(
      name: 'Camille Pissarro',
      nameJa: 'カミーユ・ピサロ',
      born: '1830',
      died: '1903',
      nationality: 'フランス（デンマーク領生まれ）',
      movement: '印象派',
      description: '印象派グループの長老的存在。8回の印象派展すべてに参加した唯一の画家。農村風景や都市の情景を温かみのある筆致で描いた。',
    ),
    ArtistProfile(
      name: 'Georges Seurat',
      nameJa: 'ジョルジュ・スーラ',
      born: '1859',
      died: '1891',
      nationality: 'フランス',
      movement: '新印象派（点描派）',
      description: '色彩理論に基づく点描技法を確立。「グランド・ジャット島の日曜日の午後」は新印象派の記念碑的作品。31歳で夭折。',
    ),
    ArtistProfile(
      name: 'Mary Cassatt',
      nameJa: 'メアリー・カサット',
      born: '1844',
      died: '1926',
      nationality: 'アメリカ',
      movement: '印象派',
      description: '印象派で活躍した数少ない女性画家。母と子の親密な姿を描いた作品が多く、日本の浮世絵からも影響を受けた独自の画風を確立。',
    ),
    ArtistProfile(
      name: 'Alfred Sisley',
      nameJa: 'アルフレッド・シスレー',
      born: '1839',
      died: '1899',
      nationality: 'イギリス（フランス在住）',
      movement: '印象派',
      description: '最も純粋な印象派の風景画家と評される。セーヌ河畔やモレの風景を穏やかな光と色彩で描き続けた。',
    ),
    ArtistProfile(
      name: 'Berthe Morisot',
      nameJa: 'ベルト・モリゾ',
      born: '1841',
      died: '1895',
      nationality: 'フランス',
      movement: '印象派',
      description: '印象派の創設メンバーの一人で、マネの義妹。女性の日常生活や子どもの姿を軽やかな筆致と繊細な色彩で描いた。',
    ),
    ArtistProfile(
      name: 'Gustave Caillebotte',
      nameJa: 'ギュスターヴ・カイユボット',
      born: '1848',
      died: '1894',
      nationality: 'フランス',
      movement: '印象派',
      description: '大胆な透視図法と写実的な都市風景で知られる。「パリの通り、雨の日」が代表作。印象派画家のパトロンとしても重要な役割を果たした。',
    ),
    ArtistProfile(
      name: 'Henri de Toulouse-Lautrec',
      nameJa: 'アンリ・ド・トゥールーズ＝ロートレック',
      born: '1864',
      died: '1901',
      nationality: 'フランス',
      movement: 'ポスト印象派',
      description: 'モンマルトルの夜の世界を鮮やかに描いた。ムーラン・ルージュのポスターで有名。リトグラフの芸術性を高め、グラフィックデザインの先駆者となった。',
    ),
    ArtistProfile(
      name: 'Paul Signac',
      nameJa: 'ポール・シニャック',
      born: '1863',
      died: '1935',
      nationality: 'フランス',
      movement: '新印象派（点描派）',
      description: 'スーラとともに新印象派を牽引。港や海岸の風景を色鮮やかな点描で描いた。理論家としても活躍し、新印象派の普及に貢献。',
    ),
  ];

  static ArtistProfile? byName(String name) {
    try {
      return all.firstWhere((a) => a.name == name);
    } catch (_) {
      return null;
    }
  }
}
