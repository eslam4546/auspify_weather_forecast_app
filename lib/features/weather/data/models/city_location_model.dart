import '../../domain/entities/city_location_entity.dart';

class CityLocationModel extends CityLocationEntity {
  const CityLocationModel({
    required super.id,
    required super.name,
    required super.country,
    super.admin1,
    required super.latitude,
    required super.longitude,
    super.isFavorite = false,
  });

  factory CityLocationModel.fromJson(Map<String, dynamic> json) {
    return CityLocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      country:
          json['country'] as String? ?? json['country_code'] as String? ?? '',
      admin1: json['admin1'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  factory CityLocationModel.fromEntity(CityLocationEntity entity) {
    return CityLocationModel(
      id: entity.id,
      name: entity.name,
      country: entity.country,
      admin1: entity.admin1,
      latitude: entity.latitude,
      longitude: entity.longitude,
      isFavorite: entity.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite,
    };
  }
}
