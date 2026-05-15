import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  BookingsBloc() : super(const BookingsState.initial()) {
    on<BookingsRequested>(_onRequested);
  }

  Future<void> _onRequested(
    BookingsRequested event,
    Emitter<BookingsState> emit,
  ) async {
    emit(const BookingsState.loading());

    await Future<void>.delayed(const Duration(milliseconds: 250));

    const bookings = [
      BookingSummary(
        reference: 'BK-1201',
        title: 'Salon appointment',
        dateLabel: 'Today',
        timeLabel: '2:30 PM',
        status: BookingStatus.confirmed,
      ),
      BookingSummary(
        reference: 'BK-1188',
        title: 'Grocery delivery slot',
        dateLabel: 'Tomorrow',
        timeLabel: '10:00 AM',
        status: BookingStatus.pending,
      ),
      BookingSummary(
        reference: 'BK-1165',
        title: 'Home service follow-up',
        dateLabel: 'Mon, 20 May',
        timeLabel: '4:00 PM',
        status: BookingStatus.completed,
      ),
    ];

    if (bookings.isEmpty) {
      emit(const BookingsState.empty(message: 'No bookings found.'));
      return;
    }

    emit(const BookingsState.loaded(bookings: bookings));
  }
}