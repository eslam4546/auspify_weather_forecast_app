class ApiConstants {
  static const String forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  // Fallback coordinates (Cairo, Egypt) when GPS permission is denied or unavailable
  static const double defaultLatitude = 30.0444;
  static const double defaultLongitude = 31.2357;
  static const String defaultCityName = 'Cairo';
  static const String defaultCountry = 'Egypt';

  // Network request timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Temperature unit identifiers
  static const String unitCelsius = 'celsius';
  static const String unitFahrenheit = 'fahrenheit';
  static const String unitSymbolCelsius = '°C';
  static const String unitSymbolFahrenheit = '°F';
}
