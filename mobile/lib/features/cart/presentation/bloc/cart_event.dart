part of 'cart_bloc.dart';

sealed class CartEvent {
  const CartEvent();
}

final class CartRequested extends CartEvent {
  const CartRequested();
}