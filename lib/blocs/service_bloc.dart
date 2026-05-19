// ServiceBloc - State Flow:
// ServiceInitial -> ServiceLoaded (all services loaded)
// ServiceLoaded -> ServiceLoaded (search filters services)
// CartUpdated emitted whenever AddToCart/RemoveFromCart/ClearCart called.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/service.dart';
import '../models/cart_item.dart';
import '../data/dummy_data.dart';

// Events
abstract class ServiceEvent extends Equatable {
  const ServiceEvent();
  @override
  List<Object?> get props => [];
}

class LoadServices extends ServiceEvent {}

class SearchService extends ServiceEvent {
  final String query;
  const SearchService({required this.query});
  @override
  List<Object?> get props => [query];
}

class AddToCart extends ServiceEvent {
  final Service service;
  const AddToCart({required this.service});
  @override
  List<Object?> get props => [service];
}

class RemoveFromCart extends ServiceEvent {
  final Service service;
  const RemoveFromCart({required this.service});
  @override
  List<Object?> get props => [service];
}

class ClearCart extends ServiceEvent {}

// States
abstract class ServiceState extends Equatable {
  const ServiceState();
  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<Service> services;
  final List<CartItem> cart;
  final String searchQuery;
  const ServiceLoaded({
    required this.services,
    required this.cart,
    this.searchQuery = '',
  });
  @override
  List<Object?> get props => [services, cart, searchQuery];

  int get cartItemCount => cart.fold(0, (sum, item) => sum + item.quantity);
  int get cartTotalPrice => cart.fold(0, (sum, item) => sum + (item.service.price * item.quantity));
}

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  ServiceBloc() : super(ServiceInitial()) {
    on<LoadServices>(_onLoadServices);
    on<SearchService>(_onSearchService);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
  }

  void _onLoadServices(LoadServices event, Emitter<ServiceState> emit) {
    List<CartItem> existingCart = [];
    if (state is ServiceLoaded) {
      existingCart = (state as ServiceLoaded).cart;
    }
    emit(ServiceLoaded(services: DummyData.services, cart: existingCart));
  }

  void _onSearchService(SearchService event, Emitter<ServiceState> emit) {
    final state = this.state;
    if (state is ServiceLoaded) {
      final query = event.query.toLowerCase();
      final filtered = DummyData.services
          .where((s) =>
              s.name.toLowerCase().contains(query) ||
              s.category.toLowerCase().contains(query))
          .toList();
      emit(ServiceLoaded(
        services: filtered,
        cart: state.cart,
        searchQuery: event.query,
      ));
    }
  }

  void _onAddToCart(AddToCart event, Emitter<ServiceState> emit) {
    final state = this.state;
    if (state is ServiceLoaded) {
      final existingIndex = state.cart.indexWhere((item) => item.service.id == event.service.id);
      List<CartItem> updatedCart = List.from(state.cart);
      if (existingIndex >= 0) {
        final existingItem = updatedCart[existingIndex];
        updatedCart[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
      } else {
        updatedCart.add(CartItem(service: event.service, quantity: 1));
      }
      emit(ServiceLoaded(services: state.services, cart: updatedCart, searchQuery: state.searchQuery));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<ServiceState> emit) {
    final state = this.state;
    if (state is ServiceLoaded) {
      final existingIndex = state.cart.indexWhere((item) => item.service.id == event.service.id);
      List<CartItem> updatedCart = List.from(state.cart);
      if (existingIndex >= 0) {
        final existingItem = updatedCart[existingIndex];
        if (existingItem.quantity > 1) {
          updatedCart[existingIndex] = existingItem.copyWith(quantity: existingItem.quantity - 1);
        } else {
          updatedCart.removeAt(existingIndex);
        }
      }
      emit(ServiceLoaded(services: state.services, cart: updatedCart, searchQuery: state.searchQuery));
    }
  }

  void _onClearCart(ClearCart event, Emitter<ServiceState> emit) {
    final state = this.state;
    if (state is ServiceLoaded) {
      emit(ServiceLoaded(services: state.services, cart: [], searchQuery: state.searchQuery));
    }
  }
}
