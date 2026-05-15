import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/status_badge.dart';
import '../bloc/bookings_bloc.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingsBloc, BookingsState>(
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
          BookingsLoaded(:final bookings) => ListView.separated(
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
                          children: [
                            Expanded(
                              child: Text(
                                booking.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            StatusBadge(status: booking.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Reference: ${booking.reference}'),
                        const SizedBox(height: 4),
                        Text('${booking.dateLabel} • ${booking.timeLabel}'),
                      ],
                    ),
                  ),
                );
              },
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