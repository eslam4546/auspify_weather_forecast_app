import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/city_location_entity.dart';
import '../../domain/usecases/city_usecases.dart';
import 'city_search_state.dart';

class CitySearchCubit extends Cubit<CitySearchState> {
  final SearchCitiesUseCase searchCitiesUseCase;
  final GetFavoriteCitiesUseCase getFavoriteCitiesUseCase;
  final ToggleFavoriteCityUseCase toggleFavoriteCityUseCase;
  final RemoveFavoriteCityUseCase removeFavoriteCityUseCase;

  Timer? _debounceTimer;

  CitySearchCubit({
    required this.searchCitiesUseCase,
    required this.getFavoriteCitiesUseCase,
    required this.toggleFavoriteCityUseCase,
    required this.removeFavoriteCityUseCase,
  }) : super(const CitySearchInitial()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final favorites = await getFavoriteCitiesUseCase();
      if (state is CitySearchLoaded) {
        final current = state as CitySearchLoaded;
        emit(current.copyWith(favoriteCities: favorites));
      } else {
        emit(
          CitySearchInitial(
            favoriteCities: favorites,
            isEditingMode: state.isEditingMode,
          ),
        );
      }
    } catch (_) {
      // Keep existing state if favorites fetch fails
    }
  }

  void onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    if (trimmed.length < 2) {
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      searchCities(trimmed);
    });
  }

  Future<void> searchCities(String query) async {
    emit(
      CitySearchLoading(
        favoriteCities: state.favoriteCities,
        isEditingMode: state.isEditingMode,
      ),
    );

    try {
      final results = await searchCitiesUseCase(query);
      emit(
        CitySearchLoaded(
          searchResults: results,
          query: query,
          favoriteCities: state.favoriteCities,
          isEditingMode: state.isEditingMode,
        ),
      );
    } catch (e) {
      emit(
        CitySearchError(
          message: e.toString().replaceFirst('Exception: ', ''),
          favoriteCities: state.favoriteCities,
          isEditingMode: state.isEditingMode,
        ),
      );
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    emit(
      CitySearchInitial(
        favoriteCities: state.favoriteCities,
        isEditingMode: state.isEditingMode,
      ),
    );
  }

  Future<void> toggleFavoriteCity(CityLocationEntity city) async {
    try {
      await toggleFavoriteCityUseCase(city);
      final updatedFavorites = await getFavoriteCitiesUseCase();

      if (state is CitySearchLoaded) {
        final current = state as CitySearchLoaded;
        final updatedResults = current.searchResults.map((c) {
          if (c.id == city.id) {
            return c.copyWith(isFavorite: !c.isFavorite);
          }
          return c;
        }).toList();

        emit(
          current.copyWith(
            searchResults: updatedResults,
            favoriteCities: updatedFavorites,
          ),
        );
      } else {
        emit(
          CitySearchInitial(
            favoriteCities: updatedFavorites,
            isEditingMode: state.isEditingMode,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> deleteFavoriteCity(int cityId) async {
    try {
      await removeFavoriteCityUseCase(cityId);
      final updatedFavorites = await getFavoriteCitiesUseCase();

      if (state is CitySearchLoaded) {
        final current = state as CitySearchLoaded;
        final updatedResults = current.searchResults.map((c) {
          if (c.id == cityId) {
            return c.copyWith(isFavorite: false);
          }
          return c;
        }).toList();

        emit(
          current.copyWith(
            searchResults: updatedResults,
            favoriteCities: updatedFavorites,
          ),
        );
      } else {
        emit(
          CitySearchInitial(
            favoriteCities: updatedFavorites,
            isEditingMode: state.isEditingMode,
          ),
        );
      }
    } catch (_) {}
  }

  void toggleEditMode() {
    final newMode = !state.isEditingMode;
    if (state is CitySearchLoaded) {
      final current = state as CitySearchLoaded;
      emit(current.copyWith(isEditingMode: newMode));
    } else if (state is CitySearchInitial) {
      emit(
        CitySearchInitial(
          favoriteCities: state.favoriteCities,
          isEditingMode: newMode,
        ),
      );
    } else if (state is CitySearchError) {
      final current = state as CitySearchError;
      emit(
        CitySearchError(
          message: current.message,
          favoriteCities: state.favoriteCities,
          isEditingMode: newMode,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
