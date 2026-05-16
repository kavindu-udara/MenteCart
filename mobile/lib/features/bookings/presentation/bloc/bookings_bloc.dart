import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bookings/data/models/booking_model.dart';
import '../../../bookings/data/repositories/bookings_repository.dart';
import '../../../../core/errors/exceptions.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  final BookingsRepository repository;

  BookingsBloc({required this.repository}) : super(const BookingsState.initial()) {
    on<BookingsRequested>(_onRequested);
    on<BookingCancelRequested>(_onCancelRequested);
  }

  Future<void> _onRequested(
    BookingsRequested event,
    Emitter<BookingsState> emit,
  ) async {
    emit(const BookingsState.loading());

    try {
      final bookings = await repository.getBookings();
      final summaries = bookings.map(_toSummary).toList();

      if (summaries.isEmpty) {
        emit(const BookingsState.empty(message: 'No bookings found.'));
        return;
      }

      emit(BookingsState.loaded(bookings: summaries));
    } on AppException catch (e) {
      emit(BookingsState.error(message: e.message));
    } catch (e) {
      emit(BookingsState.error(message: e.toString()));
    }
  }

  Future<void> _onCancelRequested(
    BookingCancelRequested event,
    Emitter<BookingsState> emit,
  ) async {
    emit(const BookingsState.loading());

    try {
      await repository.cancelBooking(event.bookingId);
      final bookings = await repository.getBookings();
      final summaries = bookings.map(_toSummary).toList();

      if (summaries.isEmpty) {
        emit(const BookingsState.empty(message: 'No bookings found.'));
        return;
      }

      emit(BookingsState.loaded(bookings: summaries));
    } on AppException catch (e) {
      emit(BookingsState.error(message: e.message));
    } catch (e) {
      emit(BookingsState.error(message: e.toString()));
    }
  }

  BookingSummary _toSummary(BookingModel booking) {
    final firstItem = booking.items.isNotEmpty ? booking.items.first : null;
    final dateLabel = firstItem == null
        ? 'No date'
        : DateFormat('MMM dd, yyyy').format(firstItem.selectedDate.toLocal());
    final timeLabel = firstItem == null
        ? 'No time'
        : '${firstItem.timeSlotStart} - ${firstItem.timeSlotEnd}';

    return BookingSummary(
      id: booking.id,
      reference: _shortReference(booking.id),
      title: 'Booking ${_shortReference(booking.id)}',
      dateLabel: dateLabel,
      timeLabel: timeLabel,
      status: _parseStatus(booking.status),
      paymentMethodLabel: _paymentMethodLabel(booking.paymentMethod),
      paymentStatusLabel: _paymentStatusLabel(booking.paymentStatus),
      totalAmount: booking.totalAmount,
      itemCount: booking.items.length,
    );
  }

  BookingStatus _parseStatus(String value) {
    return switch (value) {
      'pending' => BookingStatus.pending,
      'confirmed' => BookingStatus.confirmed,
      'completed' => BookingStatus.completed,
      'cancelled' => BookingStatus.cancelled,
      'failed' => BookingStatus.failed,
      _ => BookingStatus.failed,
    };
  }

  String _shortReference(String value) {
    if (value.length <= 6) {
      return value.toUpperCase();
    }

    return value.substring(value.length - 6).toUpperCase();
  }

  String _paymentMethodLabel(String value) {
    return switch (value) {
      'payhere' => 'PayHere',
      'pay_on_arrival' => 'Pay on arrival',
      'cash' => 'Cash',
      _ => value,
    };
  }

  String _paymentStatusLabel(String value) {
    return switch (value) {
      'paid' => 'Paid',
      'unpaid' => 'Unpaid',
      'pending' => 'Pending',
      'failed' => 'Failed',
      _ => value,
    };
  }
}