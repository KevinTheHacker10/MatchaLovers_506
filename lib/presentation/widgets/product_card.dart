import 'package:flutter/material.dart';
import 'package:matcha_lovers_506/domain/entities/product_entity.dart';
import 'package:matcha_lovers_506/theme.dart';
import 'package:intl/intl.dart';
import 'package:matcha_lovers_506/core/constants.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  // Color de fondo por categoría
  Color get _bgColor {
    switch (product.category) {
      case ProductCategory.matcha:
        return const Color(0xFFDFF2D0);
      case ProductCategory.smoothies:
        return const Color(0xFFFFE4F0);
      case ProductCategory.healthyJuices:
        return const Color(0xFFFFF3CC);
      case ProductCategory.coldCoffee:
        return const Color(0xFFE8DDD0);
    }
  }

  Color get _accentColor {
    switch (product.category) {
      case ProductCategory.matcha:
        return AppColors.oliveGreen;
      case ProductCategory.smoothies:
        return AppColors.peach;
      case ProductCategory.healthyJuices:
        return AppColors.amber;
      case ProductCategory.coldCoffee:
        return const Color(0xFF8B6D5A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: AppConstants.currency,
      decimalDigits: 0,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: product.isAvailable ? onTap : null,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Imagen (emoji) ─────────────────────────────────────────
                Expanded(
                  flex: 5,
                  child: Container(
                    color: _bgColor,
                    child: Center(
                      child: Text(
                        product.category.icon,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                ),

                // ── Info ───────────────────────────────────────────────────
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.name,
                          style: context.textStyles.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatter.format(product.price),
                              style: context.textStyles.titleMedium?.copyWith(
                                color: _accentColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: _accentColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Overlay no disponible ──────────────────────────────────────
            if (!product.isAvailable)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'No disponible',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Badge categoría ────────────────────────────────────────────
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.category.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _accentColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
