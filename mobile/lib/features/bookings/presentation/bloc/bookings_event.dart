part of 'bookings_bloc.dart';

sealed class BookingsEvent {
  const BookingsEvent();
}

final class BookingsRequested extends BookingsEvent {
  const BookingsRequested();
}