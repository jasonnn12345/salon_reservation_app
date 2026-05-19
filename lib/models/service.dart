import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String name;
  final int price;
  final int duration;
  final String category;

  const Service({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.category,
  });

  @override
  List<Object?> get props => [id, name, price, duration, category];
}
