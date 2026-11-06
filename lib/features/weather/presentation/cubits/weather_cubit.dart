import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/city_location_entity.dart';
import '../../domain/usecases/preference_usecases.dart';
import '../../domain/usecases/weather_usecases.dart';
import '../../domain/usecases/city_usecases.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final GetWeatherByGpsUseCase getWeatherByGpsUseCase;
  final GetWeatherByCityUseCase getWeatherByCityUseCase;
  final GetCachedWeatherUseCase getCachedWeatherUseCase;
  final ToggleFavoriteCityUseCase toggleFavoriteCityUseCase;
  final GetTemperatureUnitUseCase getTemperatureUnitUseCase;
  final SetTemperatureUnitUseCase setTemperatureUnitUseCase;

  WeatherCubit({
    required this.getWeatherByGpsUseCase,
    required this.getWeatherByCityUseCase,
    required this.getCachedWeatherUseCase,
    required this.toggleFavoriteCityUseCase,
    required this.getTemperatureUnitUseCase,
    required this.setTemperatureUnitUseCase,
  }) : super(const WeatherInitial());

  String _currentUnit = ApiConstants.unitCelsius;
  String get currentUnit => _currentUnit;

  Future<void> loadInitialWeather() async {
    _currentUnit = await getTemperatureUnitUseCase();
    emit(const WeatherLoading());

    try {
      final dashboard = await getWeatherByGpsUseCase(unit: _currentUnit);
      emit(
        WeatherLoaded(
          dashboard: dashboard,
          temperatureUnit: _currentUnit,
          isFavorite: dashboard.location.isFavorite,
          isOfflineCached: dashboard.isOfflineCached,
        ),
      );
    } catch (e) {
      final cached = await getCachedWeatherUseCase();
      emit(
        WeatherError(
          message: e.toString().replaceFirst('Exception: ', ''),
          cachedDashboard: cached,
        ),
      );
    }
  }

  Future<void> fetchWeatherForCurrentGps() async {
    final currentDashboard = state is WeatherLoaded
        ? (state as WeatherLoaded).dashboard
        : null;
    emit(WeatherLoading(previousDashboard: currentDashboard));

    try {
      final dashboard = await getWeatherByGpsUseCase(unit: _currentUnit);
      emit(
        WeatherLoaded(
          dashboard: dashboard,
          temperatureUnit: _currentUnit,
          isFavorite: dashboard.location.isFavorite,
          isOfflineCached: dashboard.isOfflineCached,
        ),
      );
    } catch (e) {
      final cached = await getCachedWeatherUseCase();
      emit(
        WeatherError(
          message: e.toString().replaceFirst('Exception: ', ''),
          cachedDashboard: cached ?? currentDashboard,
        ),
      );
    }
  }

  Future<void> fetchWeatherForCity(CityLocationEntity city) async {
    final currentDashboard = state is WeatherLoaded
        ? (state as WeatherLoaded).dashboard
        : null;
    emit(WeatherLoading(previousDashboard: currentDashboard));

    try {
      final dashboard = await getWeatherByCityUseCase(
        city: city,
        unit: _currentUnit,
      );
      emit(
        WeatherLoaded(
          dashboard: dashboard,
          temperatureUnit: _currentUnit,
          isFavorite: city.isFavorite,
          isOfflineCached: dashboard.isOfflineCached,
        ),
      );
    } catch (e) {
      final cached = await getCachedWeatherUseCase();
      emit(
        WeatherError(
          message: e.toString().replaceFirst('Exception: ', ''),
          cachedDashboard: cached ?? currentDashboard,
        ),
      );
    }
  }

  Future<void> toggleTemperatureUnit() async {
    final newUnit = _currentUnit == ApiConstants.unitCelsius
        ? ApiConstants.unitFahrenheit
        : ApiConstants.unitCelsius;

    _currentUnit = newUnit;
    await setTemperatureUnitUseCase(newUnit);

    if (state is WeatherLoaded) {
      final currentState = state as WeatherLoaded;
      emit(WeatherLoading(previousDashboard: currentState.dashboard));

      try {
        final updatedDashboard = await getWeatherByCityUseCase(
          city: currentState.dashboard.location,
          unit: newUnit,
        );

        emit(
          WeatherLoaded(
            dashboard: updatedDashboard,
            temperatureUnit: newUnit,
            isFavorite: currentState.isFavorite,
            isOfflineCached: updatedDashboard.isOfflineCached,
          ),
        );
      } catch (_) {
        // If refetch fails, emit state with updated unit flag
        emit(currentState.copyWith(temperatureUnit: newUnit));
      }
    }
  }

  Future<void> toggleFavorite() async {
    if (state is WeatherLoaded) {
      final currentState = state as WeatherLoaded;
      final newFav = !currentState.isFavorite;

      await toggleFavoriteCityUseCase(currentState.dashboard.location);
      emit(currentState.copyWith(isFavorite: newFav));
    }
  }

  void useCachedData() {
    if (state is WeatherError) {
      final errorState = state as WeatherError;
      if (errorState.cachedDashboard != null) {
        emit(
          WeatherLoaded(
            dashboard: errorState.cachedDashboard!.copyWith(
              isOfflineCached: true,
            ),
            temperatureUnit: _currentUnit,
            isFavorite: errorState.cachedDashboard!.location.isFavorite,
            isOfflineCached: true,
          ),
        );
      }
    }
  }

  Future<void> refreshWeather() async {
    if (state is WeatherLoaded) {
      final currentCity = (state as WeatherLoaded).dashboard.location;
      await fetchWeatherForCity(currentCity);
    } else {
      await fetchWeatherForCurrentGps();
    }
  }
}
