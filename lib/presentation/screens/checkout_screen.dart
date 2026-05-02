import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:matcha_lovers_506/core/constants.dart';
import 'package:matcha_lovers_506/presentation/providers/auth_provider.dart';
import 'package:matcha_lovers_506/presentation/providers/cart_provider.dart';
import 'package:matcha_lovers_506/presentation/providers/order_provider.dart';
import 'package:matcha_lovers_506/theme.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isProcessing = false;
  // Flag para evitar que el guard de carrito vacío navegue mientras procesamos
  bool _paymentDone = false;

  Future<void> _processPayment() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    setState(() => _isProcessing = true);

    final orderItems = cart.map((item) => item.toOrderItem()).toList();

    final order = await ref.read(orderProvider.notifier).createOrder(
      userId: currentUser.id,
      userName: currentUser.fullName,
      items: orderItems,
      paymentMethod: _selectedPaymentMethod,
    );

    if (!mounted) return;

    if (order != null) {
      // Marcamos como completado ANTES de limpiar el carrito
      // para que el guard de cart.isEmpty no navegue solo
      setState(() { _paymentDone = true; });

      ref.read(cartProvider.notifier).clear();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessDialog(
          orderId: order.id,
          total: order.total,
          onContinue: () => context.go('/pos'), // ← navega directo al POS
        ),
      );
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar el pago. Intenta de nuevo.'),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartSummary = ref.watch(cartSummaryProvider);
    final formatter = NumberFormat.currency(
        symbol: AppConstants.currency, decimalDigits: 0);

    // Solo redirige si el carrito está vacío Y el pago NO se completó
    // (evita que el guard interfiera después de limpiar el carrito)
    if (cart.isEmpty && !_paymentDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.softGreen,
      appBar: AppBar(
        title: const Text('Confirmar Pago'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: AppSpacing.paddingXl,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: AppSpacing.paddingXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Encabezado ────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppColors.oliveGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Resumen de Pedido',
                      style: context.textStyles.headlineSmall?.bold,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Items del carrito ─────────────────────────────────
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: AppColors.softGreen.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: cart.map((item) {
                      return Padding(
                        padding: AppSpacing.verticalSm,
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.oliveGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${item.quantity}x',
                                  style: context.textStyles.bodyMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.product.name,
                                style: context.textStyles.bodyLarge,
                              ),
                            ),
                            Text(
                              formatter.format(item.total),
                              style: context.textStyles.bodyLarge?.semiBold,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // ── Totales ───────────────────────────────────────────
                _summaryRow('Subtotal',
                    formatter.format(cartSummary['subtotal'])),
                const SizedBox(height: 8),
                _summaryRow('Impuesto (13%)',
                    formatter.format(cartSummary['tax'])),
                const SizedBox(height: 16),
                _summaryRow(
                  'Total',
                  formatter.format(cartSummary['total']),
                  isTotal: true,
                ),
                const SizedBox(height: 32),

                // ── Método de pago ────────────────────────────────────
                Text(
                  'Método de Pago',
                  style: context.textStyles.titleLarge?.bold,
                ),
                const SizedBox(height: 16),
                PaymentMethodOption(
                  method: PaymentMethod.cash,
                  icon: Icons.payments,
                  isSelected:
                      _selectedPaymentMethod == PaymentMethod.cash,
                  onTap: () => setState(
                      () => _selectedPaymentMethod = PaymentMethod.cash),
                ),
                const SizedBox(height: 12),
                PaymentMethodOption(
                  method: PaymentMethod.card,
                  icon: Icons.credit_card,
                  isSelected:
                      _selectedPaymentMethod == PaymentMethod.card,
                  onTap: () => setState(
                      () => _selectedPaymentMethod = PaymentMethod.card),
                ),
                const SizedBox(height: 32),

                // ── Botón confirmar ───────────────────────────────────
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    child: _isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Confirmar Pago',
                                style: context.textStyles.titleMedium
                                    ?.copyWith(
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
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textStyles.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 22 : null,
          ),
        ),
        Text(
          value,
          style: context.textStyles.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            fontSize: isTotal ? 22 : null,
            color: isTotal ? AppColors.oliveGreen : null,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// PAYMENT METHOD OPTION
// =============================================================================

class PaymentMethodOption extends StatelessWidget {
  final PaymentMethod method;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodOption({
    super.key,
    required this.method,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.oliveGreen.withValues(alpha: 0.1)
          : Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected ? AppColors.oliveGreen : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.oliveGreen
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                method.displayName,
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.oliveGreen : null,
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle,
                    color: AppColors.oliveGreen, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SUCCESS DIALOG
// =============================================================================

class SuccessDialog extends StatelessWidget {
  final String orderId;
  final double total;
  final VoidCallback onContinue; // ← navega directo al POS

  const SuccessDialog({
    super.key,
    required this.orderId,
    required this.total,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
        symbol: AppConstants.currency, decimalDigits: 0);

    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: AppSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.oliveGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.oliveGreen,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Pago Exitoso!',
              style: context.textStyles.headlineSmall?.bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Total pagado: ${formatter.format(total)}',
              style: context.textStyles.titleLarge?.copyWith(
                color: AppColors.oliveGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pedido #${orderId.substring(0, 8).toUpperCase()}',
              style: context.textStyles.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onContinue, // ← context.go('/pos')
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
