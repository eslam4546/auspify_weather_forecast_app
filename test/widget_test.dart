import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast_app/core/theme/app_theme.dart';

void main() {
  test('AppTheme initial theme test', () {
    expect(AppTheme.darkTheme.brightness, equals(Brightness.dark));
    expect(AppTheme.lightTheme.brightness, equals(Brightness.light));
  });
}
