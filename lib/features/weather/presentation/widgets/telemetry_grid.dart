import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/weather_entities.dart';

class TelemetryGrid extends StatelessWidget {
  final CurrentWeatherEntity current;
  final String unitSymbol;

  const TelemetryGrid({
    super.key,
    required this.current,
    required this.unitSymbol,
  });

  String _getUvCategory(double uv) {
    if (uv <= 2) return 'Low';
    if (uv <= 5) return 'Moderate';
    if (uv <= 7) return 'High';
    if (uv <= 10) return 'Very High';
    return 'Extreme';
  }

  Color _getUvColor(double uv) {
    if (uv <= 2) return Colors.greenAccent;
    if (uv <= 5) return AppColors.secondaryWarmGold;
    if (uv <= 7) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Atmospheric Telemetry',
                style: AppTheme.headlineSm.copyWith(color: textPrimary),
              ),
              Text(
                'SENSORS LIVE',
                style: AppTheme.telemetryMono.copyWith(color: textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // 2-Column Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            // 1. Humidity Card
            _buildTelemetryCard(
              cardBg: cardBg,
              cardBorder: cardBorder,
              title: 'HUMIDITY',
              icon: Icons.water_drop_outlined,
              iconColor: AppColors.primarySkyBlue,
              valueWidget: Text(
                '${current.humidity}%',
                style: AppTheme.headlineMd.copyWith(color: textPrimary),
              ),
              extraWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (current.humidity / 100).clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: isDark
                          ? AppColors.darkSurfaceContainerHighest
                          : AppColors.lightSurfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primarySkyBlue,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: current.humidity > 70
                  ? 'High humidity'
                  : current.humidity < 30
                  ? 'Dry air'
                  : 'Comfortable humidity',
              textSecondary: textSecondary,
            ),

            // 2. Wind Velocity Card
            _buildTelemetryCard(
              cardBg: cardBg,
              cardBorder: cardBorder,
              title: 'WIND VELOCITY',
              icon: Icons.air,
              iconColor: AppColors.primarySkyBlue,
              valueWidget: Row(
                children: [
                  Text(
                    '${current.windSpeed.round()}',
                    style: AppTheme.headlineMd.copyWith(color: textPrimary),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'km/h',
                    style: AppTheme.labelMd.copyWith(color: textSecondary),
                  ),
                ],
              ),
              subtitle: 'Surface wind gusts',
              textSecondary: textSecondary,
            ),

            // 3. Feels Like Card
            _buildTelemetryCard(
              cardBg: cardBg,
              cardBorder: cardBorder,
              title: 'FEELS LIKE',
              icon: Icons.thermostat_outlined,
              iconColor: AppColors.primarySkyBlue,
              valueWidget: Text(
                '${current.apparentTemperature.round()}$unitSymbol',
                style: AppTheme.headlineMd.copyWith(color: textPrimary),
              ),
              subtitle: 'Humidity & wind adjusted',
              textSecondary: textSecondary,
            ),

            // 4. UV Index Card
            _buildTelemetryCard(
              cardBg: cardBg,
              cardBorder: cardBorder,
              title: 'UV INDEX',
              icon: Icons.wb_sunny_outlined,
              iconColor: AppColors.secondaryWarmGold,
              valueWidget: Row(
                children: [
                  Text(
                    '${current.uvIndex.round()}',
                    style: AppTheme.headlineMd.copyWith(color: textPrimary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getUvColor(current.uvIndex)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getUvCategory(current.uvIndex),
                      style: AppTheme.labelMd.copyWith(
                        color: _getUvColor(current.uvIndex),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: current.uvIndex >= 6
                  ? 'Protection required'
                  : 'Low sun hazard',
              textSecondary: textSecondary,
            ),

            // 5. Pressure Card
            _buildTelemetryCard(
              cardBg: cardBg,
              cardBorder: cardBorder,
              title: 'PRESSURE',
              icon: Icons.speed,
              iconColor: AppColors.primarySkyBlue,
              valueWidget: Row(
                children: [
                  Text(
                    '${current.surfacePressure.round()}',
                    style: AppTheme.headlineMd.copyWith(color: textPrimary),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'hPa',
                    style: AppTheme.labelMd.copyWith(color: textSecondary),
                  ),
                ],
              ),
              subtitle: 'Atmospheric barometrics',
              textSecondary: textSecondary,
            ),

            // 6. Day / Night Cycle Card
            _buildTelemetryCard(
              cardBg: cardBg,
              cardBorder: cardBorder,
              title: 'SOLAR CYCLE',
              icon: current.isDay ? Icons.light_mode : Icons.dark_mode_outlined,
              iconColor: current.isDay
                  ? AppColors.secondaryWarmGold
                  : AppColors.tertiarySoftBlue,
              valueWidget: Text(
                current.isDay ? 'Daytime' : 'Nighttime',
                style: AppTheme.headlineMd.copyWith(
                  color: textPrimary,
                  fontSize: 19,
                ),
              ),
              subtitle: current.isDay
                  ? 'Sun is elevated'
                  : 'Celestial dark horizon',
              textSecondary: textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTelemetryCard({
    required Color cardBg,
    required Color cardBorder,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget valueWidget,
    Widget? extraWidget,
    required String subtitle,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Category & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.telemetryMono.copyWith(color: textSecondary),
              ),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),

          // Core Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [valueWidget, ?extraWidget],
          ),

          // Footer Subtitle
          Text(
            subtitle,
            style: AppTheme.bodyMd.copyWith(color: textSecondary, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
