import 'package:equatable/equatable.dart';

class CityLocationEntity extends Equatable {
  final int id;
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;
  final bool isFavorite;

  const CityLocationEntity({
    required this.id,
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
  });

  CityLocationEntity copyWith({
    int? id,
    String? name,
    String? country,
    String? admin1,
    double? latitude,
    double? longitude,
    bool? isFavorite,
  }) {
    return CityLocationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      admin1: admin1 ?? this.admin1,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    country,
    admin1,
    latitude,
    longitude,
    isFavorite,
  ];
}
