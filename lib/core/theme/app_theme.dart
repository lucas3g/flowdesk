import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

/// Constrói os [ThemeData] claro e escuro do FlowDesk (Material 3),
/// injetando os tokens do design system via [FlowDeskColors].
abstract final class AppTheme {
  static ThemeData get dark => _build(FlowDeskColors.dark, Brightness.dark);

  static ThemeData get light => _build(FlowDeskColors.light, Brightness.light);

  static ThemeData _build(FlowDeskColors colors, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.blue,
      brightness: brightness,
      primary: colors.blue,
      surface: colors.content,
      error: colors.red,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.content,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: colors.hover,
      dividerColor: colors.separator,
      extensions: [colors],
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, colors),
      iconTheme: IconThemeData(color: colors.text2, size: 19),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.panel2,
          borderRadius: BorderRadius.circular(AppDimens.radiusChip),
          border: Border.all(color: colors.cardBorder),
        ),
        textStyle: TextStyle(color: colors.text, fontSize: 11.5),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(colors.text3),
        radius: const Radius.circular(6),
        thickness: const WidgetStatePropertyAll(6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.blue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.blue,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Tipografia do design: SF Pro (padrão do macOS) com pesos/tamanhos do mockup.
  static TextTheme _textTheme(TextTheme base, FlowDeskColors colors) {
    return base
        .apply(bodyColor: colors.text, displayColor: colors.text)
        .copyWith(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: colors.text,
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: colors.text,
          ),
          titleSmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
          bodyMedium: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.text,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colors.text2,
          ),
          labelSmall: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
            color: colors.text3,
          ),
        );
  }
}
