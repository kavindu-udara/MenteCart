part of 'cart_bloc.dart';

sealed class CartState {
  const CartState();

  const factory CartState.initial() = CartInitial;
  const factory CartState.loading() = CartLoading;
  const factory CartState.loaded({
    required List<CartItemSummary> items,
    required double total,
  }) = CartLoaded;
  const factory CartState.empty({required String message}) = CartEmpty;
  const factory CartState.error({required String message}) = CartError;
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartLoaded extends CartState {
  final List<CartItemSummary> items;
  final double total;

  const CartLoaded({required this.items, required this.total});
}

final class CartEmpty extends CartState {
  final String message;

  const CartEmpty({required this.message});
}

final class CartError extends CartState {
  final String message;

  const CartError({required this.message});
}

final class CartItemSummary {
  final String name;
  final int quantity;
  final double price;

  const CartItemSummary({
    required this.name,
    required this.quantity,
    required this.price,
  });
}