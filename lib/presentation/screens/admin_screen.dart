import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:matcha_lovers_506/core/constants.dart';
import 'package:matcha_lovers_506/presentation/providers/order_provider.dart';
import 'package:matcha_lovers_506/theme.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesStatsAsync = ref.watch(salesStatsProvider);
    final todayOrders = ref.watch(todayOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.softGreen,
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            salesStatsAsync.when(
              data: (stats) {
                final formatter = NumberFormat.currency(
                  symbol: AppConstants.currency,
                  decimalDigits: 0,
                );

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Ventas Totales',
                            value: formatter.format(stats['totalSales']),
                            icon: Icons.attach_money,
                            color: AppColors.oliveGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Pedidos Totales',
                            value: '${stats['totalOrders']}',
                            icon: Icons.receipt_long,
                            color: AppColors.peach,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StatCard(
                      title: 'Promedio por Pedido',
                      value: formatter.format(stats['averageOrderValue']),
                      icon: Icons.trending_up,
                      color: AppColors.amber,
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: AppSpacing.paddingXl,
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Text('Error cargando estadísticas: $error'),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.oliveGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.today,
                            color: AppColors.oliveGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Pedidos de Hoy',
                          style: context.textStyles.titleLarge?.bold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (todayOrders.isEmpty)
                      Center(
                        child: Padding(
                          padding: AppSpacing.paddingXl,
                          child: Text(
                            'No hay pedidos hoy',
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: todayOrders.take(5).map((order) {
                          final formatter = NumberFormat.currency(
                            symbol: AppConstants.currency,
                            decimalDigits: 0,
                          );
                          final timeFormatter = DateFormat('HH:mm');

                          return Container(
                            margin: AppSpacing.verticalSm,
                            padding: AppSpacing.paddingMd,
                            decoration: BoxDecoration(
                              color: AppColors.softGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.oliveGreen,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      timeFormatter.format(order.createdAt),
                                      style: context.textStyles.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.userName,
                                        style: context.textStyles.bodyMedium?.semiBold,
                                      ),
                                      Text(
                                        '${order.items.length} productos',
                                        style: context.textStyles.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatter.format(order.total),
                                  style: context.textStyles.titleMedium?.bold.withColor(
                                    AppColors.oliveGreen,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.peach.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: AppColors.peach,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Gestión',
                          style: context.textStyles.titleLarge?.bold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AdminActionButton(
                      icon: Icons.inventory_2,
                      label: 'Gestionar Productos',
                      color: AppColors.oliveGreen,
                       onTap: () => context.push('/admin/products'),
                    ),
                    const SizedBox(height: 8),
                    AdminActionButton(
                      icon: Icons.people,
                      label: 'Gestionar Usuarios',
                      color: AppColors.peach,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Función próximamente')),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    AdminActionButton(
                      icon: Icons.assessment,
                      label: 'Reportes Detallados',
                      color: AppColors.amber,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Función próximamente')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: context.textStyles.headlineSmall?.bold.withColor(color),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const AdminActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: context.textStyles.titleMedium?.semiBold,
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
