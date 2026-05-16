import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/status_badge.dart';
import '../bloc/bookings_bloc.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  Future<void> _refresh(BuildContext context) async {
    context.read<BookingsBloc>().add(const BookingsRequested());
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<void> _confirmCancel(BuildContext context, BookingSummary booking) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      context.read<BookingsBloc>().add(BookingCancelRequested(bookingId: booking.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingsBloc, BookingsState>(
      listener: (context, state) {
        if (state is BookingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
          BookingsInitial() || BookingsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          BookingsError(:final message) => _StateMessage(
              icon: Icons.error_outline,
              title: 'Bookings unavailable',
              message: message,
            ),
          BookingsEmpty(:final message) => _StateMessage(
              icon: Icons.event_busy_outlined,
              title: 'No bookings yet',
              message: message,
            ),
          BookingsLoaded(:final bookings) => RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = bookings[index];

                  return Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Reference: ${booking.reference}'),
                                  ],
                                ),
                              ),
                              StatusBadge(status: booking.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('${booking.dateLabel} • ${booking.timeLabel}'),
                          const SizedBox(height: 4),
                          Text('${booking.paymentMethodLabel} • ${booking.paymentStatusLabel} • ${booking.itemCount} item(s)'),
                          const SizedBox(height: 4),
                          Text('Total: \$${booking.totalAmount.toStringAsFixed(2)}'),
                          if (booking.canCancel) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: () => _confirmCancel(context, booking),
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel booking'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        };
      },
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}