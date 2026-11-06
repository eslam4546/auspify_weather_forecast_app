import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/city_location_entity.dart';
import '../models/city_location_model.dart';
import '../models/weather_dashboard_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherDashboardModel> fetchForecast({
    required double latitude,
    required double longitude,
    required String unit,
    required CityLocationEntity location,
  });

  Future<List<CityLocationModel>> searchCities(String query);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;

  WeatherRemoteDataSourceImpl({required this.dio});

  @override
  Future<WeatherDashboardModel> fetchForecast({
    required double latitude,
    required double longitude,
    required String unit,
    required CityLocationEntity location,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.forecastBaseUrl,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': [
            'temperature_2m',
            'relative_humidity_2m',
            'apparent_temperature',
            'is_day',
            'weather_code',
            'surface_pressure',
            'wind_speed_10m',
          ].join(','),
          'hourly': [
            'temperature_2m',
            'weather_code',
            'precipitation_probability',
          ].join(','),
          'daily': [
            'weather_code',
            'temperature_2m_max',
            'temperature_2m_min',
            'uv_index_max',
            'precipitation_probability_max',
          ].join(','),
          'temperature_unit': unit == ApiConstants.unitFahrenheit
              ? ApiConstants.unitFahrenheit
              : ApiConstants.unitCelsius,
          'timezone': 'auto',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);

        return WeatherDashboardModel.fromOpenMeteoJson(
          json: data,
          location: location,
        );
      } else {
        throw ServerException(
          'Failed to retrieve forecast data.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network connection error while fetching weather.',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CityLocationModel>> searchCities(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    try {
      final response = await dio.get(
        ApiConstants.geocodingBaseUrl,
        queryParameters: {
          'name': trimmedQuery,
          'count': 10,
          'language': 'en',
          'format': 'json',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : Map<String, dynamic>.from(response.data as Map);

        final results = data['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }

        return results
            .map(
              (item) =>
                  CityLocationModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw ServerException(
          'Failed to search cities.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error while searching cities.',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
