import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matcha_lovers_506/core/constants.dart';
import 'package:matcha_lovers_506/domain/entities/product_entity.dart';
import 'package:matcha_lovers_506/theme.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  String _getCategoryColor() {
    switch (product.category) {
      case ProductCategory.matcha:
        return '🍵';
      case ProductCategory.smoothies:
        return '🥤';
      case ProductCategory.healthyJuices:
        return '🥗';
      case ProductCategory.coldCoffee:
        return '☕';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: AppConstants.currency, decimalDigits: 0);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.oliveGreen.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.softGreen.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getCategoryColor(),
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: AppSpacing.paddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          product.name,
                          style: context.textStyles.titleMedium?.bold,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.oliveGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          formatter.format(product.price),
                          style: context.textStyles.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
