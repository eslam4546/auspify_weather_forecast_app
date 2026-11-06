import '../../domain/entities/city_location_entity.dart';
import '../../domain/entities/weather_entities.dart';
import 'city_location_model.dart';

class CurrentWeatherModel extends CurrentWeatherEntity {
  const CurrentWeatherModel({
    required super.temperature,
    required super.apparentTemperature,
    required super.humidity,
    required super.windSpeed,
    required super.surfacePressure,
    required super.uvIndex,
    required super.weatherCode,
    required super.isDay,
    required super.time,
  });

  factory CurrentWeatherModel.fromJson(
    Map<String, dynamic> json, {
    double uvIndex = 0.0,
  }) {
    return CurrentWeatherModel(
      temperature:
          (json['temperature_2m'] ?? json['temperature'] as num?)?.toDouble() ??
          0.0,
      apparentTemperature:
          (json['apparent_temperature'] ?? json['apparentTemperature'] as num?)
              ?.toDouble() ??
          0.0,
      humidity:
          (json['relative_humidity_2m'] ?? json['humidity'] as num?)?.toInt() ??
          0,
      windSpeed:
          (json['wind_speed_10m'] ?? json['windSpeed'] as num?)?.toDouble() ??
          0.0,
      surfacePressure:
          (json['surface_pressure'] ?? json['surfacePressure'] as num?)
              ?.toDouble() ??
          1013.0,
      uvIndex:
          (json['uv_index'] ?? json['uvIndex'] as num?)?.toDouble() ?? uvIndex,
      weatherCode:
          (json['weather_code'] ?? json['weatherCode'] as num?)?.toInt() ?? 0,
      isDay: json['is_day'] == 1 || json['isDay'] == true,
      time: json['time'] as String? ?? '',
    );
  }

  factory CurrentWeatherModel.fromEntity(CurrentWeatherEntity entity) {
    return CurrentWeatherModel(
      temperature: entity.temperature,
      apparentTemperature: entity.apparentTemperature,
      humidity: entity.humidity,
      windSpeed: entity.windSpeed,
      surfacePressure: entity.surfacePressure,
      uvIndex: entity.uvIndex,
      weatherCode: entity.weatherCode,
      isDay: entity.isDay,
      time: entity.time,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'apparentTemperature': apparentTemperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'surfacePressure': surfacePressure,
      'uvIndex': uvIndex,
      'weatherCode': weatherCode,
      'isDay': isDay,
      'time': time,
    };
  }
}

class HourlyForecastModel extends HourlyForecastEntity {
  const HourlyForecastModel({
    required super.time,
    required super.temperature,
    required super.weatherCode,
    required super.precipitationProbability,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlyForecastModel(
      time: json['time'] as String? ?? '',
      temperature:
          (json['temperature'] ?? json['temperature_2m'] as num?)?.toDouble() ??
          0.0,
      weatherCode:
          (json['weatherCode'] ?? json['weather_code'] as num?)?.toInt() ?? 0,
      precipitationProbability:
          (json['precipitationProbability'] ??
                  json['precipitation_probability'] as num?)
              ?.toInt() ??
          0,
    );
  }

  factory HourlyForecastModel.fromEntity(HourlyForecastEntity entity) {
    return HourlyForecastModel(
      time: entity.time,
      temperature: entity.temperature,
      weatherCode: entity.weatherCode,
      precipitationProbability: entity.precipitationProbability,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'temperature': temperature,
      'weatherCode': weatherCode,
      'precipitationProbability': precipitationProbability,
    };
  }
}

class DailyForecastModel extends DailyForecastEntity {
  const DailyForecastModel({
    required super.date,
    required super.maxTemperature,
    required super.minTemperature,
    required super.weatherCode,
    required super.precipitationProbabilityMax,
  });

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    return DailyForecastModel(
      date: (json['date'] ?? json['time'] as String?) ?? '',
      maxTemperature:
          (json['maxTemperature'] ?? json['temperature_2m_max'] as num?)
              ?.toDouble() ??
          0.0,
      minTemperature:
          (json['minTemperature'] ?? json['temperature_2m_min'] as num?)
              ?.toDouble() ??
          0.0,
      weatherCode:
          (json['weatherCode'] ?? json['weather_code'] as num?)?.toInt() ?? 0,
      precipitationProbabilityMax:
          (json['precipitationProbabilityMax'] ??
                  json['precipitation_probability_max'] as num?)
              ?.toInt() ??
          0,
    );
  }

  factory DailyForecastModel.fromEntity(DailyForecastEntity entity) {
    return DailyForecastModel(
      date: entity.date,
      maxTemperature: entity.maxTemperature,
      minTemperature: entity.minTemperature,
      weatherCode: entity.weatherCode,
      precipitationProbabilityMax: entity.precipitationProbabilityMax,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'maxTemperature': maxTemperature,
      'minTemperature': minTemperature,
      'weatherCode': weatherCode,
      'precipitationProbabilityMax': precipitationProbabilityMax,
    };
  }
}

class WeatherDashboardModel extends WeatherDashboardEntity {
  const WeatherDashboardModel({
    required super.location,
    required super.current,
    required super.hourly,
    required super.daily,
    required super.lastUpdated,
    super.isOfflineCached = false,
  });

  /// Parses Open-Meteo REST API JSON response
  factory WeatherDashboardModel.fromOpenMeteoJson({
    required Map<String, dynamic> json,
    required CityLocationEntity location,
  }) {
    // 1. Extract UV Index from daily[0] if available
    double uvIndex = 0.0;
    final dailyJson = json['daily'] as Map<String, dynamic>?;
    if (dailyJson != null) {
      final uvList = dailyJson['uv_index_max'] as List<dynamic>?;
      if (uvList != null && uvList.isNotEmpty) {
        uvIndex = (uvList.first as num?)?.toDouble() ?? 0.0;
      }
    }

    // 2. Parse Current Weather
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final current = CurrentWeatherModel.fromJson(currentJson, uvIndex: uvIndex);

    // 3. Parse Hourly Forecast (slice next 24 hours starting from current hour)
    final List<HourlyForecastModel> hourlyList = [];
    final hourlyJson = json['hourly'] as Map<String, dynamic>?;
    if (hourlyJson != null) {
      final times =
          (hourlyJson['time'] as List<dynamic>?)?.cast<String>() ?? [];
      final temps = (hourlyJson['temperature_2m'] as List<dynamic>?) ?? [];
      final codes = (hourlyJson['weather_code'] as List<dynamic>?) ?? [];
      final precipProbs =
          (hourlyJson['precipitation_probability'] as List<dynamic>?) ?? [];

      // Determine starting index closest to current time
      int startIndex = 0;
      final currentTimeStr = current.time;
      if (currentTimeStr.isNotEmpty) {
        final foundIndex = times.indexWhere(
          (t) => t.startsWith(currentTimeStr.substring(0, 13)),
        );
        if (foundIndex != -1) {
          startIndex = foundIndex;
        }
      }

      final endIndex = (startIndex + 24).clamp(0, times.length);
      for (int i = startIndex; i < endIndex; i++) {
        hourlyList.add(
          HourlyForecastModel(
            time: times[i],
            temperature: (temps[i] as num?)?.toDouble() ?? 0.0,
            weatherCode: (codes[i] as num?)?.toInt() ?? 0,
            precipitationProbability: (precipProbs[i] as num?)?.toInt() ?? 0,
          ),
        );
      }
    }

    // 4. Parse Daily Forecast (7 days)
    final List<DailyForecastModel> dailyList = [];
    if (dailyJson != null) {
      final dates = (dailyJson['time'] as List<dynamic>?)?.cast<String>() ?? [];
      final maxTemps =
          (dailyJson['temperature_2m_max'] as List<dynamic>?) ?? [];
      final minTemps =
          (dailyJson['temperature_2m_min'] as List<dynamic>?) ?? [];
      final codes = (dailyJson['weather_code'] as List<dynamic>?) ?? [];
      final precipProbsMax =
          (dailyJson['precipitation_probability_max'] as List<dynamic>?) ?? [];

      final count = [dates.length, 7].reduce((a, b) => a < b ? a : b);
      for (int i = 0; i < count; i++) {
        dailyList.add(
          DailyForecastModel(
            date: dates[i],
            maxTemperature: (maxTemps[i] as num?)?.toDouble() ?? 0.0,
            minTemperature: (minTemps[i] as num?)?.toDouble() ?? 0.0,
            weatherCode: (codes[i] as num?)?.toInt() ?? 0,
            precipitationProbabilityMax:
                (precipProbsMax[i] as num?)?.toInt() ?? 0,
          ),
        );
      }
    }

    return WeatherDashboardModel(
      location: location,
      current: current,
      hourly: hourlyList,
      daily: dailyList,
      lastUpdated: DateTime.now(),
      isOfflineCached: false,
    );
  }

  /// Parses locally persisted cache JSON
  factory WeatherDashboardModel.fromCacheJson(Map<String, dynamic> json) {
    final locationJson = json['location'] as Map<String, dynamic>? ?? {};
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final hourlyRaw = json['hourly'] as List<dynamic>? ?? [];
    final dailyRaw = json['daily'] as List<dynamic>? ?? [];

    return WeatherDashboardModel(
      location: CityLocationModel.fromJson(locationJson),
      current: CurrentWeatherModel.fromJson(currentJson),
      hourly: hourlyRaw
          .map((e) => HourlyForecastModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      daily: dailyRaw
          .map((e) => DailyForecastModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] as String? ?? '') ??
          DateTime.now(),
      isOfflineCached: true,
    );
  }

  factory WeatherDashboardModel.fromEntity(WeatherDashboardEntity entity) {
    return WeatherDashboardModel(
      location: entity.location,
      current: entity.current,
      hourly: entity.hourly,
      daily: entity.daily,
      lastUpdated: entity.lastUpdated,
      isOfflineCached: entity.isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': CityLocationModel.fromEntity(location).toJson(),
      'current': CurrentWeatherModel.fromEntity(current).toJson(),
      'hourly': hourly
          .map((e) => HourlyForecastModel.fromEntity(e).toJson())
          .toList(),
      'daily': daily
          .map((e) => DailyForecastModel.fromEntity(e).toJson())
          .toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isOfflineCached': isOfflineCached,
    };
  }
}
