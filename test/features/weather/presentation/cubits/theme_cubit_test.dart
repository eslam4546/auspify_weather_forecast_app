import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast_app/features/weather/domain/usecases/preference_usecases.dart';
import 'package:weather_forecast_app/features/weather/presentation/cubits/theme_cubit.dart';

class MockGetThemeModeUseCase extends Mock implements GetThemeModeUseCase {}

class MockSetThemeModeUseCase extends Mock implements SetThemeModeUseCase {}

void main() {
  late MockGetThemeModeUseCase mockGetThemeModeUseCase;
  late MockSetThemeModeUseCase mockSetThemeModeUseCase;

  setUp(() {
    mockGetThemeModeUseCase = MockGetThemeModeUseCase();
    mockSetThemeModeUseCase = MockSetThemeModeUseCase();

    when(() => mockGetThemeModeUseCase()).thenAnswer((_) async => true);
    when(() => mockSetThemeModeUseCase(any())).thenAnswer((_) async {});
  });

  group('ThemeCubit Tests', () {
    test('initial state is ThemeMode.dark', () {
      final cubit = ThemeCubit(
        getThemeModeUseCase: mockGetThemeModeUseCase,
        setThemeModeUseCase: mockSetThemeModeUseCase,
      );

      expect(cubit.state, equals(ThemeMode.dark));
      expect(cubit.isDarkMode, isTrue);
    });

    blocTest<ThemeCubit, ThemeMode>(
      'toggles theme from dark to light and persists choice',
      build: () => ThemeCubit(
        getThemeModeUseCase: mockGetThemeModeUseCase,
        setThemeModeUseCase: mockSetThemeModeUseCase,
      ),
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [ThemeMode.light],
      verify: (_) {
        verify(() => mockSetThemeModeUseCase(false)).called(1);
      },
    );

    blocTest<ThemeCubit, ThemeMode>(
      'toggles theme twice back to dark',
      build: () => ThemeCubit(
        getThemeModeUseCase: mockGetThemeModeUseCase,
        setThemeModeUseCase: mockSetThemeModeUseCase,
      ),
      act: (cubit) async {
        await cubit.toggleTheme(); // -> light
        await cubit.toggleTheme(); // -> dark
      },
      expect: () => [ThemeMode.light, ThemeMode.dark],
    );
  });
}
