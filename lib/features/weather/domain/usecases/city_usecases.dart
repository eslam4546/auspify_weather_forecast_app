import '../entities/city_location_entity.dart';
import '../repositories/weather_repository.dart';

class SearchCitiesUseCase {
  final WeatherRepository repository;

  const SearchCitiesUseCase(this.repository);

  Future<List<CityLocationEntity>> call(String query) {
    return repository.searchCities(query);
  }
}

class GetFavoriteCitiesUseCase {
  final WeatherRepository repository;

  const GetFavoriteCitiesUseCase(this.repository);

  Future<List<CityLocationEntity>> call() {
    return repository.getFavoriteCities();
  }
}

class ToggleFavoriteCityUseCase {
  final WeatherRepository repository;

  const ToggleFavoriteCityUseCase(this.repository);

  Future<void> call(CityLocationEntity city) {
    return repository.toggleFavoriteCity(city);
  }
}

class RemoveFavoriteCityUseCase {
  final WeatherRepository repository;

  const RemoveFavoriteCityUseCase(this.repository);

  Future<void> call(int cityId) {
    return repository.removeFavoriteCity(cityId);
  }
}
