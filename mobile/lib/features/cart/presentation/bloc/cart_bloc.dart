import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState.initial()) {
    on<CartRequested>(_onRequested);
  }

  Future<void> _onRequested(
    CartRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartState.loading());

    await Future<void>.delayed(const Duration(milliseconds: 250));

    const items = <CartItemSummary>[
      CartItemSummary(
        name: 'Organic Apples',
        quantity: 2,
        price: 4.50,
      ),
      CartItemSummary(
        name: 'Wholegrain Bread',
        quantity: 1,
        price: 3.20,
      ),
      CartItemSummary(
        name: 'Green Tea Pack',
        quantity: 3,
        price: 5.80,
      ),
    ];

    if (items.isEmpty) {
      emit(const CartState.empty(message: 'Your cart is empty right now.'));
      return;
    }

    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    emit(CartState.loaded(items: items, total: total));
  }
}