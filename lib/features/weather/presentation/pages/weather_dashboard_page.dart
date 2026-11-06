import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubits/theme_cubit.dart';
import '../cubits/weather_cubit.dart';
import '../cubits/weather_state.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/hourly_forecast_ribbon.dart';
import '../widgets/telemetry_grid.dart';
import '../widgets/weather_error_view.dart';
import '../widgets/weather_hero_card.dart';
import '../widgets/weather_shimmer_view.dart';
import 'city_search_page.dart';

class WeatherDashboardPage extends StatefulWidget {
  const WeatherDashboardPage({super.key});

  @override
  State<WeatherDashboardPage> createState() => _WeatherDashboardPageState();
}

class _WeatherDashboardPageState extends State<WeatherDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherCubit>().loadInitialWeather();
    });
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
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.cloud_outlined,
                  size: 22,
                  color: AppColors.primarySkyBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Aether Forecast',
                  style: AppTheme.headlineSm.copyWith(color: textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'LIVE RADAR ACTIVE',
              style: AppTheme.telemetryMono.copyWith(
                color: AppColors.primarySkyBlue,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          // Search Icon
          IconButton(
            tooltip: 'Search Cities',
            icon: const Icon(Icons.search_rounded, size: 24),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CitySearchPage()),
              );
            },
          ),
          // Theme Switcher Button
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 22,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<WeatherCubit, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading && state.previousDashboard == null) {
            return const WeatherShimmerView();
          }

          if (state is WeatherError) {
            return WeatherErrorView(
              message: state.message,
              hasCachedData: state.cachedDashboard != null,
              onRetry: () => context.read<WeatherCubit>().refreshWeather(),
              onUseCached: () => context.read<WeatherCubit>().useCachedData(),
            );
          }

          if (state is WeatherLoaded ||
              (state is WeatherLoading && state.previousDashboard != null)) {
            final dashboard = state is WeatherLoaded
                ? state.dashboard
                : (state as WeatherLoading).previousDashboard!;
            final currentUnit = state is WeatherLoaded
                ? state.temperatureUnit
                : context.read<WeatherCubit>().currentUnit;
            final isFavorite = state is WeatherLoaded
                ? state.isFavorite
                : false;
            final isOffline = state is WeatherLoaded
                ? state.isOfflineCached
                : false;

            final unitSymbol = currentUnit == ApiConstants.unitFahrenheit
                ? ApiConstants.unitSymbolFahrenheit
                : ApiConstants.unitSymbolCelsius;

            return RefreshIndicator(
              onRefresh: () => context.read<WeatherCubit>().refreshWeather(),
              color: AppColors.primarySkyBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Offline / Cached Warning Banner
                    if (isOffline) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceContainerHighest
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.secondaryWarmGold.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.cloud_sync_outlined,
                                  size: 20,
                                  color: AppColors.secondaryWarmGold,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Offline Mode Active',
                                      style: AppTheme.labelMd.copyWith(
                                        color: textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Cached telemetry displayed',
                                      style: AppTheme.telemetryMono.copyWith(
                                        color: textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  context.read<WeatherCubit>().refreshWeather(),
                              icon: const Icon(
                                Icons.refresh,
                                size: 16,
                                color: AppColors.primarySkyBlue,
                              ),
                              label: const Text(
                                'Retry',
                                style: TextStyle(
                                  color: AppColors.primarySkyBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Subheader: Location Name, GPS Indicator, Favorite & Unit Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Location Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: AppColors.primarySkyBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      dashboard.location.name,
                                      style: AppTheme.headlineSm.copyWith(
                                        color: textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primarySkyBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    dashboard.location.country.isNotEmpty
                                        ? '${dashboard.location.country} • GPS Live'
                                        : 'GPS Active • High Precision',
                                    style: AppTheme.telemetryMono.copyWith(
                                      color: AppColors.primarySkyBlue,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action Cluster: Bookmark Star & °C/°F Pill Toggle
                        Row(
                          children: [
                            // Bookmark Star Button
                            IconButton(
                              tooltip: isFavorite
                                  ? 'Remove Favorite'
                                  : 'Save Favorite',
                              icon: Icon(
                                isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 24,
                                color: isFavorite
                                    ? AppColors.secondaryWarmGold
                                    : textSecondary,
                              ),
                              onPressed: () {
                                context.read<WeatherCubit>().toggleFavorite();
                              },
                            ),

                            // °C / °F Unit Pill Toggle
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurfaceContainer
                                    : AppColors.lightSurfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildUnitButton(
                                    label: '°C',
                                    isSelected:
                                        currentUnit == ApiConstants.unitCelsius,
                                    onTap: () {
                                      if (currentUnit !=
                                          ApiConstants.unitCelsius) {
                                        context
                                            .read<WeatherCubit>()
                                            .toggleTemperatureUnit();
                                      }
                                    },
                                  ),
                                  _buildUnitButton(
                                    label: '°F',
                                    isSelected:
                                        currentUnit ==
                                        ApiConstants.unitFahrenheit,
                                    onTap: () {
                                      if (currentUnit !=
                                          ApiConstants.unitFahrenheit) {
                                        context
                                            .read<WeatherCubit>()
                                            .toggleTemperatureUnit();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 1. Hero Weather Card
                    WeatherHeroCard(
                      current: dashboard.current,
                      todayForecast: dashboard.daily.isNotEmpty
                          ? dashboard.daily.first
                          : null,
                      unitSymbol: unitSymbol,
                    ),
                    const SizedBox(height: 20),

                    // 2. 24-Hour Hourly Timeline
                    HourlyForecastRibbon(
                      hourlyList: dashboard.hourly,
                      unitSymbol: unitSymbol,
                    ),
                    const SizedBox(height: 20),

                    // 3. Atmospheric Telemetry 2x3 Grid
                    TelemetryGrid(
                      current: dashboard.current,
                      unitSymbol: unitSymbol,
                    ),
                    const SizedBox(height: 20),

                    // 4. 7-Day Extended Forecast List
                    DailyForecastList(
                      dailyList: dashboard.daily,
                      unitSymbol: unitSymbol,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          return const WeatherShimmerView();
        },
      ),
    );
  }

  Widget _buildUnitButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySkyBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
