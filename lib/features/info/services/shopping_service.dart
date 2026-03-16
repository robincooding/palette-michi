import 'package:palette_michi/features/info/data/shopping_items.dart';
import 'package:palette_michi/features/info/models/shopping_item_model.dart';

class ShoppingService {
  const ShoppingService();

  /// 도시에 맞는 전체 아이템 반환 (공통 + 도시 전용)
  List<ShoppingItem> getItemsForCity(String city) {
    return ShoppingItems.getItemsForCity(city);
  }

  /// 카테고리 필터 적용 후 반환
  List<ShoppingItem> getFilteredItems({
    required String city,
    required ShoppingCategory category,
  }) {
    return ShoppingItems.getFilteredItems(city: city, category: category);
  }
}
