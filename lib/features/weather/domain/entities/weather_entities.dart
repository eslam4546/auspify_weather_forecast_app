import 'package:equatable/equatable.dart';

import 'city_location_entity.dart';

class CurrentWeatherEntity extends Equatable {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final double surfacePressure;
  final double uvIndex;
  final int weatherCode;
  final bool isDay;
  final String time;

  const CurrentWeatherEntity({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.surfacePressure,
    required this.uvIndex,
    required this.weatherCode,
    required this.isDay,
    required this.time,
  });

  @override
  List<Object?> get props => [
    temperature,
    apparentTemperature,
    humidity,
    windSpeed,
    surfacePressure,
    uvIndex,
    weatherCode,
    isDay,
    time,
  ];
}

class HourlyForecastEntity extends Equatable {
  final String time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;

  const HourlyForecastEntity({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  @override
  List<Object?> get props => [
    time,
    temperature,
    weatherCode,
    precipitationProbability,
  ];
}

class DailyForecastEntity extends Equatable {
  final String date;
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;
  final int precipitationProbabilityMax;

  const DailyForecastEntity({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
    required this.precipitationProbabilityMax,
  });

  @override
  List<Object?> get props => [
    date,
    maxTemperature,
    minTemperature,
    weatherCode,
    precipitationProbabilityMax,
  ];
}

class WeatherDashboardEntity extends Equatable {
  final CityLocationEntity location;
  final CurrentWeatherEntity current;
  final List<HourlyForecastEntity> hourly;
  final List<DailyForecastEntity> daily;
  final DateTime lastUpdated;
  final bool isOfflineCached;

  const WeatherDashboardEntity({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.lastUpdated,
    this.isOfflineCached = false,
  });

  WeatherDashboardEntity copyWith({
    CityLocationEntity? location,
    CurrentWeatherEntity? current,
    List<HourlyForecastEntity>? hourly,
    List<DailyForecastEntity>? daily,
    DateTime? lastUpdated,
    bool? isOfflineCached,
  }) {
    return WeatherDashboardEntity(
      location: location ?? this.location,
      current: current ?? this.current,
      hourly: hourly ?? this.hourly,
      daily: daily ?? this.daily,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOfflineCached: isOfflineCached ?? this.isOfflineCached,
    );
  }

  @override
  List<Object?> get props => [
    location,
    current,
    hourly,
    daily,
    lastUpdated,
    isOfflineCached,
  ];
}
