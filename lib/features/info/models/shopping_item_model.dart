/// 쇼핑 필수템 아이템 모델
class ShoppingItem {
  final String id;
  final String title;
  final String category; // ShoppingCategory enum의 label
  final ShoppingCategory categoryType;
  final String description;
  final List<String> tags;
  final String? imageUrl;

  /// null이면 전국 공통 아이템, 값이 있으면 해당 도시 전용
  final String? city;

  const ShoppingItem({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryType,
    required this.description,
    required this.tags,
    this.imageUrl,
    this.city,
  });
}

enum ShoppingCategory {
  all('전체'),
  convenienceStore('편의점'),
  drugstore('드럭스토어·돈키'),
  supermarket('슈퍼·마트'),
  shoppingMall('백화점·쇼핑몰'),
  localSpecialty('지역특산품');

  const ShoppingCategory(this.label);
  final String label;
}
