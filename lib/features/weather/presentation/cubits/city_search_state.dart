import 'package:equatable/equatable.dart';

import '../../domain/entities/city_location_entity.dart';

abstract class CitySearchState extends Equatable {
  final List<CityLocationEntity> favoriteCities;
  final bool isEditingMode;

  const CitySearchState({
    this.favoriteCities = const [],
    this.isEditingMode = false,
  });

  @override
  List<Object?> get props => [favoriteCities, isEditingMode];
}

class CitySearchInitial extends CitySearchState {
  const CitySearchInitial({
    super.favoriteCities = const [],
    super.isEditingMode = false,
  });
}

class CitySearchLoading extends CitySearchState {
  const CitySearchLoading({
    super.favoriteCities = const [],
    super.isEditingMode = false,
  });
}

class CitySearchLoaded extends CitySearchState {
  final List<CityLocationEntity> searchResults;
  final String query;

  const CitySearchLoaded({
    required this.searchResults,
    required this.query,
    super.favoriteCities = const [],
    super.isEditingMode = false,
  });

  CitySearchLoaded copyWith({
    List<CityLocationEntity>? searchResults,
    String? query,
    List<CityLocationEntity>? favoriteCities,
    bool? isEditingMode,
  }) {
    return CitySearchLoaded(
      searchResults: searchResults ?? this.searchResults,
      query: query ?? this.query,
      favoriteCities: favoriteCities ?? this.favoriteCities,
      isEditingMode: isEditingMode ?? this.isEditingMode,
    );
  }

  @override
  List<Object?> get props => [
    searchResults,
    query,
    favoriteCities,
    isEditingMode,
  ];
}

class CitySearchError extends CitySearchState {
  final String message;

  const CitySearchError({
    required this.message,
    super.favoriteCities = const [],
    super.isEditingMode = false,
  });

  @override
  List<Object?> get props => [message, favoriteCities, isEditingMode];
}
