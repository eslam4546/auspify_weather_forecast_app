import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast_app/core/constants/api_constants.dart';
import 'package:weather_forecast_app/features/weather/domain/entities/city_location_entity.dart';
import 'package:weather_forecast_app/features/weather/domain/entities/weather_entities.dart';
import 'package:weather_forecast_app/features/weather/domain/usecases/city_usecases.dart';
import 'package:weather_forecast_app/features/weather/domain/usecases/preference_usecases.dart';
import 'package:weather_forecast_app/features/weather/domain/usecases/weather_usecases.dart';
import 'package:weather_forecast_app/features/weather/presentation/cubits/weather_cubit.dart';
import 'package:weather_forecast_app/features/weather/presentation/cubits/weather_state.dart';

class MockGetWeatherByGpsUseCase extends Mock
    implements GetWeatherByGpsUseCase {}

class MockGetWeatherByCityUseCase extends Mock
    implements GetWeatherByCityUseCase {}

class MockGetCachedWeatherUseCase extends Mock
    implements GetCachedWeatherUseCase {}

class MockToggleFavoriteCityUseCase extends Mock
    implements ToggleFavoriteCityUseCase {}

class MockGetTemperatureUnitUseCase extends Mock
    implements GetTemperatureUnitUseCase {}

class MockSetTemperatureUnitUseCase extends Mock
    implements SetTemperatureUnitUseCase {}

void main() {
  late MockGetWeatherByGpsUseCase mockGetGps;
  late MockGetWeatherByCityUseCase mockGetCity;
  late MockGetCachedWeatherUseCase mockGetCached;
  late MockToggleFavoriteCityUseCase mockToggleFav;
  late MockGetTemperatureUnitUseCase mockGetUnit;
  late MockSetTemperatureUnitUseCase mockSetUnit;

  const testLocation = CityLocationEntity(
    id: 1,
    name: 'Cairo',
    country: 'Egypt',
    latitude: 30.0,
    longitude: 31.0,
  );

  const testCurrent = CurrentWeatherEntity(
    temperature: 24.0,
    apparentTemperature: 23.5,
    humidity: 50,
    windSpeed: 10.0,
    surfacePressure: 1013.0,
    uvIndex: 4.0,
    weatherCode: 0,
    isDay: true,
    time: '2026-11-06T12:00',
  );

  final testDashboard = WeatherDashboardEntity(
    location: testLocation,
    current: testCurrent,
    hourly: const [],
    daily: const [],
    lastUpdated: DateTime(2026, 11, 6),
  );

  setUpAll(() {
    registerFallbackValue(testLocation);
  });

  setUp(() {
    mockGetGps = MockGetWeatherByGpsUseCase();
    mockGetCity = MockGetWeatherByCityUseCase();
    mockGetCached = MockGetCachedWeatherUseCase();
    mockToggleFav = MockToggleFavoriteCityUseCase();
    mockGetUnit = MockGetTemperatureUnitUseCase();
    mockSetUnit = MockSetTemperatureUnitUseCase();

    when(() => mockGetUnit()).thenAnswer((_) async => ApiConstants.unitCelsius);
    when(() => mockSetUnit(any())).thenAnswer((_) async {});
    when(() => mockToggleFav(any())).thenAnswer((_) async {});
  });

  group('WeatherCubit Tests', () {
    test('initial state is WeatherInitial', () {
      final cubit = WeatherCubit(
        getWeatherByGpsUseCase: mockGetGps,
        getWeatherByCityUseCase: mockGetCity,
        getCachedWeatherUseCase: mockGetCached,
        toggleFavoriteCityUseCase: mockToggleFav,
        getTemperatureUnitUseCase: mockGetUnit,
        setTemperatureUnitUseCase: mockSetUnit,
      );

      expect(cubit.state, equals(const WeatherInitial()));
      expect(cubit.currentUnit, equals(ApiConstants.unitCelsius));
    });

    blocTest<WeatherCubit, WeatherState>(
      'loads initial GPS weather successfully',
      setUp: () {
        when(() => mockGetGps(unit: any(named: 'unit')))
            .thenAnswer((_) async => testDashboard);
      },
      build: () => WeatherCubit(
        getWeatherByGpsUseCase: mockGetGps,
        getWeatherByCityUseCase: mockGetCity,
        getCachedWeatherUseCase: mockGetCached,
        toggleFavoriteCityUseCase: mockToggleFav,
        getTemperatureUnitUseCase: mockGetUnit,
        setTemperatureUnitUseCase: mockSetUnit,
      ),
      act: (cubit) => cubit.loadInitialWeather(),
      expect: () => [
        const WeatherLoading(),
        WeatherLoaded(
          dashboard: testDashboard,
          temperatureUnit: ApiConstants.unitCelsius,
          isFavorite: false,
          isOfflineCached: false,
        ),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'emits WeatherError when GPS fetch fails and no cache exists',
      setUp: () {
        when(() => mockGetGps(unit: any(named: 'unit')))
            .thenThrow(Exception('Server unreachable'));
        when(() => mockGetCached()).thenAnswer((_) async => null);
      },
      build: () => WeatherCubit(
        getWeatherByGpsUseCase: mockGetGps,
        getWeatherByCityUseCase: mockGetCity,
        getCachedWeatherUseCase: mockGetCached,
        toggleFavoriteCityUseCase: mockToggleFav,
        getTemperatureUnitUseCase: mockGetUnit,
        setTemperatureUnitUseCase: mockSetUnit,
      ),
      act: (cubit) => cubit.loadInitialWeather(),
      expect: () => [
        const WeatherLoading(),
        const WeatherError(
          message: 'Server unreachable',
          cachedDashboard: null,
        ),
      ],
    );
  });
}
