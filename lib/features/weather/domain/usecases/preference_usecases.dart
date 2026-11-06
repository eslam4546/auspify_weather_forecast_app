import '../repositories/weather_repository.dart';

class GetTemperatureUnitUseCase {
  final WeatherRepository repository;

  const GetTemperatureUnitUseCase(this.repository);

  Future<String> call() {
    return repository.getPreferredTemperatureUnit();
  }
}

class SetTemperatureUnitUseCase {
  final WeatherRepository repository;

  const SetTemperatureUnitUseCase(this.repository);

  Future<void> call(String unit) {
    return repository.setPreferredTemperatureUnit(unit);
  }
}

class GetThemeModeUseCase {
  final WeatherRepository repository;

  const GetThemeModeUseCase(this.repository);

  Future<bool> call() {
    return repository.getPreferredThemeMode();
  }
}

class SetThemeModeUseCase {
  final WeatherRepository repository;

  const SetThemeModeUseCase(this.repository);

  Future<void> call(bool isDark) {
    return repository.setPreferredThemeMode(isDark);
  }
}
