import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/city_location_model.dart';
import '../models/weather_dashboard_model.dart';

abstract class WeatherLocalDataSource {
  Future<void> cacheWeatherDashboard(WeatherDashboardModel dashboard);
  Future<WeatherDashboardModel?> getCachedWeatherDashboard();

  Future<List<CityLocationModel>> getFavoriteCities();
  Future<void> saveFavoriteCity(CityLocationModel city);
  Future<void> removeFavoriteCity(int cityId);
  Future<bool> isCityFavorite(int cityId);

  Future<String> getTemperatureUnit();
  Future<void> setTemperatureUnit(String unit);

  Future<bool> getThemeModeIsDark();
  Future<void> setThemeModeIsDark(bool isDark);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _cachedWeatherKey = 'CACHED_WEATHER';
  static const String _favoriteCitiesKey = 'FAVORITE_CITIES';
  static const String _temperatureUnitKey = 'PREF_TEMP_UNIT';
  static const String _themeModeKey = 'PREF_THEME_IS_DARK';

  WeatherLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheWeatherDashboard(WeatherDashboardModel dashboard) async {
    try {
      final jsonString = jsonEncode(dashboard.toJson());
      await sharedPreferences.setString(_cachedWeatherKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache weather data: $e');
    }
  }

  @override
  Future<WeatherDashboardModel?> getCachedWeatherDashboard() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedWeatherKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> decoded =
            jsonDecode(jsonString) as Map<String, dynamic>;
        return WeatherDashboardModel.fromCacheJson(decoded);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to retrieve cached weather: $e');
    }
  }

  @override
  Future<List<CityLocationModel>> getFavoriteCities() async {
    try {
      final jsonList = sharedPreferences.getStringList(_favoriteCitiesKey);
      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }
      return jsonList.map((item) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return CityLocationModel.fromJson(decoded);
      }).toList();
    } catch (e) {
      throw CacheException('Failed to retrieve favorite cities: $e');
    }
  }

  @override
  Future<void> saveFavoriteCity(CityLocationModel city) async {
    try {
      final favorites = await getFavoriteCities();
      final updatedCity = CityLocationModel(
        id: city.id,
        name: city.name,
        country: city.country,
        admin1: city.admin1,
        latitude: city.latitude,
        longitude: city.longitude,
        isFavorite: true,
      );

      favorites.removeWhere((c) => c.id == city.id);
      favorites.insert(0, updatedCity);

      final encodedList = favorites.map((c) => jsonEncode(c.toJson())).toList();
      await sharedPreferences.setStringList(_favoriteCitiesKey, encodedList);
    } catch (e) {
      throw CacheException('Failed to save favorite city: $e');
    }
  }

  @override
  Future<void> removeFavoriteCity(int cityId) async {
    try {
      final favorites = await getFavoriteCities();
      favorites.removeWhere((c) => c.id == cityId);

      final encodedList = favorites.map((c) => jsonEncode(c.toJson())).toList();
      await sharedPreferences.setStringList(_favoriteCitiesKey, encodedList);
    } catch (e) {
      throw CacheException('Failed to remove favorite city: $e');
    }
  }

  @override
  Future<bool> isCityFavorite(int cityId) async {
    try {
      final favorites = await getFavoriteCities();
      return favorites.any((c) => c.id == cityId);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> getTemperatureUnit() async {
    return sharedPreferences.getString(_temperatureUnitKey) ??
        ApiConstants.unitCelsius;
  }

  @override
  Future<void> setTemperatureUnit(String unit) async {
    await sharedPreferences.setString(_temperatureUnitKey, unit);
  }

  @override
  Future<bool> getThemeModeIsDark() async {
    // Default to dark mode (true) matching Stitch 'Aether Atmospheric Weather' design
    return sharedPreferences.getBool(_themeModeKey) ?? true;
  }

  @override
  Future<void> setThemeModeIsDark(bool isDark) async {
    await sharedPreferences.setBool(_themeModeKey, isDark);
  }
}
