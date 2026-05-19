import 'package:equatable/equatable.dart';
import 'stylist.dart';
import 'service.dart';

enum BookingStatus { waiting, confirmed, done, cancelled }

class Booking extends Equatable {
  final String id;
  final String userId;
  final Stylist stylist;
  final List<Service> services;
  final DateTime date;
  final String time;
  final String notes;
  final BookingStatus status;
  final int totalPrice;

  const Booking({
    required this.id,
    required this.userId,
    required this.stylist,
    required this.services,
    required this.date,
    required this.time,
    required this.notes,
    required this.status,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [id, userId, stylist, services, date, time, notes, status, totalPrice];
}
