import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/stylist.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../data/dummy_data.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class LoadHistory extends BookingEvent {
  const LoadHistory();
}

class SelectStylist extends BookingEvent {
  final Stylist stylist;
  const SelectStylist(this.stylist);
  @override
  List<Object?> get props => [stylist];
}

class SelectServices extends BookingEvent {
  final List<Service> services;
  const SelectServices(this.services);
  @override
  List<Object?> get props => [services];
}

class SelectDate extends BookingEvent {
  final DateTime date;
  const SelectDate(this.date);
  @override
  List<Object?> get props => [date];
}

class SelectTime extends BookingEvent {
  final String time;
  const SelectTime(this.time);
  @override
  List<Object?> get props => [time];
}

class AddNote extends BookingEvent {
  final String note;
  const AddNote(this.note);
  @override
  List<Object?> get props => [note];
}

class ApplyVoucher extends BookingEvent {
  final String code;
  const ApplyVoucher(this.code);
  @override
  List<Object?> get props => [code];
}

class RemoveVoucher extends BookingEvent {
  const RemoveVoucher();
}

class ConfirmBooking extends BookingEvent {
  final String userId;
  const ConfirmBooking({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class ResetBookingForm extends BookingEvent {
  const ResetBookingForm();
}

class ResetConfirmedFlag extends BookingEvent {
  const ResetConfirmedFlag();
}

class BookingState extends Equatable {
  final List<Booking> bookingHistory;
  final Stylist? selectedStylist;
  final List<Service> selectedServices;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? notes;
  final String? appliedVoucher;
  final int discountAmount;
  final bool isConfirmed;
  final bool isLoading;
  final String? errorMessage;

  const BookingState({
    this.bookingHistory = const [],
    this.selectedStylist,
    this.selectedServices = const [],
    this.selectedDate,
    this.selectedTime,
    this.notes,
    this.appliedVoucher,
    this.discountAmount = 0,
    this.isConfirmed = false,
    this.isLoading = false,
    this.errorMessage,
  });

  int get subtotal => selectedServices.fold(0, (sum, s) => sum + s.price);
  int get total => subtotal - discountAmount;

  static const _undefined = Object();

  BookingState copyWith({
    List<Booking>? bookingHistory,
    Object? selectedStylist = _undefined,
    List<Service>? selectedServices,
    Object? selectedDate = _undefined,
    Object? selectedTime = _undefined,
    Object? notes = _undefined,
    Object? appliedVoucher = _undefined,
    int? discountAmount,
    bool? isConfirmed,
    bool? isLoading,
    Object? errorMessage = _undefined,
  }) {
    return BookingState(
      bookingHistory: bookingHistory ?? this.bookingHistory,
      selectedStylist: selectedStylist == _undefined
          ? this.selectedStylist
          : selectedStylist as Stylist?,
      selectedServices: selectedServices ?? this.selectedServices,
      selectedDate: selectedDate == _undefined
          ? this.selectedDate
          : selectedDate as DateTime?,
      selectedTime: selectedTime == _undefined
          ? this.selectedTime
          : selectedTime as String?,
      notes: notes == _undefined
          ? this.notes
          : notes as String?,
      appliedVoucher: appliedVoucher == _undefined
          ? this.appliedVoucher
          : appliedVoucher as String?,
      discountAmount: discountAmount ?? this.discountAmount,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _undefined
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        bookingHistory,
        selectedStylist,
        selectedServices,
        selectedDate,
        selectedTime,
        notes,
        appliedVoucher,
        discountAmount,
        isConfirmed,
        isLoading,
        errorMessage,
      ];
}

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc() : super(const BookingState()) {
    on<LoadHistory>(_onLoadHistory);
    on<SelectStylist>(_onSelectStylist);
    on<SelectServices>(_onSelectServices);
    on<SelectDate>(_onSelectDate);
    on<SelectTime>(_onSelectTime);
    on<AddNote>(_onAddNote);
    on<ApplyVoucher>(_onApplyVoucher);
    on<RemoveVoucher>(_onRemoveVoucher);
    on<ConfirmBooking>(_onConfirmBooking);
    on<ResetBookingForm>(_onResetBookingForm);
    on<ResetConfirmedFlag>(_onResetConfirmedFlag);
  }

  void _onLoadHistory(LoadHistory event, Emitter<BookingState> emit) {
    if (state.bookingHistory.isEmpty) {
      emit(state.copyWith(bookingHistory: DummyData.bookingHistory));
    }
  }

  void _onSelectStylist(SelectStylist event, Emitter<BookingState> emit) {
    emit(state.copyWith(selectedStylist: event.stylist));
  }

  void _onSelectServices(SelectServices event, Emitter<BookingState> emit) {
    emit(state.copyWith(selectedServices: event.services));
  }

  void _onSelectDate(SelectDate event, Emitter<BookingState> emit) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onSelectTime(SelectTime event, Emitter<BookingState> emit) {
    emit(state.copyWith(selectedTime: event.time));
  }

  void _onAddNote(AddNote event, Emitter<BookingState> emit) {
    emit(state.copyWith(notes: event.note));
  }

  void _onApplyVoucher(ApplyVoucher event, Emitter<BookingState> emit) {
    final code = event.code.trim().toUpperCase();
    if (code == 'SALON10') {
      final discount = (state.subtotal * 0.1).round();
      emit(state.copyWith(
        appliedVoucher: code,
        discountAmount: discount,
        errorMessage: null,
      ));
    } else {
      emit(state.copyWith(
        appliedVoucher: null,
        discountAmount: 0,
        errorMessage: 'Kode voucher tidak valid',
      ));
    }
  }

  void _onRemoveVoucher(RemoveVoucher event, Emitter<BookingState> emit) {
    emit(state.copyWith(
      appliedVoucher: null,
      discountAmount: 0,
      errorMessage: null,
    ));
  }

  Future<void> _onConfirmBooking(
    ConfirmBooking event,
    Emitter<BookingState> emit,
  ) async {
    debugPrint('=== _onConfirmBooking START ===');

    try {
      emit(state.copyWith(isLoading: true, isConfirmed: false));

      await Future.delayed(const Duration(seconds: 1));

      if (state.selectedStylist == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Stylist belum dipilih',
        ));
        return;
      }
      if (state.selectedDate == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Tanggal belum dipilih',
        ));
        return;
      }
      if (state.selectedTime == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Jam belum dipilih',
        ));
        return;
      }
      if (state.selectedServices.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Belum ada layanan dipilih',
        ));
        return;
      }

      final newBooking = Booking(
        id: 'BK${DateTime.now().millisecondsSinceEpoch}',
        userId: event.userId,
        stylist: state.selectedStylist!,
        services: List.from(state.selectedServices),
        date: state.selectedDate!,
        time: state.selectedTime!,
        notes: state.notes,
        status: BookingStatus.menunggu,
        totalPrice: state.total,
      );

      debugPrint('=== New booking created: ${newBooking.id} ===');

      final updatedHistory = [newBooking, ...state.bookingHistory];

      emit(state.copyWith(
        isLoading: false,
        isConfirmed: true,
        bookingHistory: updatedHistory,
        selectedStylist: null,
        selectedDate: null,
        selectedTime: null,
        notes: null,
        discountAmount: 0,
        appliedVoucher: null,
      ));

      debugPrint('=== _onConfirmBooking DONE, isConfirmed=true ===');
    } catch (e, stackTrace) {
      debugPrint('=== ConfirmBooking ERROR: $e ===');
      debugPrint(stackTrace.toString());
      emit(state.copyWith(
        isLoading: false,
        isConfirmed: false,
        errorMessage: 'Gagal konfirmasi booking: $e',
      ));
    }
  }

  void _onResetBookingForm(ResetBookingForm event, Emitter<BookingState> emit) {
    emit(state.copyWith(
      isConfirmed: false,
      errorMessage: null,
    ));
  }

  void _onResetConfirmedFlag(ResetConfirmedFlag event, Emitter<BookingState> emit) {
    emit(state.copyWith(isConfirmed: false));
  }
}
