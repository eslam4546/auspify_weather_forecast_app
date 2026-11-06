import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/preference_usecases.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final GetThemeModeUseCase getThemeModeUseCase;
  final SetThemeModeUseCase setThemeModeUseCase;

  ThemeCubit({
    required this.getThemeModeUseCase,
    required this.setThemeModeUseCase,
    ThemeMode initialMode = ThemeMode.dark,
  }) : super(initialMode);

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> loadSavedTheme() async {
    final isDark = await getThemeModeUseCase();
    final savedMode = isDark ? ThemeMode.dark : ThemeMode.light;
    if (state != savedMode) {
      emit(savedMode);
    }
  }

  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    emit(newMode);
    await setThemeModeUseCase(newMode == ThemeMode.dark);
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await setThemeModeUseCase(mode == ThemeMode.dark);
  }
}
