import '../entities/city_location_entity.dart';
import '../entities/weather_entities.dart';

abstract class WeatherRepository {
  /// Fetches real-time and forecast weather by explicit latitude and longitude coordinates.
  Future<WeatherDashboardEntity> getWeatherByCoordinates({
    required double lat,
    required double lon,
    required String unit,
    String? cityName,
    String? country,
  });

  /// Fetches weather for a selected [CityLocationEntity].
  Future<WeatherDashboardEntity> getWeatherByCityLocation({
    required CityLocationEntity city,
    required String unit,
  });

  /// Fetches weather for the device's real-time GPS location via Geolocator.
  /// Falls back gracefully to Cairo default coordinates if location permission is denied.
  Future<WeatherDashboardEntity> getWeatherForCurrentGpsLocation({
    required String unit,
  });

  /// Searches global cities matching [query] using Open-Meteo Geocoding API.
  Future<List<CityLocationEntity>> searchCities(String query);

  /// Retrieves all bookmarked favorite cities from local persistence.
  Future<List<CityLocationEntity>> getFavoriteCities();

  /// Toggles a city's favorite bookmark status.
  Future<void> toggleFavoriteCity(CityLocationEntity city);

  /// Removes a favorite city by its unique ID.
  Future<void> removeFavoriteCity(int cityId);

  /// Gets the persisted temperature unit ('celsius' or 'fahrenheit').
  Future<String> getPreferredTemperatureUnit();

  /// Persists the temperature unit preference ('celsius' or 'fahrenheit').
  Future<void> setPreferredTemperatureUnit(String unit);

  /// Gets the persisted theme mode preference (true = dark, false = light).
  Future<bool> getPreferredThemeMode();

  /// Persists the theme mode preference.
  Future<void> setPreferredThemeMode(bool isDark);

  /// Retrieves the last cached weather dashboard from local storage (if any).
  Future<WeatherDashboardEntity?> getCachedWeather();
}
