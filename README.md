# Auspify Weather Forecast App (Task 3)

[![Flutter](https://img.shields.io/badge/Flutter-3.47.7-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-blue.svg?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State%20Management-flutter__bloc%20%28Cubit%29-indigo.svg)](https://pub.dev/packages/flutter_bloc)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-teal.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A production-ready, responsive mobile weather forecast application developed for the **Auspify Technologies 4-Week Practical Learning Internship Program (Task 3)**.

The app fetches dynamic, real-time meteorological conditions and multi-day forecasts using the keyless **Open-Meteo REST & Geocoding APIs**, featuring GPS device telemetry, global city search, favorite cities management, temperature unit conversion (`°C`/`°F`), and adaptive Dark/Light themes inspired by the Google Stitch **"Aether Atmospheric Weather"** design system.

---

## 🌟 Key Features

* **Live Weather Dashboard**: Real-time temperature in ultra-light typography, weather condition description, Material Symbols/weather icon, high/low daily summary, and live status badge.
* **Essential 2x3 Telemetry Grid**:
  * **Humidity (%)**: Linear progress meter with ambient zone descriptor.
  * **Wind Velocity (km/h)**: Surface wind speed with direction compass indicator.
  * **Feels Like**: Apparent temperature adjusted for humidity and wind velocity.
  * **UV Index**: Numeric scale with semantic severity tags (*Low*, *Moderate*, *High*, *Extreme*).
  * **Surface Pressure (hPa)**: Barometric pressure monitoring.
  * **Solar Cycle**: Daytime / Nighttime indicator.
* **24-Hour Hourly Timeline**: Horizontally scrollable capsule ribbon with condition icons, precipitation probability badges, and hourly temperatures.
* **7-Day Extended Forecast**: Week-ahead outlook with normalized min/max horizontal temperature gradient range bars.
* **GPS Location Telemetry**: Uses `geolocator` with runtime permission handling and graceful fallback to Cairo coordinates (`30.0444, 31.2357`) if location services or permissions are denied.
* **Global City Search**: Live debounced search querying Open-Meteo Geocoding API with immediate tap-to-load and instant bookmarking.
* **Bento Favorite Cities**: Local persistence of saved cities with count badge, one-tap switching, and interactive `Edit` mode with deletion actions.
* **Temperature Unit Toggle**: Seamlessly switch between Celsius (`°C`) and Fahrenheit (`°F`) with local persistence and automatic forecast recalculation.
* **Theme Mode Switcher**: Adaptive Dark Mode (default Aether celestial slate) and Light Mode with local persistence.
* **Error & Offline Resilience**: Shimmer skeleton loading during network queries, user-friendly error views with "Retry", and offline cached telemetry display.

---

## 🏗️ Architecture & Technology Stack

The project strictly follows **Clean Architecture** with a unidirectional data flow powered by **Cubit (`flutter_bloc`)**:

```
lib/
├── core/
│   ├── constants/      # API endpoints, default fallback coordinates, timeouts
│   ├── error/          # Typed Failures and Exceptions
│   ├── theme/          # AppColors, AppTheme (Dark & Light), Typography tokens
│   └── utils/          # WmoWeatherMapper (WMO 0-99 code to conditions & icons)
├── features/
│   └── weather/
│       ├── data/
│       │   ├── datasources/   # Remote (Dio), Local (SharedPreferences), Location (Geolocator)
│       │   ├── models/        # JSON serialization & entity mappers
│       │   └── repositories/  # WeatherRepositoryImpl mapping exceptions to failures
│       ├── domain/
│       │   ├── entities/      # CityLocationEntity, CurrentWeather, Hourly, Daily, Dashboard
│       │   ├── repositories/  # WeatherRepository abstract contract
│       │   └── usecases/      # 11 focused domain use cases
│       └── presentation/
│           ├── cubits/        # WeatherCubit, CitySearchCubit, ThemeCubit
│           ├── pages/         # WeatherDashboardPage, CitySearchPage
│           └── widgets/       # HeroCard, TelemetryGrid, HourlyRibbon, DailyList, Shimmer, Error
├── injection_container.dart   # Lightweight, type-safe ServiceLocator
└── main.dart                  # MultiBlocProvider & MaterialApp root
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK: `^3.13.5` or later
* Dart SDK: `^3.13.5` or later

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/eslam4546/auspify_weather_forecast_app.git
   cd auspify_weather_forecast_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run code analysis and tests:**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Testing

The test suite covers Core utilities, JSON deserialization/serialization, and Cubit state management:

```bash
flutter test
```
* **Core Tests**: WMO code mapping, weather descriptions, and day/night icons.
* **Data Layer Tests**: Geocoding JSON parsing, Open-Meteo forecast JSON parsing, and cache roundtrip serialization.
* **State Management Tests**: `ThemeCubit` and `WeatherCubit` state transitions using `bloc_test` and `mocktail`.

---

## 📄 License
This project is licensed under the MIT License.
