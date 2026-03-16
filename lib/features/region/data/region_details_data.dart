import '../models/region_model.dart';

final Map<RegionGroup, RegionDetail> regionDetails = {
  RegionGroup.hokkaido: const RegionDetail(
    name: 'Hokkaido',
    nameKr: '홋카이도',
    description:
        '일본 최북단에 위치한 광활한 대자연의 땅입니다. 사계절이 뚜렷하며 야생의 풍경, 파우더 스노우로 유명한 스키장, 싱싱한 해산물, 그리고 독특한 아이누 문화가 어우러진 매력적인 지역입니다.',
    majorCities: ['삿포로 (Sapporo)', '하코다테 (Hakodate)'],
    topSpots: [
      '니세코/루수쓰/후라노 스키 리조트 (Niseko/Rusutsu/Furano)',
      '시레토코 국립공원 (Shiretoko)',
      '아칸 호수 — 아이누 문화 (Lake Akan)',
    ],
    cultureAndFood: ['삿포로 라멘/맥주', '스시', '여름 하이킹', '온천'],
    images: [
      'https://res.cloudinary.com/palette-michi/image/upload/v1773423215/hokkaido_1_qkisjo.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773423216/hokkaido_2_mi2xkv.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773423216/hokkaido_3_idx2bt.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773423218/hokkaido_4_v7gpo9.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773423215/hokkaido_5_ujtckj.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773423217/hokkaido_6_twfiyb.jpg',
    ],
  ),
  RegionGroup.tohoku: const RegionDetail(
    name: 'Tohoku',
    nameKr: '도호쿠',
    description:
        '자연 경관과 온천, 축제가 풍부한 북동부 지역입니다. 웅장한 자연 속에서 계절의 변화를 느끼기에 최적이며, 겨울에는 신비로운 수빙 현상을 관찰할 수 있는 산악 지대가 인상적입니다.',
    majorCities: ['센다이 (Sendai)', '아오모리 (Aomori)'],
    topSpots: [
      '마쓰시마 (Matsushima Bay)',
      '오이라세 계곡 (Oirase Stream)',
      '긴잔 온천 (Ginzan Onsen)',
      '히로사키 성 (Hirosaki Castle)',
    ],
    cultureAndFood: ['규탄 (우설)', '키리탄포', '네부타 축제', 'Zao 수빙(눈 괴물)'],
    images: [
      'https://res.cloudinary.com/palette-michi/image/upload/v1773425601/tohoku_1_nomg1o.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773424681/tohoku_2_onmoet.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773424679/tohoku_3_poczvh.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773424879/tohoku_4_ehlzd3.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773424680/tohoku_5_l7gww9.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773424681/tohoku_6_zpncum.jpg',
    ],
  ),
  RegionGroup.kanto: const RegionDetail(
    name: 'Kanto',
    nameKr: '간토',
    description:
        '현대적인 대도시와 역사적인 명소가 조화롭게 어우러진 일본의 중심부입니다. 도쿄의 화려한 야경부터 인근 근교의 고즈넉한 에도 시대 마을까지 다채로운 경험을 선사합니다.',
    majorCities: ['도쿄 (Tokyo)', '요코하마 (Yokohama)'],
    topSpots: ['닛코 (Nikko)', '가마쿠라 (Kamakura)', '가와고에 (Kawagoe) — 에도 마을'],
    cultureAndFood: ['스시', '팝 컬쳐', '봄 벚꽃 및 가을 단풍 명소'],
    images: [
      'https://res.cloudinary.com/palette-michi/image/upload/v1773471481/kanto_1_nsrqxg.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1772421474/kanto_2_kavwje.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773471481/kanto_3_vnrxrq.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773471483/kanto_4_wrigdk.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773471479/kanto_5_yirjic.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773471485/kanto_6_mwkbj6.jpg',
    ],
  ),
  RegionGroup.hokurikuShinetsu: const RegionDetail(
    name: 'Hokuriku Shinetsu',
    nameKr: '호쿠리쿠•신에쓰',
    description:
        '일본해와 일본 알프스 사이에 위치하여 전통과 자연의 조화가 아름다운 곳입니다. 예술적인 정원과 유서 깊은 사찰, 그리고 겨울철 풍부한 강설량으로 유명한 지역입니다.',
    majorCities: ['가나자와 (Kanazawa)', '나가노 (Nagano)'],
    topSpots: ['다테야마 알프스 산맥 (Tateyama)', '노토 반도 (Noto)', '겐로쿠엔 정원 (Kenrokuen)'],
    cultureAndFood: ['에치젠 게', '사케', '금박 공예', '시골 마을 탐방'],
    images: [
      'https://res.cloudinary.com/palette-michi/image/upload/v1773472783/hokuriku_1_xqeyt3.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773472776/hokuriku_2_pn0p9l.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773472779/hokuriku_3_yskvkc.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773472785/hokuriku_4_ou42vp.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773472781/hokuriku_5_nhob1e.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773472778/hokuriku_6_o8xdpt.jpg',
    ],
  ),
  RegionGroup.tokai: const RegionDetail(
    name: 'Tokai',
    nameKr: '도카이',
    description:
        '후지산과 고대 유산, 드넓은 녹차밭이 있는 전형적인 일본의 풍경을 간직한 지역입니다. 일본의 영적 중심지인 신사와 유네스코 세계유산 마을이 조화를 이룹니다.',
    majorCities: ['나고야 (Nagoya)', '시즈오카 (Shizuoka)'],
    topSpots: [
      '후지산 (Mt. Fuji)',
      '시라카와고 (Shirakawa-go)',
      '이세진구 (Ise-Jingu)',
      '다카야마 (Takayama)',
    ],
    cultureAndFood: ['시즈오카 녹차', '히다규(와규)', '사케 양조장', '불꽃 축제'],
    images: [
      'https://res.cloudinary.com/palette-michi/image/upload/v1773473942/tokai_1_rctrgq.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773473949/tokai_2_fotssy.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773473947/tokai_3_ihingq.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773473944/tokai_4_abgk3o.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773473951/tokai_5_uuynbo.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773473944/tokai_6_bzq41f.jpg',
    ],
  ),
  RegionGroup.kansai: const RegionDetail(
    name: 'Kansai',
    nameKr: '간사이',
    description:
        '일본의 영적 및 문화적 중심지로 수많은 사찰과 활기찬 밤문화가 풍성한 지역입니다. 전통적인 가이세키 요리부터 길거리 음식의 천국까지 미식가들에게도 완벽한 장소입니다.',
    majorCities: ['교토 (Kyoto)', '오사카 (Osaka)', '나라 (Nara)'],
    topSpots: ['히메지 성 (Himeji Castle)', '고야산 (Koyasan)', '고베 항구 전망대 (Kobe)'],
    cultureAndFood: ['오코노미야키', '가이세키 요리', '선(Zen) 정원', '역사 지구'],
    images: [
      'https://res.cloudinary.com/palette-michi/image/upload/v1773502964/kansai_1_xj6vsj.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773503331/kansai_2_feixsw.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773503048/kansai_3_lfxj9x.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773502960/kansai_4_km657z.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773502968/kansai_5_cvsuzw.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773502962/kansai_6_wt0zqo.jpg',
    ],
  ),
  RegionGroup.chugoku: const RegionDetail(
    name: 'Chugoku',
    nameKr: '주고쿠',
    description:
        '역사와 자연, 섬 호핑이 매력적인 서부 지역입니다. 바다 위에 떠 있는 듯한 붉은 도리이와 아름다운 일본식 정원, 그리고 역사적인 평화 기념비가 위치한 곳입니다.',
    majorCities: ['히로시마 (Hiroshima)', '오카야마 (Okayama)'],
    topSpots: [
      '미야지마 — 이츠쿠시마 (Miyajima)',
      '고라쿠엔 정원 (Korakuen)',
      '다이센산 (Mt. Daisen)',
    ],
    cultureAndFood: ['시모노세키 복어', '비젠 도자기', 'Iwami Kagura 전통 춤'],
    images: [
      'https://res.cloudinary.com/palette-michi/image/upload/v1773564440/chugoku_1_r7h7nm.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773564442/chugoku_2_thohgz.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773564453/chugoku_3_pqx1p1.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773564447/chugoku_4_bc8cmn.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773564444/chugoku_5_nxhb0o.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773564450/chugoku_6_ydozsc.jpg',
    ],
  ),
  RegionGroup.shikoku: const RegionDetail(
    name: 'Shikoku',
    nameKr: '시코쿠',
    description:
        '고전 문학과 88개 사찰 순례길, 그리고 우동의 본고장으로 유명한 섬입니다. 소용돌이치는 바다와 일본에서 가장 오래된 온천 등 독특한 자연 경관을 자랑합니다.',
    majorCities: ['마쓰야마 (Matsuyama)', '다카마쓰 (Takamatsu)'],
    topSpots: [
      '88사 순례길 (Shikoku Pilgrimage)',
      '나루토 소용돌이 (Naruto)',
      '도고 온천 (Dogo Onsen)',
    ],
    cultureAndFood: ['사누키 우동', '여름 아와오도리 축제', '나츠메 소세키 소설 배경'],
    images: [
      'https://res.cloudinary.com/palette-michi/image/upload/v1773565827/shikoku_1_kd7ner.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773565835/shikoku_2_iq2wfp.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773565831/shikoku_3_vydwqm.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773565837/shikoku_4_v3s72r.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773565828/shikoku_5_s4hgdr.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773565825/shikoku_6_attn0b.jpg',
    ],
  ),
  RegionGroup.kyushu: const RegionDetail(
    name: 'Kyushu',
    nameKr: '큐슈',
    description:
        '불과 물의 땅으로 불리며 역동적인 화산 활동과 풍부한 온천이 가득합니다. 현대적인 도시 문화와 함께 이국적인 역사적 배경을 가진 매력적인 여행지입니다.',
    majorCities: ['후쿠오카 (Fukuoka)', '가고시마 (Kagoshima)'],
    topSpots: ['벳부 온천 (Beppu)', '아소 화산 (Aso)', '나가사키 (Nagasaki)'],
    cultureAndFood: ['하카타 돈코츠 라멘', '가고시마 흑돼지', '도자기 마을'],
    images: [
      'https://res.cloudinary.com/palette-michi/image/upload/v1773567989/kyushu_1_lfmbqm.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773567994/kyushu_2_gg4i4e.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773567985/kyushu_3_u6o83a.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773567991/kyushu_4_cjicpn.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773567984/kyushu_5_uy99py.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773568203/kyushu_6_bynzji.jpg',
    ],
  ),
  RegionGroup.okinawa: const RegionDetail(
    name: 'Okinawa',
    nameKr: '오키나와',
    description:
        '아열대 기후와 독자적인 류큐 왕국 문화를 가진 에메랄드빛 섬입니다. 일본 최고의 스노클링 및 다이빙 포인트와 함께 고유의 장수 식단 문화가 유명합니다.',
    majorCities: ['나하 (Naha)'],
    topSpots: ['슈리 성 (Shuri Castle)', '추라우미 수족관 (Churaumi)', '맹그로브 숲'],
    cultureAndFood: ['고야 참푸루', '오키나와 소바', '고래 관찰', '가라테의 발상지'],
    images: [
      'https://res.cloudinary.com/palette-michi/image/upload/v1773568814/okinawa_1_iupe5f.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773568818/okinawa_2_mcg2ke.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773568827/okinawa_3_gg5lrz.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773568813/okinawa_4_mf5ndx.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773568822/okinawa_5_oe79xi.jpg',
      'https://res.cloudinary.com/palette-michi/image/upload/v1773568824/okinawa_6_mxaqvl.jpg',
    ],
  ),
};
