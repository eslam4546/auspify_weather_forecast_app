import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/wmo_weather_mapper.dart';
import '../../domain/entities/weather_entities.dart';

class HourlyForecastRibbon extends StatelessWidget {
  final List<HourlyForecastEntity> hourlyList;
  final String unitSymbol;

  const HourlyForecastRibbon({
    super.key,
    required this.hourlyList,
    required this.unitSymbol,
  });

  String _formatHour(String timeString, int index) {
    if (index == 0) return 'Now';
    try {
      final dateTime = DateTime.parse(timeString);
      return DateFormat.j().format(dateTime); // e.g. "1 PM"
    } catch (_) {
      // Fallback: extract HH from "YYYY-MM-DDTHH:MM"
      if (timeString.contains('T')) {
        return timeString.split('T').last.substring(0, 5);
      }
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hourlyList.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkOnSurface
        : AppColors.lightOnSurface;
    final textSecondary = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 18,
                    color: AppColors.primarySkyBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Forecast",
                    style: AppTheme.headlineSm.copyWith(color: textPrimary),
                  ),
                ],
              ),
              Text(
                '24 HOURS',
                style: AppTheme.telemetryMono.copyWith(color: textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Horizontal Scrollable Timeline Ribbon
        SizedBox(
          height: 134,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: hourlyList.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = hourlyList[index];
              final isNow = index == 0;
              final hourLabel = _formatHour(item.time, index);
              final icon = WmoWeatherMapper.getIcon(item.weatherCode);

              return Container(
                width: 66,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(33),
                  color: isNow
                      ? AppColors.primarySkyBlue.withValues(
                          alpha: isDark ? 0.20 : 0.15,
                        )
                      : (isDark
                            ? AppColors.darkSurfaceContainer
                            : AppColors.lightSurfaceContainer),
                  border: Border.all(
                    color: isNow
                        ? AppColors.primarySkyBlue
                        : (isDark
                              ? AppColors.glassBorderDark
                              : AppColors.glassBorderLight),
                    width: isNow ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.15 : 0.04,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Hour label
                    Text(
                      hourLabel,
                      style: AppTheme.labelMd.copyWith(
                        color: isNow ? AppColors.primarySkyBlue : textSecondary,
                        fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),

                    // Weather Icon
                    Icon(
                      icon,
                      size: 24,
                      color: isNow
                          ? AppColors.secondaryWarmGold
                          : (item.weatherCode >= 51 && item.weatherCode <= 82
                                ? AppColors.primarySkyBlue
                                : AppColors.secondaryWarmGold),
                    ),

                    // Precipitation Probability Pill (if > 0%)
                    if (item.precipitationProbability > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySkyBlue.withValues(
                            alpha: 0.18,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.precipitationProbability}%',
                          style: AppTheme.telemetryMono.copyWith(
                            fontSize: 9,
                            color: AppColors.primarySkyBlue,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 14),

                    // Temperature
                    Text(
                      '${item.temperature.round()}°',
                      style: AppTheme.titleMd.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
