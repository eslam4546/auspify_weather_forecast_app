import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/api_constants.dart';
import 'features/weather/data/datasources/location_service.dart';
import 'features/weather/data/datasources/weather_local_data_source.dart';
import 'features/weather/data/datasources/weather_remote_data_source.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/domain/repositories/weather_repository.dart';
import 'features/weather/domain/usecases/city_usecases.dart';
import 'features/weather/domain/usecases/preference_usecases.dart';
import 'features/weather/domain/usecases/weather_usecases.dart';
import 'features/weather/presentation/cubits/city_search_cubit.dart';
import 'features/weather/presentation/cubits/theme_cubit.dart';
import 'features/weather/presentation/cubits/weather_cubit.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _singletons = {};
  final Map<Type, dynamic> _factories = {};

  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    if (_factories.containsKey(T)) {
      return (_factories[T] as T Function())();
    }
    throw StateError('Service of type $T is not registered in ServiceLocator.');
  }

  T call<T>() => get<T>();

  void reset() {
    _singletons.clear();
    _factories.clear();
  }
}

final sl = ServiceLocator();

Future<void> initDependencies() async {
  // 1. External & Platform Services
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  final dio = Dio(
    BaseOptions(
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Accept': 'application/json'},
    ),
  );
  sl.registerSingleton<Dio>(dio);

  // 2. Data Sources & Hardware Services
  sl.registerSingleton<LocationService>(LocationServiceImpl());

  sl.registerSingleton<WeatherRemoteDataSource>(
    WeatherRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerSingleton<WeatherLocalDataSource>(
    WeatherLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // 3. Repository
  sl.registerSingleton<WeatherRepository>(
    WeatherRepositoryImpl(
      remoteDataSource: sl<WeatherRemoteDataSource>(),
      localDataSource: sl<WeatherLocalDataSource>(),
      locationService: sl<LocationService>(),
    ),
  );

  // 4. Use Cases
  sl.registerSingleton<GetWeatherByGpsUseCase>(
    GetWeatherByGpsUseCase(sl<WeatherRepository>()),
  );
  sl.registerSingleton<GetWeatherByCityUseCase>(
    GetWeatherByCityUseCase(sl<WeatherRepository>()),
  );
  sl.registerSingleton<GetCachedWeatherUseCase>(
    GetCachedWeatherUseCase(sl<WeatherRepository>()),
  );

  sl.registerSingleton<SearchCitiesUseCase>(
    SearchCitiesUseCase(sl<WeatherRepository>()),
  );
  sl.registerSingleton<GetFavoriteCitiesUseCase>(
    GetFavoriteCitiesUseCase(sl<WeatherRepository>()),
  );
  sl.registerSingleton<ToggleFavoriteCityUseCase>(
    ToggleFavoriteCityUseCase(sl<WeatherRepository>()),
  );
  sl.registerSingleton<RemoveFavoriteCityUseCase>(
    RemoveFavoriteCityUseCase(sl<WeatherRepository>()),
  );

  sl.registerSingleton<GetTemperatureUnitUseCase>(
    GetTemperatureUnitUseCase(sl<WeatherRepository>()),
  );
  sl.registerSingleton<SetTemperatureUnitUseCase>(
    SetTemperatureUnitUseCase(sl<WeatherRepository>()),
  );
  sl.registerSingleton<GetThemeModeUseCase>(
    GetThemeModeUseCase(sl<WeatherRepository>()),
  );
  sl.registerSingleton<SetThemeModeUseCase>(
    SetThemeModeUseCase(sl<WeatherRepository>()),
  );

  // 5. Cubits (Factory registration for UI reactivity)
  sl.registerFactory<ThemeCubit>(
    () => ThemeCubit(
      getThemeModeUseCase: sl<GetThemeModeUseCase>(),
      setThemeModeUseCase: sl<SetThemeModeUseCase>(),
    ),
  );

  sl.registerFactory<WeatherCubit>(
    () => WeatherCubit(
      getWeatherByGpsUseCase: sl<GetWeatherByGpsUseCase>(),
      getWeatherByCityUseCase: sl<GetWeatherByCityUseCase>(),
      getCachedWeatherUseCase: sl<GetCachedWeatherUseCase>(),
      toggleFavoriteCityUseCase: sl<ToggleFavoriteCityUseCase>(),
      getTemperatureUnitUseCase: sl<GetTemperatureUnitUseCase>(),
      setTemperatureUnitUseCase: sl<SetTemperatureUnitUseCase>(),
    ),
  );

  sl.registerFactory<CitySearchCubit>(
    () => CitySearchCubit(
      searchCitiesUseCase: sl<SearchCitiesUseCase>(),
      getFavoriteCitiesUseCase: sl<GetFavoriteCitiesUseCase>(),
      toggleFavoriteCityUseCase: sl<ToggleFavoriteCityUseCase>(),
      removeFavoriteCityUseCase: sl<RemoveFavoriteCityUseCase>(),
    ),
  );
}
