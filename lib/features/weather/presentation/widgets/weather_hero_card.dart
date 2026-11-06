import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/wmo_weather_mapper.dart';
import '../../domain/entities/weather_entities.dart';

class WeatherHeroCard extends StatelessWidget {
  final CurrentWeatherEntity current;
  final DailyForecastEntity? todayForecast;
  final String unitSymbol;

  const WeatherHeroCard({
    super.key,
    required this.current,
    this.todayForecast,
    required this.unitSymbol,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conditionTitle = WmoWeatherMapper.getDescription(current.weatherCode);
    final conditionIcon = WmoWeatherMapper.getIcon(
      current.weatherCode,
      isDay: current.isDay,
    );

    final highTemp = todayForecast != null
        ? '${todayForecast!.maxTemperature.round()}°'
        : '--';
    final lowTemp = todayForecast != null
        ? '${todayForecast!.minTemperature.round()}°'
        : '--';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkSurfaceContainerHigh,
                  AppColors.darkSurfaceContainer,
                  AppColors.darkSurfaceContainerLow,
                ]
              : [
                  Colors.white,
                  const Color(0xFFF1F5F9),
                  const Color(0xFFE2E8F0),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark
              ? AppColors.glassBorderDark
              : AppColors.glassBorderLight,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Ambient Glow Effect (Top-Right)
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySkyBlue.withValues(alpha: 0.12),
              ),
            ),
          ),
          // Ambient Glow Effect (Bottom-Left)
          Positioned(
            left: -16,
            bottom: -16,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryWarmGold.withValues(alpha: 0.10),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Label
                Text(
                  'ATMOSPHERIC OVERVIEW',
                  style: AppTheme.telemetryMono.copyWith(
                    color: isDark
                        ? AppColors.darkOnSurfaceVariant
                        : AppColors.lightOnSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),

                // Temperature and Weather Icon Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Large Hero Temperature
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${current.temperature.round()}',
                          style: AppTheme.displayHeroMobile.copyWith(
                            color: isDark
                                ? AppColors.darkOnSurface
                                : AppColors.lightOnSurface,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            unitSymbol,
                            style: AppTheme.headlineMd.copyWith(
                              color: AppColors.primarySkyBlue,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Weather Icon with Ambient Halo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondaryWarmGold.withValues(
                              alpha: 0.15,
                            ),
                          ),
                          child: Icon(
                            conditionIcon,
                            size: 38,
                            color: AppColors.secondaryWarmGold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          conditionTitle,
                          style: AppTheme.labelMd.copyWith(
                            color: AppColors.primarySkyBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // High/Low and "Updated" Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // High / Low temperatures
                    Row(
                      children: [
                        const Text(
                          '↑ ',
                          style: TextStyle(
                            color: AppColors.secondaryWarmGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          highTemp,
                          style: AppTheme.bodyMd.copyWith(
                            color: isDark
                                ? AppColors.darkOnSurface
                                : AppColors.lightOnSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkOutlineVariant
                                  : AppColors.lightOutlineVariant,
                            ),
                          ),
                        ),
                        const Text(
                          '↓ ',
                          style: TextStyle(
                            color: AppColors.primarySkyBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          lowTemp,
                          style: AppTheme.bodyMd.copyWith(
                            color: isDark
                                ? AppColors.darkOnSurface
                                : AppColors.lightOnSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Updated Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AppColors.darkSurfaceContainerHighest
                                    : AppColors.lightSurfaceContainerHighest)
                                .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                            'Live Data',
                            style: AppTheme.telemetryMono.copyWith(
                              color: isDark
                                  ? AppColors.darkOnSurfaceVariant
                                  : AppColors.lightOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
