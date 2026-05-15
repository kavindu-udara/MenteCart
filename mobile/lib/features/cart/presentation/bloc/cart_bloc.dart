import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../../../../core/errors/exceptions.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc({required CartRepository cartRepository})
      : _cartRepository = cartRepository,
        super(const CartState.initial()) {
    on<CartRequested>(_onRequested);
  }

  Future<void> _onRequested(
    CartRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartState.loading());

    try {
      final cart = await _cartRepository.getCart();

      if (cart.items.isEmpty) {
        emit(const CartState.empty(message: 'Your cart is empty right now.'));
        return;
      }

      emit(CartState.loaded(cart: cart));
    } on AppException catch (e) {
      emit(CartState.error(message: e.message));
    } catch (e) {
      emit(CartState.error(message: 'Failed to load cart'));
    }
  }
}