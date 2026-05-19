// BookingBloc - State Flow:
// BookingInitial -> BookingInProgress (user fills selections step by step)
//   SelectStylist -> BookingInProgress (updates stylist)
//   SelectServices -> BookingInProgress (updates services)
//   SelectDate -> BookingInProgress (updates date)
//   SelectTime -> BookingInProgress (updates time)
//   AddNotes -> BookingInProgress (updates notes)
// BookingInProgress -> BookingConfirmed (after ConfirmBooking)
// BookingInitial -> HistoryLoaded (after LoadHistory)

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/stylist.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../data/dummy_data.dart';

// Events
abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class SelectStylistBooking extends BookingEvent {
  final Stylist stylist;
  const SelectStylistBooking({required this.stylist});
  @override
  List<Object?> get props => [stylist];
}

class SelectServicesBooking extends BookingEvent {
  final List<Service> services;
  const SelectServicesBooking({required this.services});
  @override
  List<Object?> get props => [services];
}

class SelectDateBooking extends BookingEvent {
  final DateTime date;
  const SelectDateBooking({required this.date});
  @override
  List<Object?> get props => [date];
}

class SelectTimeBooking extends BookingEvent {
  final String time;
  const SelectTimeBooking({required this.time});
  @override
  List<Object?> get props => [time];
}

class AddNotesBooking extends BookingEvent {
  final String notes;
  const AddNotesBooking({required this.notes});
  @override
  List<Object?> get props => [notes];
}

class ConfirmBooking extends BookingEvent {
  final String? voucherCode;
  const ConfirmBooking({this.voucherCode});
  @override
  List<Object?> get props => [voucherCode];
}

class LoadHistory extends BookingEvent {
  const LoadHistory();
}

// States
abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingInProgress extends BookingState {
  final Stylist? stylist;
  final List<Service> services;
  final DateTime? date;
  final String? time;
  final String notes;
  final int subtotal;

  const BookingInProgress({
    this.stylist,
    this.services = const [],
    this.date,
    this.time,
    this.notes = '',
    this.subtotal = 0,
  });

  BookingInProgress copyWith({
    Stylist? stylist,
    List<Service>? services,
    DateTime? date,
    String? time,
    String? notes,
    int? subtotal,
  }) {
    return BookingInProgress(
      stylist: stylist ?? this.stylist,
      services: services ?? this.services,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  List<Object?> get props => [stylist, services, date, time, notes, subtotal];
}

class BookingConfirmed extends BookingState {
  final Booking booking;
  const BookingConfirmed({required this.booking});
  @override
  List<Object?> get props => [booking];
}

class HistoryLoaded extends BookingState {
  final List<Booking> history;
  const HistoryLoaded({required this.history});
  @override
  List<Object?> get props => [history];
}

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final List<Booking> _confirmedBookings = [];

  BookingBloc() : super(BookingInitial()) {
    on<SelectStylistBooking>(_onSelectStylist);
    on<SelectServicesBooking>(_onSelectServices);
    on<SelectDateBooking>(_onSelectDate);
    on<SelectTimeBooking>(_onSelectTime);
    on<AddNotesBooking>(_onAddNotes);
    on<ConfirmBooking>(_onConfirmBooking);
    on<LoadHistory>(_onLoadHistory);
  }

  void _onSelectStylist(SelectStylistBooking event, Emitter<BookingState> emit) {
    final current = state is BookingInProgress ? state as BookingInProgress : const BookingInProgress();
    emit(current.copyWith(stylist: event.stylist));
  }

  void _onSelectServices(SelectServicesBooking event, Emitter<BookingState> emit) {
    final current = state is BookingInProgress ? state as BookingInProgress : const BookingInProgress();
    final total = event.services.fold<int>(0, (sum, s) => sum + s.price);
    emit(current.copyWith(services: event.services, subtotal: total));
  }

  void _onSelectDate(SelectDateBooking event, Emitter<BookingState> emit) {
    final current = state is BookingInProgress ? state as BookingInProgress : const BookingInProgress();
    emit(current.copyWith(date: event.date));
  }

  void _onSelectTime(SelectTimeBooking event, Emitter<BookingState> emit) {
    final current = state is BookingInProgress ? state as BookingInProgress : const BookingInProgress();
    emit(current.copyWith(time: event.time));
  }

  void _onAddNotes(AddNotesBooking event, Emitter<BookingState> emit) {
    final current = state is BookingInProgress ? state as BookingInProgress : const BookingInProgress();
    emit(current.copyWith(notes: event.notes));
  }

  void _onConfirmBooking(ConfirmBooking event, Emitter<BookingState> emit) async {
    final current = state as BookingInProgress;
    emit(const BookingInitial()); // show loading

    await Future.delayed(const Duration(seconds: 1));

    int totalPrice = current.subtotal;
    if (event.voucherCode?.toUpperCase() == 'SALON10') {
      totalPrice = (totalPrice * 0.9).round();
    }

    final booking = Booking(
      id: 'B${DateTime.now().millisecondsSinceEpoch}',
      userId: DummyData.currentUser.id,
      stylist: current.stylist!,
      services: current.services,
      date: current.date!,
      time: current.time!,
      notes: current.notes,
      status: BookingStatus.confirmed,
      totalPrice: totalPrice,
    );

    _confirmedBookings.add(booking);
    emit(BookingConfirmed(booking: booking));
  }

  void _onLoadHistory(LoadHistory event, Emitter<BookingState> emit) async {
    emit(const BookingInitial());
    await Future.delayed(const Duration(milliseconds: 300));
    final history = [..._confirmedBookings, ...DummyData.bookingHistory];
    emit(HistoryLoaded(history: history));
  }
}
