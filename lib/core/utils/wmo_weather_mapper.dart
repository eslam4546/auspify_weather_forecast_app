import 'package:flutter/material.dart';

/// Maps Open-Meteo WMO integer weather interpretation codes (0 - 99)
/// to human-readable condition descriptions and Material Icons.
class WmoWeatherMapper {
  static String getDescription(int? code) {
    if (code == null) return 'Unknown Weather';

    switch (code) {
      case 0:
        return 'Clear Sky';
      case 1:
        return 'Mainly Clear';
      case 2:
        return 'Partly Cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Fog';
      case 48:
        return 'Depositing Rime Fog';
      case 51:
        return 'Light Drizzle';
      case 53:
        return 'Moderate Drizzle';
      case 55:
        return 'Dense Drizzle';
      case 56:
        return 'Light Freezing Drizzle';
      case 57:
        return 'Dense Freezing Drizzle';
      case 61:
        return 'Slight Rain';
      case 63:
        return 'Moderate Rain';
      case 65:
        return 'Heavy Rain';
      case 66:
        return 'Light Freezing Rain';
      case 67:
        return 'Heavy Freezing Rain';
      case 71:
        return 'Slight Snow';
      case 73:
        return 'Moderate Snow';
      case 75:
        return 'Heavy Snow';
      case 77:
        return 'Snow Grains';
      case 80:
        return 'Slight Rain Showers';
      case 81:
        return 'Moderate Rain Showers';
      case 82:
        return 'Violent Rain Showers';
      case 85:
        return 'Slight Snow Showers';
      case 86:
        return 'Heavy Snow Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
        return 'Thunderstorm with Slight Hail';
      case 99:
        return 'Thunderstorm with Heavy Hail';
      default:
        return 'Variably Cloudy';
    }
  }

  static IconData getIcon(int? code, {bool isDay = true}) {
    if (code == null) return Icons.help_outline;

    switch (code) {
      case 0:
        return isDay ? Icons.wb_sunny : Icons.nightlight_round;
      case 1:
        return isDay ? Icons.wb_sunny_outlined : Icons.nightlight_outlined;
      case 2:
        return isDay ? Icons.cloud_queue : Icons.nights_stay;
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.blur_on;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain;
      case 61:
      case 63:
      case 80:
      case 81:
        return Icons.water_drop;
      case 65:
      case 66:
      case 67:
      case 82:
        return Icons.umbrella;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm;
      default:
        return Icons.wb_cloudy;
    }
  }
}
