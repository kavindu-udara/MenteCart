part of 'bookings_bloc.dart';

sealed class BookingsEvent {
  const BookingsEvent();
}

final class BookingsRequested extends BookingsEvent {
  const BookingsRequested();
}

final class BookingCancelRequested extends BookingsEvent {
  final String bookingId;

  const BookingCancelRequested({required this.bookingId});
}