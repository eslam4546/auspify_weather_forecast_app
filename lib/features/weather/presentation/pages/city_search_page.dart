import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/city_location_entity.dart';
import '../cubits/city_search_cubit.dart';
import '../cubits/city_search_state.dart';
import '../cubits/weather_cubit.dart';

class CitySearchPage extends StatefulWidget {
  const CitySearchPage({super.key});

  @override
  State<CitySearchPage> createState() => _CitySearchPageState();
}

class _CitySearchPageState extends State<CitySearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CitySearchCubit>().loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkOnSurface
        : AppColors.lightOnSurface;
    final textSecondary = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search & Cities',
              style: AppTheme.headlineSm.copyWith(color: textPrimary),
            ),
            Text(
              'LIVE RADAR READY',
              style: AppTheme.telemetryMono.copyWith(
                color: AppColors.primarySkyBlue,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<CitySearchCubit, CitySearchState>(
        builder: (context, state) {
          final isEditing = state.isEditingMode;
          final favoriteCities = state.favoriteCities;
          final isSearching =
              state is CitySearchLoading ||
              (state is CitySearchLoaded && state.query.isNotEmpty);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search Bar & Clear/Cancel Actions
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceContainer
                              : AppColors.lightSurfaceContainerHighest,
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: isDark
                                ? AppColors.glassBorderDark
                                : AppColors.glassBorderLight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.primarySkyBlue,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: false,
                                style: AppTheme.bodyLg.copyWith(
                                  color: textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search city, region or country...',
                                  hintStyle: AppTheme.bodyMd.copyWith(
                                    color: textSecondary.withValues(alpha: 0.7),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (val) {
                                  context
                                      .read<CitySearchCubit>()
                                      .onSearchQueryChanged(val);
                                },
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel_rounded,
                                  size: 18,
                                ),
                                color: textSecondary,
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<CitySearchCubit>().clearSearch();
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          context.read<CitySearchCubit>().clearSearch();
                          FocusScope.of(context).unfocus();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.primarySkyBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // 2. GPS "Detect My Location" Action Chip
                GestureDetector(
                  onTap: () {
                    context.read<WeatherCubit>().fetchWeatherForCurrentGps();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySkyBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primarySkyBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.my_location_rounded,
                          size: 16,
                          color: AppColors.primarySkyBlue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Detect My Location',
                          style: TextStyle(
                            color: AppColors.primarySkyBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Search Results Feed (if searching)
                if (state is CitySearchLoading) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primarySkyBlue,
                      ),
                    ),
                  ),
                ] else if (state is CitySearchLoaded &&
                    state.query.isNotEmpty) ...[
                  _buildSearchResultsSection(
                    context,
                    results: state.searchResults,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 24),
                ] else if (state is CitySearchError) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      state.message,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 4. Saved / Favorite Cities Section (Bento Cards)
                if (!isSearching ||
                    (state is CitySearchLoaded &&
                        state.searchResults.isEmpty)) ...[
                  _buildFavoritesSection(
                    context,
                    favorites: favoriteCities,
                    isEditing: isEditing,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResultsSection(
    BuildContext context, {
    required List<CityLocationEntity> results,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: textSecondary),
            const SizedBox(height: 12),
            Text(
              'No cities found',
              style: AppTheme.headlineSm.copyWith(color: textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Try checking for spelling or searching for another region.',
              style: AppTheme.bodyMd.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SEARCH MATCHES (${results.length})',
              style: AppTheme.telemetryMono.copyWith(color: textSecondary),
            ),
            Text(
              'TAP TO VIEW',
              style: AppTheme.telemetryMono.copyWith(
                color: AppColors.primarySkyBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceContainer
                : AppColors.lightSurfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.glassBorderDark
                  : AppColors.glassBorderLight,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 0.5,
              indent: 56,
              color: Color(0x14888888),
            ),
            itemBuilder: (context, index) {
              final city = results[index];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primarySkyBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.primarySkyBlue,
                  ),
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        city.name,
                        style: AppTheme.titleMd.copyWith(color: textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (city.country.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceContainerHighest
                              : AppColors.lightSurfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          city.country.length > 3
                              ? city.country.substring(0, 2).toUpperCase()
                              : city.country,
                          style: AppTheme.telemetryMono.copyWith(
                            fontSize: 9,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  city.admin1 != null && city.admin1!.isNotEmpty
                      ? '${city.admin1}, ${city.country}'
                      : city.country,
                  style: AppTheme.bodyMd.copyWith(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Favorite Toggle Star
                    IconButton(
                      icon: Icon(
                        city.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: city.isFavorite
                            ? AppColors.secondaryWarmGold
                            : textSecondary,
                        size: 22,
                      ),
                      onPressed: () {
                        context.read<CitySearchCubit>().toggleFavoriteCity(
                          city,
                        );
                      },
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF888888),
                      size: 20,
                    ),
                  ],
                ),
                onTap: () {
                  context.read<WeatherCubit>().fetchWeatherForCity(city);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection(
    BuildContext context, {
    required List<CityLocationEntity> favorites,
    required bool isEditing,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Favorite Cities',
                  style: AppTheme.headlineSm.copyWith(color: textPrimary),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceContainerHighest
                        : AppColors.lightSurfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${favorites.length} Saved',
                    style: AppTheme.telemetryMono.copyWith(
                      color: AppColors.primarySkyBlue,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            if (favorites.isNotEmpty)
              TextButton(
                onPressed: () {
                  context.read<CitySearchCubit>().toggleEditMode();
                },
                child: Text(
                  isEditing ? 'Done' : 'Edit',
                  style: TextStyle(
                    color: isEditing
                        ? AppColors.secondaryWarmGold
                        : AppColors.primarySkyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (favorites.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceContainer
                  : AppColors.lightSurfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.glassBorderDark
                    : AppColors.glassBorderLight,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.star_outline_rounded,
                  size: 36,
                  color: AppColors.secondaryWarmGold,
                ),
                const SizedBox(height: 8),
                Text(
                  'No Saved Cities',
                  style: AppTheme.titleMd.copyWith(color: textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Search for a city above and tap the star icon to bookmark it for quick access.',
                  style: AppTheme.bodyMd.copyWith(color: textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else ...[
          // Bento Stack of Saved City Cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favorites.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final city = favorites[index];

              return GestureDetector(
                onTap: isEditing
                    ? null
                    : () {
                        context.read<WeatherCubit>().fetchWeatherForCity(city);
                        Navigator.of(context).pop();
                      },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [Color(0xFF162744), Color(0xFF0D1A2D)]
                          : const [Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: isDark
                          ? AppColors.glassBorderDark
                          : AppColors.glassBorderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // City metadata
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: AppColors.primarySkyBlue,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    city.name,
                                    style: AppTheme.headlineSm.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              city.country.isNotEmpty
                                  ? city.country
                                  : 'Saved City',
                              style: AppTheme.bodyMd.copyWith(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Actions: Delete button (if editing) or Chevron
                      if (isEditing) ...[
                        IconButton(
                          tooltip: 'Delete ${city.name}',
                          icon: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                          ),
                          onPressed: () {
                            context.read<CitySearchCubit>().deleteFavoriteCity(
                              city.id,
                            );
                          },
                        ),
                      ] else ...[
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.primarySkyBlue,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
