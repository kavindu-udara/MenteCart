import 'package:flutter/material.dart';

import '../../features/bookings/presentation/bloc/bookings_bloc.dart';

class StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final badge = switch (status) {
      BookingStatus.pending => _BadgeData(
          label: 'Pending',
          color: Colors.amber,
          icon: Icons.schedule,
        ),
      BookingStatus.confirmed => _BadgeData(
          label: 'Confirmed',
          color: Colors.green,
          icon: Icons.verified,
        ),
      BookingStatus.completed => _BadgeData(
          label: 'Completed',
          color: Colors.blue,
          icon: Icons.check_circle,
        ),
      BookingStatus.cancelled => _BadgeData(
          label: 'Cancelled',
          color: Colors.red,
          icon: Icons.cancel,
        ),
      BookingStatus.failed => _BadgeData(
          label: 'Failed',
          color: Colors.deepOrange,
          icon: Icons.error,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: badge.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(badge.icon, size: 16, color: badge.color),
            const SizedBox(width: 6),
            Text(
              badge.label,
              style: TextStyle(
                color: badge.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeData {
  final String label;
  final Color color;
  final IconData icon;

  const _BadgeData({
    required this.label,
    required this.color,
    required this.icon,
  });
}