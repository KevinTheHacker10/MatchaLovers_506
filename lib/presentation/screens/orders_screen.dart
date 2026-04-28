import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:matcha_lovers_506/core/constants.dart';
import 'package:matcha_lovers_506/domain/entities/order_entity.dart';
import 'package:matcha_lovers_506/presentation/providers/order_provider.dart';
import 'package:matcha_lovers_506/theme.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);
    
    return Scaffold(
      backgroundColor: AppColors.softGreen,
      appBar: AppBar(
        title: const Text('Historial de Pedidos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay pedidos registrados',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppSpacing.paddingMd,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(order: order);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderEntity order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: AppConstants.currency, decimalDigits: 0);
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: AppSpacing.verticalSm,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        tilePadding: AppSpacing.paddingMd,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.oliveGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.receipt_long,
            color: AppColors.oliveGreen,
          ),
        ),
        title: Text(
          'Pedido #${order.id.substring(0, 8)}',
          style: context.textStyles.titleMedium?.bold,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dateFormatter.format(order.createdAt),
              style: context.textStyles.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Por: ${order.userName}',
              style: context.textStyles.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatter.format(order.total),
              style: context.textStyles.titleMedium?.bold.withColor(AppColors.oliveGreen),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.status.displayName,
                style: context.textStyles.labelSmall?.copyWith(
                  color: _getStatusColor(order.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        children: [
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: AppColors.softGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Productos',
                  style: context.textStyles.titleSmall?.bold,
                ),
                const SizedBox(height: 12),
                ...order.items.map((item) {
                  return Padding(
                    padding: AppSpacing.verticalXs,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.oliveGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${item.quantity}',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: context.textStyles.bodyMedium,
                          ),
                        ),
                        Text(
                          formatter.format(item.total),
                          style: context.textStyles.bodyMedium?.semiBold,
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Método de pago:', style: context.textStyles.bodyMedium),
                    Text(
                      order.paymentMethod.displayName,
                      style: context.textStyles.bodyMedium?.semiBold,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return AppColors.oliveGreen;
      case OrderStatus.pending:
        return AppColors.amber;
      case OrderStatus.cancelled:
        return AppColors.coral;
    }
  }
}
