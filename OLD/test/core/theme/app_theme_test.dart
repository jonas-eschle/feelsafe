/// Tests for [AppTheme.light] / [AppTheme.dark] and the
/// [AppColorsExt] theme extension.
library;

import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guardianangela/core/theme/app_colors.dart';
import 'package:guardianangela/core/theme/app_theme.dart';
import 'package:guardianangela/core/theme/theme_extensions.dart';

void main() {
  group('AppTheme.light', () {
    final theme = AppTheme.light();

    test('uses Material 3', () {
      check(theme.useMaterial3).isTrue();
    });

    test('is a light brightness color scheme', () {
      check(theme.colorScheme.brightness).equals(Brightness.light);
    });

    test('registers the AppColorsExt extension', () {
      final ext = theme.extension<AppColorsExt>();
      check(ext).isNotNull();
      check(ext!.colors).identicalTo(AppColors.light);
    });
  });

  group('AppTheme.dark', () {
    final theme = AppTheme.dark();

    test('uses Material 3', () {
      check(theme.useMaterial3).isTrue();
    });

    test('is a dark brightness color scheme', () {
      check(theme.colorScheme.brightness).equals(Brightness.dark);
    });

    test('registers AppColorsExt with the dark palette', () {
      final ext = theme.extension<AppColorsExt>();
      check(ext).isNotNull();
      check(ext!.colors).identicalTo(AppColors.dark);
    });
  });

  group('AppColors palettes', () {
    test('light palette is fully populated', () {
      check(
        AppColors.light.safe,
      ).not((it) => it.equals(const Color(0x00000000)));
      check(
        AppColors.light.warning,
      ).not((it) => it.equals(const Color(0x00000000)));
      check(
        AppColors.light.danger,
      ).not((it) => it.equals(const Color(0x00000000)));
    });

    test('dark palette differs from light', () {
      check(AppColors.dark.safe).not((it) => it.equals(AppColors.light.safe));
      check(
        AppColors.dark.warning,
      ).not((it) => it.equals(AppColors.light.warning));
      check(
        AppColors.dark.danger,
      ).not((it) => it.equals(AppColors.light.danger));
    });

    test('"on" colors complement their background', () {
      // In the light palette, `safe` is green and `safeOn` is white.
      check(AppColors.light.safeOn).equals(Colors.white);
      check(AppColors.light.dangerOn).equals(Colors.white);
      check(AppColors.light.warningOn).equals(Colors.black);
    });
  });

  group('AppColorsExt', () {
    test('copyWith returns identity when no colors provided', () {
      const ext = AppColorsExt(colors: AppColors.light);
      check(ext.copyWith().colors).identicalTo(AppColors.light);
    });

    test('copyWith replaces when colors provided', () {
      const ext = AppColorsExt(colors: AppColors.light);
      final replaced = ext.copyWith(colors: AppColors.dark);
      check(replaced.colors).identicalTo(AppColors.dark);
    });

    test('lerp returns first when t < 0.5', () {
      const a = AppColorsExt(colors: AppColors.light);
      const b = AppColorsExt(colors: AppColors.dark);
      check(a.lerp(b, 0.2).colors).identicalTo(AppColors.light);
    });

    test('lerp returns second when t >= 0.5', () {
      const a = AppColorsExt(colors: AppColors.light);
      const b = AppColorsExt(colors: AppColors.dark);
      check(a.lerp(b, 0.7).colors).identicalTo(AppColors.dark);
    });

    test('lerp with null other returns self', () {
      const a = AppColorsExt(colors: AppColors.light);
      check(a.lerp(null, 0.5).colors).identicalTo(AppColors.light);
    });
  });

  group('AppColorsOn context extension', () {
    testWidgets('returns the palette registered on the theme', (tester) async {
      AppColors? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) {
              captured = context.appColors;
              return const SizedBox();
            },
          ),
        ),
      );
      check(captured).identicalTo(AppColors.light);
    });

    testWidgets('falls back to light palette without extension', (
      tester,
    ) async {
      AppColors? captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              captured = context.appColors;
              return const SizedBox();
            },
          ),
        ),
      );
      check(captured).identicalTo(AppColors.light);
    });
  });
}
