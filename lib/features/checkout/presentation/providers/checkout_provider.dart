import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/isar_collections/order_collection.dart';
import '../../../../shared/providers/isar_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../orders/data/repositories/order_repository_impl.dart';
import '../../../orders/presentation/providers/order_provider.dart';

// ── Payment Method ────────────────────────────────────────────────────────────

enum PaymentMethod { cash, gcash, other }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.gcash:
        return 'GCash';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.gcash:
        return 'gcash';
      case PaymentMethod.other:
        return 'other';
    }
  }
}

// ── State ─────────────────────────────────────────────────────────────────────

class CheckoutState {
  final PaymentMethod? selectedMethod;
  final String amountDisplay;
  final bool isProcessing;
  final String? errorMessage;
  final OrderCollection? completedOrder;

  const CheckoutState({
    this.selectedMethod,
    this.amountDisplay = '',
    this.isProcessing = false,
    this.errorMessage,
    this.completedOrder,
  });

  double get amountEntered => double.tryParse(amountDisplay) ?? 0.0;

  bool isPaymentValid(double orderTotal) {
    if (selectedMethod == null) return false;
    if (selectedMethod == PaymentMethod.cash) {
      return amountEntered >= orderTotal;
    }
    return true;
  }

  CheckoutState copyWith({
    PaymentMethod? selectedMethod,
    String? amountDisplay,
    bool? isProcessing,
    String? errorMessage,
    OrderCollection? completedOrder,
    bool clearError = false,
    bool clearMethod = false,
  }) {
    return CheckoutState(
      selectedMethod:
          clearMethod ? null : selectedMethod ?? this.selectedMethod,
      amountDisplay: amountDisplay ?? this.amountDisplay,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      completedOrder: completedOrder ?? this.completedOrder,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  /// Resets to initial state — call when entering the checkout screen.
  void reset() => state = const CheckoutState();

  void selectMethod(PaymentMethod method) {
    state = state.copyWith(
      selectedMethod: method,
      amountDisplay: '',
      clearError: true,
    );
  }

  void appendDigit(String digit) {
    final current = state.amountDisplay;
    if (digit == '.' && current.contains('.')) return;
    if (current.contains('.')) {
      final decimals = current.split('.')[1];
      if (decimals.length >= 2) return;
    }
    // Prevent leading zeros like "00" or "01" (allow "0.")
    if (current == '0' && digit != '.') return;
    state = state.copyWith(amountDisplay: current + digit);
  }

  void deleteDigit() {
    final current = state.amountDisplay;
    if (current.isEmpty) return;
    state = state.copyWith(
      amountDisplay: current.substring(0, current.length - 1),
    );
  }

  /// Saves the order to Isar, enqueues it for sync, deducts inventory,
  /// and clears the active cart. Returns the saved order on success.
  Future<OrderCollection?> processPayment() async {
    final orderState = ref.read(orderProvider);
    final authState = ref.read(authProvider);
    final isar = ref.read(isarProvider);
    final cashier = authState.selectedCashier;

    if (cashier == null || state.selectedMethod == null) return null;
    if (!state.isPaymentValid(orderState.total)) return null;

    state = state.copyWith(isProcessing: true, clearError: true);

    try {
      final repo = OrderRepositoryImpl(isar);

      final amountTendered = state.selectedMethod == PaymentMethod.cash
          ? state.amountEntered
          : orderState.total;

      final savedOrder = await repo.saveOrder(
        orderState: orderState,
        cashierId: cashier.syncId,
        cashierName: cashier.name,
        amountTendered: amountTendered,
        paymentMethod: state.selectedMethod!.value,
      );

      ref.read(orderProvider.notifier).clearCart();

      state = state.copyWith(
        isProcessing: false,
        completedOrder: savedOrder,
      );

      return savedOrder;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Payment failed. Please try again.',
      );
      return null;
    }
  }
}

final checkoutProvider = NotifierProvider<CheckoutNotifier, CheckoutState>(
  CheckoutNotifier.new,
);
