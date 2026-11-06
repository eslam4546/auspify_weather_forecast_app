import '../entities/city_location_entity.dart';
import '../entities/weather_entities.dart';
import '../repositories/weather_repository.dart';

class GetWeatherByGpsUseCase {
  final WeatherRepository repository;

  const GetWeatherByGpsUseCase(this.repository);

  Future<WeatherDashboardEntity> call({required String unit}) {
    return repository.getWeatherForCurrentGpsLocation(unit: unit);
  }
}

class GetWeatherByCityUseCase {
  final WeatherRepository repository;

  const GetWeatherByCityUseCase(this.repository);

  Future<WeatherDashboardEntity> call({
    required CityLocationEntity city,
    required String unit,
  }) {
    return repository.getWeatherByCityLocation(city: city, unit: unit);
  }
}

class GetCachedWeatherUseCase {
  final WeatherRepository repository;

  const GetCachedWeatherUseCase(this.repository);

  Future<WeatherDashboardEntity?> call() {
    return repository.getCachedWeather();
  }
}
