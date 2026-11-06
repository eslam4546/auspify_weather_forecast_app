import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/city_location_entity.dart';
import '../../domain/entities/weather_entities.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/location_service.dart';
import '../datasources/weather_local_data_source.dart';
import '../datasources/weather_remote_data_source.dart';
import '../models/city_location_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;
  final LocationService locationService;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.locationService,
  });

  @override
  Future<WeatherDashboardEntity> getWeatherByCoordinates({
    required double lat,
    required double lon,
    required String unit,
    String? cityName,
    String? country,
  }) async {
    final isFav = await localDataSource.isCityFavorite(cityName.hashCode);
    final location = CityLocationEntity(
      id: cityName.hashCode,
      name: cityName ?? 'Selected Location',
      country: country ?? '',
      latitude: lat,
      longitude: lon,
      isFavorite: isFav,
    );

    try {
      final dashboard = await remoteDataSource.fetchForecast(
        latitude: lat,
        longitude: lon,
        unit: unit,
        location: location,
      );

      // Cache fresh data locally
      await localDataSource.cacheWeatherDashboard(dashboard);
      return dashboard;
    } on ServerException catch (e) {
      // Offline fallback: check if we have cached data
      final cached = await localDataSource.getCachedWeatherDashboard();
      if (cached != null) {
        return cached.copyWith(isOfflineCached: true);
      }
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedWeatherDashboard();
      if (cached != null) {
        return cached.copyWith(isOfflineCached: true);
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<WeatherDashboardEntity> getWeatherByCityLocation({
    required CityLocationEntity city,
    required String unit,
  }) async {
    final isFav = await localDataSource.isCityFavorite(city.id);
    final updatedCity = city.copyWith(isFavorite: isFav);

    try {
      final dashboard = await remoteDataSource.fetchForecast(
        latitude: city.latitude,
        longitude: city.longitude,
        unit: unit,
        location: updatedCity,
      );

      // Cache fresh data locally
      await localDataSource.cacheWeatherDashboard(dashboard);
      return dashboard;
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedWeatherDashboard();
      if (cached != null && cached.location.name == city.name) {
        return cached.copyWith(isOfflineCached: true);
      }
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedWeatherDashboard();
      if (cached != null && cached.location.name == city.name) {
        return cached.copyWith(isOfflineCached: true);
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<WeatherDashboardEntity> getWeatherForCurrentGpsLocation({
    required String unit,
  }) async {
    CityLocationEntity location;

    try {
      final position = await locationService.getCurrentPosition();
      location = CityLocationEntity(
        id: 'gps_current'.hashCode,
        name: 'Current Location',
        country: 'GPS Active',
        latitude: position.latitude,
        longitude: position.longitude,
        isFavorite: false,
      );
    } on LocationException catch (_) {
      // Graceful fallback to default Cairo coordinates if permission is denied or service disabled
      location = const CityLocationEntity(
        id: 360630,
        name: ApiConstants.defaultCityName,
        country: ApiConstants.defaultCountry,
        latitude: ApiConstants.defaultLatitude,
        longitude: ApiConstants.defaultLongitude,
        isFavorite: false,
      );
    } catch (_) {
      location = const CityLocationEntity(
        id: 360630,
        name: ApiConstants.defaultCityName,
        country: ApiConstants.defaultCountry,
        latitude: ApiConstants.defaultLatitude,
        longitude: ApiConstants.defaultLongitude,
        isFavorite: false,
      );
    }

    try {
      final dashboard = await remoteDataSource.fetchForecast(
        latitude: location.latitude,
        longitude: location.longitude,
        unit: unit,
        location: location,
      );

      await localDataSource.cacheWeatherDashboard(dashboard);
      return dashboard;
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedWeatherDashboard();
      if (cached != null) {
        return cached.copyWith(isOfflineCached: true);
      }
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedWeatherDashboard();
      if (cached != null) {
        return cached.copyWith(isOfflineCached: true);
      }
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<CityLocationEntity>> searchCities(String query) async {
    try {
      final models = await remoteDataSource.searchCities(query);
      final favoriteCities = await localDataSource.getFavoriteCities();
      final favoriteIds = favoriteCities.map((c) => c.id).toSet();

      return models.map((model) {
        return model.copyWith(isFavorite: favoriteIds.contains(model.id));
      }).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<CityLocationEntity>> getFavoriteCities() async {
    try {
      return await localDataSource.getFavoriteCities();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> toggleFavoriteCity(CityLocationEntity city) async {
    try {
      final isFav = await localDataSource.isCityFavorite(city.id);
      if (isFav) {
        await localDataSource.removeFavoriteCity(city.id);
      } else {
        await localDataSource.saveFavoriteCity(
          CityLocationModel.fromEntity(city),
        );
      }
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<void> removeFavoriteCity(int cityId) async {
    try {
      await localDataSource.removeFavoriteCity(cityId);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  @override
  Future<String> getPreferredTemperatureUnit() async {
    return await localDataSource.getTemperatureUnit();
  }

  @override
  Future<void> setPreferredTemperatureUnit(String unit) async {
    await localDataSource.setTemperatureUnit(unit);
  }

  @override
  Future<bool> getPreferredThemeMode() async {
    return await localDataSource.getThemeModeIsDark();
  }

  @override
  Future<void> setPreferredThemeMode(bool isDark) async {
    await localDataSource.setThemeModeIsDark(isDark);
  }

  @override
  Future<WeatherDashboardEntity?> getCachedWeather() async {
    try {
      return await localDataSource.getCachedWeatherDashboard();
    } catch (_) {
      return null;
    }
  }
}
