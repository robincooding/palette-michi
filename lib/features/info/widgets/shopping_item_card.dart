import 'package:flutter/material.dart';
import 'package:palette_michi/core/theme/app_colors.dart';
import 'package:palette_michi/features/info/models/shopping_item_model.dart';

class ShoppingItemCard extends StatelessWidget {
  const ShoppingItemCard({super.key, required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 / 플레이스홀더
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _buildPlaceholder(item.categoryType),
                  )
                : _buildPlaceholder(item.categoryType),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryRow(),
                const SizedBox(height: 4),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildTags(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Row(
      children: [
        Text(
          item.category,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.primaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (item.city != null) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${item.city} 한정',
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: item.tags
          .take(2)
          .map(
            (tag) => Text(
              tag,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          )
          .toList(),
    );
  }

  static Widget _buildPlaceholder(ShoppingCategory category) {
    final iconData = switch (category) {
      ShoppingCategory.convenienceStore => Icons.store_outlined,
      ShoppingCategory.drugstore => Icons.storefront_outlined,
      ShoppingCategory.supermarket => Icons.shopping_basket_outlined,
      ShoppingCategory.shoppingMall => Icons.shopping_bag_outlined,
      ShoppingCategory.localSpecialty => Icons.card_giftcard_outlined,
      ShoppingCategory.all => Icons.shopping_cart_outlined,
    };
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey[100],
      child: Icon(iconData, color: Colors.grey[400], size: 32),
    );
  }
}
