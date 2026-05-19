import 'package:equatable/equatable.dart';
import 'service.dart';

class CartItem extends Equatable {
  final Service service;
  final int quantity;

  const CartItem({
    required this.service,
    required this.quantity,
  });

  CartItem copyWith({Service? service, int? quantity}) {
    return CartItem(
      service: service ?? this.service,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [service, quantity];
}
