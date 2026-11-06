import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/weather/presentation/cubits/city_search_cubit.dart';
import 'features/weather/presentation/cubits/theme_cubit.dart';
import 'features/weather/presentation/cubits/weather_cubit.dart';
import 'features/weather/presentation/pages/weather_dashboard_page.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<WeatherCubit>(create: (_) => sl<WeatherCubit>()),
        BlocProvider<CitySearchCubit>(create: (_) => sl<CitySearchCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Aether Weather',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const WeatherDashboardPage(),
          );
        },
      ),
    );
  }
}
