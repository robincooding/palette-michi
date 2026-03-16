class City {
  final String name;
  final String description;
  final String imageUrl; // 향후 API나 assets에서 가져오기

  const City({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

const List<City> initialCities = [
  City(
    name: "도쿄",
    description: "과거와 미래가 공존하는 빛의 도시",
    imageUrl: "assets/cities/tokyo.jpg",
  ),
  City(
    name: "오사카",
    description: "입안 가득 행복이 터지는 미식의 천국",
    imageUrl: "assets/cities/osaka.jpg",
  ),
  City(
    name: "교토",
    description: "천 년의 시간이 머무는 정적인 거리",
    imageUrl: "assets/cities/kyoto.jpg",
  ),
  City(
    name: "시즈오카",
    description: "후지산을 품은 초록빛 차 향기",
    imageUrl: "assets/cities/shizuoka.jpg",
  ),
  City(
    name: "나고야",
    description: "역사와 현대가 조화로운 중심지",
    imageUrl: "assets/cities/nagoya.jpg",
  ),
  City(
    name: "삿포로",
    description: "하얀 설원 위로 피어나는 낭만",
    imageUrl: "assets/cities/sapporo.jpg",
  ),
  City(
    name: "후쿠오카",
    description: "따뜻한 정이 느껴지는 강변의 밤",
    imageUrl: "assets/cities/fukuoka.jpg",
  ),
  City(
    name: "가고시마",
    description: "웅장한 화산과 바다가 만나는 곳",
    imageUrl: "assets/cities/kagoshima.jpg",
  ),
  City(
    name: "오키나와",
    description: "에메랄드빛 바다가 전하는 위로",
    imageUrl: "assets/cities/okinawa.jpg",
  ),
];
