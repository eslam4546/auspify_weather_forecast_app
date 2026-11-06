import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast_app/features/weather/data/models/city_location_model.dart';
import 'package:weather_forecast_app/features/weather/data/models/weather_dashboard_model.dart';
import 'package:weather_forecast_app/features/weather/domain/entities/city_location_entity.dart';

void main() {
  group('CityLocationModel Tests', () {
    test('should correctly deserialize from Open-Meteo Geocoding JSON', () {
      final json = {
        'id': 360630,
        'name': 'Cairo',
        'latitude': 30.06263,
        'longitude': 31.24967,
        'country': 'Egypt',
        'admin1': 'Cairo',
      };

      final model = CityLocationModel.fromJson(json);

      expect(model.id, equals(360630));
      expect(model.name, equals('Cairo'));
      expect(model.country, equals('Egypt'));
      expect(model.latitude, equals(30.06263));
      expect(model.longitude, equals(31.24967));
      expect(model.admin1, equals('Cairo'));
      expect(model.isFavorite, isFalse);
    });

    test('should roundtrip toJson and fromJson cleanly', () {
      const entity = CityLocationEntity(
        id: 12345,
        name: 'Tokyo',
        country: 'Japan',
        admin1: 'Kanto',
        latitude: 35.6895,
        longitude: 139.6917,
        isFavorite: true,
      );

      final model = CityLocationModel.fromEntity(entity);
      final json = model.toJson();
      final deserialized = CityLocationModel.fromJson(json);

      expect(deserialized.id, equals(12345));
      expect(deserialized.name, equals('Tokyo'));
      expect(deserialized.isFavorite, isTrue);
    });
  });

  group('WeatherDashboardModel Tests', () {
    test('should correctly parse Open-Meteo forecast JSON payload', () {
      const location = CityLocationEntity(
        id: 1,
        name: 'Cairo',
        country: 'Egypt',
        latitude: 30.0,
        longitude: 31.0,
      );

      final openMeteoJson = {
        'latitude': 30.0,
        'longitude': 31.0,
        'current': {
          'time': '2026-11-06T18:00',
          'temperature_2m': 22.4,
          'relative_humidity_2m': 65,
          'apparent_temperature': 21.8,
          'is_day': 0,
          'weather_code': 1,
          'surface_pressure': 1014.2,
          'wind_speed_10m': 12.5,
        },
        'hourly': {
          'time': ['2026-11-06T18:00', '2026-11-06T19:00', '2026-11-06T20:00'],
          'temperature_2m': [22.4, 21.0, 19.5],
          'weather_code': [1, 2, 3],
          'precipitation_probability': [0, 10, 20],
        },
        'daily': {
          'time': ['2026-11-06', '2026-11-07'],
          'weather_code': [1, 2],
          'temperature_2m_max': [26.5, 27.1],
          'temperature_2m_min': [16.2, 17.0],
          'uv_index_max': [5.2, 5.5],
          'precipitation_probability_max': [10, 0],
        },
      };

      final dashboard = WeatherDashboardModel.fromOpenMeteoJson(
        json: openMeteoJson,
        location: location,
      );

      expect(dashboard.location.name, equals('Cairo'));
      expect(dashboard.current.temperature, equals(22.4));
      expect(dashboard.current.humidity, equals(65));
      expect(dashboard.current.uvIndex, equals(5.2));
      expect(dashboard.current.isDay, isFalse);
      expect(dashboard.hourly.length, equals(3));
      expect(dashboard.daily.length, equals(2));
      expect(dashboard.isOfflineCached, isFalse);
    });

    test('should roundtrip cache JSON correctly', () {
      const location = CityLocationEntity(
        id: 1,
        name: 'Cairo',
        country: 'Egypt',
        latitude: 30.0,
        longitude: 31.0,
      );

      final openMeteoJson = {
        'current': {
          'time': '2026-11-06T18:00',
          'temperature_2m': 22.4,
          'relative_humidity_2m': 65,
          'apparent_temperature': 21.8,
          'is_day': 1,
          'weather_code': 0,
          'surface_pressure': 1013.0,
          'wind_speed_10m': 10.0,
        },
        'hourly': {
          'time': ['2026-11-06T18:00'],
          'temperature_2m': [22.4],
          'weather_code': [0],
          'precipitation_probability': [0],
        },
        'daily': {
          'time': ['2026-11-06'],
          'weather_code': [0],
          'temperature_2m_max': [25.0],
          'temperature_2m_min': [15.0],
          'uv_index_max': [4.0],
          'precipitation_probability_max': [0],
        },
      };

      final original = WeatherDashboardModel.fromOpenMeteoJson(
        json: openMeteoJson,
        location: location,
      );

      final json = original.toJson();
      final cached = WeatherDashboardModel.fromCacheJson(json);

      expect(cached.location.name, equals('Cairo'));
      expect(cached.current.temperature, equals(22.4));
      expect(cached.isOfflineCached, isTrue);
    });
  });
}
