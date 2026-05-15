part of 'bookings_bloc.dart';

enum BookingStatus { pending, confirmed, completed, cancelled }

sealed class BookingsState {
  const BookingsState();

  const factory BookingsState.initial() = BookingsInitial;
  const factory BookingsState.loading() = BookingsLoading;
  const factory BookingsState.loaded({
    required List<BookingSummary> bookings,
  }) = BookingsLoaded;
  const factory BookingsState.empty({required String message}) = BookingsEmpty;
  const factory BookingsState.error({required String message}) = BookingsError;
}

final class BookingsInitial extends BookingsState {
  const BookingsInitial();
}

final class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

final class BookingsLoaded extends BookingsState {
  final List<BookingSummary> bookings;

  const BookingsLoaded({required this.bookings});
}

final class BookingsEmpty extends BookingsState {
  final String message;

  const BookingsEmpty({required this.message});
}

final class BookingsError extends BookingsState {
  final String message;

  const BookingsError({required this.message});
}

final class BookingSummary {
  final String reference;
  final String title;
  final String dateLabel;
  final String timeLabel;
  final BookingStatus status;

  const BookingSummary({
    required this.reference,
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
  });
}