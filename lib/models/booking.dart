import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'stylist.dart';
import 'service.dart';

enum BookingStatus { menunggu, dikonfirmasi, selesai, dibatalkan }

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.menunggu:
        return 'Menunggu';
      case BookingStatus.dikonfirmasi:
        return 'Dikonfirmasi';
      case BookingStatus.selesai:
        return 'Selesai';
      case BookingStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.menunggu:
        return Colors.orange;
      case BookingStatus.dikonfirmasi:
        return Colors.blue;
      case BookingStatus.selesai:
        return Colors.green;
      case BookingStatus.dibatalkan:
        return Colors.red;
    }
  }
}

class Booking extends Equatable {
  final String id;
  final String userId;
  final Stylist stylist;
  final List<Service> services;
  final DateTime date;
  final String time;
  final String? notes;
  final BookingStatus status;
  final int totalPrice;

  const Booking({
    required this.id,
    required this.userId,
    required this.stylist,
    required this.services,
    required this.date,
    required this.time,
    this.notes,
    required this.status,
    required this.totalPrice,
  });

  Booking copyWith({
    String? id,
    String? userId,
    Stylist? stylist,
    List<Service>? services,
    DateTime? date,
    String? time,
    String? notes,
    BookingStatus? status,
    int? totalPrice,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stylist: stylist ?? this.stylist,
      services: services ?? this.services,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object?> get props => [id, userId, stylist, services, date, time, notes, status, totalPrice];
}
