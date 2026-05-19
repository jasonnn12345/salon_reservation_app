// StylistBloc - State Flow:
// StylistInitial -> StylistLoading -> StylistLoaded (all stylists loaded)
// StylistLoaded -> StylistFiltered (search performed)
// StylistLoaded -> StylistDetailLoaded (detail view opened)

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/stylist.dart';
import '../data/dummy_data.dart';

// Events
abstract class StylistEvent extends Equatable {
  const StylistEvent();
  @override
  List<Object?> get props => [];
}

class LoadStylists extends StylistEvent {}

class SearchStylist extends StylistEvent {
  final String query;
  const SearchStylist({required this.query});
  @override
  List<Object?> get props => [query];
}

class SelectStylist extends StylistEvent {
  final String id;
  const SelectStylist({required this.id});
  @override
  List<Object?> get props => [id];
}

// States
abstract class StylistState extends Equatable {
  const StylistState();
  @override
  List<Object?> get props => [];
}

class StylistInitial extends StylistState {}

class StylistLoading extends StylistState {}

class StylistLoaded extends StylistState {
  final List<Stylist> stylists;
  const StylistLoaded({required this.stylists});
  @override
  List<Object?> get props => [stylists];
}

class StylistFiltered extends StylistState {
  final List<Stylist> stylists;
  const StylistFiltered({required this.stylists});
  @override
  List<Object?> get props => [stylists];
}

class StylistDetailLoaded extends StylistState {
  final Stylist stylist;
  const StylistDetailLoaded({required this.stylist});
  @override
  List<Object?> get props => [stylist];
}

class StylistBloc extends Bloc<StylistEvent, StylistState> {
  StylistBloc() : super(StylistInitial()) {
    on<LoadStylists>(_onLoadStylists);
    on<SearchStylist>(_onSearchStylist);
    on<SelectStylist>(_onSelectStylist);
  }

  void _onLoadStylists(LoadStylists event, Emitter<StylistState> emit) async {
    emit(StylistLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(StylistLoaded(stylists: DummyData.stylists));
  }

  void _onSearchStylist(SearchStylist event, Emitter<StylistState> emit) {
    final query = event.query.toLowerCase();
    final allStylists = DummyData.stylists;
    final filtered = allStylists
        .where((s) =>
            s.name.toLowerCase().contains(query) ||
            s.specialization.toLowerCase().contains(query))
        .toList();
    emit(StylistFiltered(stylists: filtered));
  }

  void _onSelectStylist(SelectStylist event, Emitter<StylistState> emit) {
    final stylist = DummyData.stylists.firstWhere((s) => s.id == event.id);
    emit(StylistDetailLoaded(stylist: stylist));
  }
}
