import 'package:flutter/material.dart';
import '../models/booking.dart';

class StatusChip extends StatelessWidget {
  final BookingStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case BookingStatus.waiting:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'Menunggu';
        break;
      case BookingStatus.confirmed:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'Dikonfirmasi';
        break;
      case BookingStatus.done:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Selesai';
        break;
      case BookingStatus.cancelled:
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
