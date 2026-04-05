import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:matcha_lovers_506/core/constants.dart';
import 'package:matcha_lovers_506/presentation/providers/cart_provider.dart';
import 'package:matcha_lovers_506/theme.dart';

class CartPanel extends ConsumerWidget {
  final List<CartItem> cartItems;
  final VoidCallback onCheckout;

  const CartPanel({
    super.key,
    required this.cartItems,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartSummary = ref.watch(cartSummaryProvider);
    final formatter = NumberFormat.currency(symbol: AppConstants.currency, decimalDigits: 0);

    return Column(
      children: [
        Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: AppColors.oliveGreen,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Carrito',
                style: context.textStyles.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (cartItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cartSummary['itemCount']}',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: AppColors.oliveGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Carrito vacío',
                        style: context.textStyles.titleMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: AppSpacing.paddingMd,
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return CartItemCard(
                      item: item,
                      onIncrement: () => ref.read(cartProvider.notifier).incrementQuantity(item.product.id),
                      onDecrement: () => ref.read(cartProvider.notifier).decrementQuantity(item.product.id),
                      onRemove: () => ref.read(cartProvider.notifier).removeProduct(item.product.id),
                    );
                  },
                ),
        ),
        if (cartItems.isNotEmpty)
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', formatter.format(cartSummary['subtotal']), context),
                const SizedBox(height: 8),
                _buildSummaryRow('Impuesto (13%)', formatter.format(cartSummary['tax']), context),
                const Divider(height: 24),
                _buildSummaryRow(
                  'Total',
                  formatter.format(cartSummary['total']),
                  context,
                  isTotal: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.oliveGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payment, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Procesar Pago',
                          style: context.textStyles.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, BuildContext context, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textStyles.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 20 : null,
          ),
        ),
        Text(
          value,
          style: context.textStyles.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 20 : null,
            color: isTotal ? AppColors.oliveGreen : null,
          ),
        ),
      ],
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: AppConstants.currency, decimalDigits: 0);

    return Card(
      margin: AppSpacing.verticalSm,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.product.name,
                    style: context.textStyles.bodyLarge?.semiBold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.coral,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildQuantityButton(Icons.remove, onDecrement),
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: context.textStyles.titleMedium?.bold,
                      ),
                    ),
                    _buildQuantityButton(Icons.add, onIncrement),
                  ],
                ),
                Text(
                  formatter.format(item.total),
                  style: context.textStyles.titleMedium?.bold.withColor(AppColors.oliveGreen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.oliveGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.white),
        onPressed: onPressed,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      ),
    );
  }
}
