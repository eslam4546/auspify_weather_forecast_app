import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast_app/core/utils/wmo_weather_mapper.dart';

void main() {
  group('WmoWeatherMapper Tests', () {
    test('should return correct description for known WMO codes', () {
      expect(WmoWeatherMapper.getDescription(0), equals('Clear Sky'));
      expect(WmoWeatherMapper.getDescription(1), equals('Mainly Clear'));
      expect(WmoWeatherMapper.getDescription(2), equals('Partly Cloudy'));
      expect(WmoWeatherMapper.getDescription(3), equals('Overcast'));
      expect(WmoWeatherMapper.getDescription(45), equals('Fog'));
      expect(WmoWeatherMapper.getDescription(61), equals('Slight Rain'));
      expect(WmoWeatherMapper.getDescription(63), equals('Moderate Rain'));
      expect(WmoWeatherMapper.getDescription(65), equals('Heavy Rain'));
      expect(WmoWeatherMapper.getDescription(71), equals('Slight Snow'));
      expect(WmoWeatherMapper.getDescription(95), equals('Thunderstorm'));
    });

    test('should return fallback description for null or unknown code', () {
      expect(WmoWeatherMapper.getDescription(null), equals('Unknown Weather'));
      expect(WmoWeatherMapper.getDescription(999), equals('Variably Cloudy'));
    });

    test('should return appropriate day vs night icons for code 0', () {
      final dayIcon = WmoWeatherMapper.getIcon(0, isDay: true);
      final nightIcon = WmoWeatherMapper.getIcon(0, isDay: false);

      expect(dayIcon, equals(Icons.wb_sunny));
      expect(nightIcon, equals(Icons.nightlight_round));
    });

    test('should return rain and storm icons for codes 61 and 95', () {
      expect(WmoWeatherMapper.getIcon(61), equals(Icons.water_drop));
      expect(WmoWeatherMapper.getIcon(95), equals(Icons.thunderstorm));
    });
  });
}
