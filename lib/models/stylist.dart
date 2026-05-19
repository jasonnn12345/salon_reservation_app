import 'package:equatable/equatable.dart';

class Stylist extends Equatable {
  final String id;
  final String name;
  final String photo;
  final String specialization;
  final double rating;
  final int experience;
  final List<String> reviews;

  const Stylist({
    required this.id,
    required this.name,
    required this.photo,
    required this.specialization,
    required this.rating,
    required this.experience,
    required this.reviews,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, photo, specialization, rating, experience, reviews];
}
