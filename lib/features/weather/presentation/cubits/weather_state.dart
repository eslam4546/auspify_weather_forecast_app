import 'package:equatable/equatable.dart';

import '../../domain/entities/weather_entities.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  final String? message;
  final WeatherDashboardEntity? previousDashboard;

  const WeatherLoading({this.message, this.previousDashboard});

  @override
  List<Object?> get props => [message, previousDashboard];
}

class WeatherLoaded extends WeatherState {
  final WeatherDashboardEntity dashboard;
  final String temperatureUnit;
  final bool isFavorite;
  final bool isOfflineCached;

  const WeatherLoaded({
    required this.dashboard,
    required this.temperatureUnit,
    required this.isFavorite,
    this.isOfflineCached = false,
  });

  WeatherLoaded copyWith({
    WeatherDashboardEntity? dashboard,
    String? temperatureUnit,
    bool? isFavorite,
    bool? isOfflineCached,
  }) {
    return WeatherLoaded(
      dashboard: dashboard ?? this.dashboard,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      isFavorite: isFavorite ?? this.isFavorite,
      isOfflineCached: isOfflineCached ?? this.isOfflineCached,
    );
  }

  @override
  List<Object?> get props => [
    dashboard,
    temperatureUnit,
    isFavorite,
    isOfflineCached,
  ];
}

class WeatherError extends WeatherState {
  final String message;
  final WeatherDashboardEntity? cachedDashboard;

  const WeatherError({required this.message, this.cachedDashboard});

  @override
  List<Object?> get props => [message, cachedDashboard];
}
