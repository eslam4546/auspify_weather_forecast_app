import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/wmo_weather_mapper.dart';
import '../../domain/entities/weather_entities.dart';

class DailyForecastList extends StatelessWidget {
  final List<DailyForecastEntity> dailyList;
  final String unitSymbol;

  const DailyForecastList({
    super.key,
    required this.dailyList,
    required this.unitSymbol,
  });

  String _formatDay(String dateString, int index) {
    if (index == 0) return 'Today';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat.E().format(date); // e.g. "Thu", "Fri"
    } catch (_) {
      return 'Day $index';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dailyList.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? AppColors.darkSurfaceContainer
        : AppColors.lightSurfaceContainer;
    final cardBorder = isDark
        ? AppColors.glassBorderDark
        : AppColors.glassBorderLight;
    final textPrimary = isDark
        ? AppColors.darkOnSurface
        : AppColors.lightOnSurface;
    final textSecondary = isDark
        ? AppColors.darkOnSurfaceVariant
        : AppColors.lightOnSurfaceVariant;

    // Compute week-wide minimum and maximum to normalize range bars
    double weekMin = dailyList.first.minTemperature;
    double weekMax = dailyList.first.maxTemperature;
    for (final day in dailyList) {
      if (day.minTemperature < weekMin) weekMin = day.minTemperature;
      if (day.maxTemperature > weekMax) weekMax = day.maxTemperature;
    }
    final double totalRange = (weekMax - weekMin) <= 0
        ? 1.0
        : (weekMax - weekMin);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: AppColors.primarySkyBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '7-Day Forecast',
                    style: AppTheme.headlineSm.copyWith(color: textPrimary),
                  ),
                ],
              ),
              Text(
                'EXTENDED HORIZON',
                style: AppTheme.telemetryMono.copyWith(color: textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Daily Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyList.length,
            separatorBuilder: (context, index) => const Divider(
              height: 18,
              thickness: 0.5,
              color: Color(0x14888888),
            ),
            itemBuilder: (context, index) {
              final day = dailyList[index];
              final dayName = _formatDay(day.date, index);
              final isToday = index == 0;
              final icon = WmoWeatherMapper.getIcon(day.weatherCode);

              // Relative fractions for horizontal temperature range bar
              final double startFraction =
                  ((day.minTemperature - weekMin) / totalRange).clamp(
                    0.0,
                    0.85,
                  );
              final double widthFraction =
                  ((day.maxTemperature - day.minTemperature) / totalRange)
                      .clamp(0.12, 1.0 - startFraction);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    // Day of Week
                    SizedBox(
                      width: 58,
                      child: Text(
                        dayName,
                        style: AppTheme.bodyMd.copyWith(
                          color: isToday
                              ? AppColors.primarySkyBlue
                              : textPrimary,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),

                    // Weather Icon & Rain %
                    SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 20,
                            color: day.precipitationProbabilityMax > 30
                                ? AppColors.primarySkyBlue
                                : AppColors.secondaryWarmGold,
                          ),
                          const SizedBox(width: 4),
                          if (day.precipitationProbabilityMax > 0)
                            Text(
                              '${day.precipitationProbabilityMax}%',
                              style: AppTheme.telemetryMono.copyWith(
                                fontSize: 10,
                                color: day.precipitationProbabilityMax > 40
                                    ? AppColors.primarySkyBlue
                                    : textSecondary,
                                fontWeight: day.precipitationProbabilityMax > 40
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Min Temp
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${day.minTemperature.round()}°',
                        textAlign: TextAlign.right,
                        style: AppTheme.labelMd.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Dynamic Horizontal Temperature Range Bar
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final barTotalWidth = constraints.maxWidth;
                          final leftOffset = barTotalWidth * startFraction;
                          final segmentWidth = barTotalWidth * widthFraction;

                          return Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurfaceContainerHighest
                                  : AppColors.lightSurfaceContainerHighest,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: leftOffset,
                                  width: segmentWidth,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primarySkyBlue,
                                          AppColors.secondaryWarmGold,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Max Temp
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${day.maxTemperature.round()}°',
                        textAlign: TextAlign.left,
                        style: AppTheme.labelMd.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
