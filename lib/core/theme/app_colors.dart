import 'package:flutter/material.dart';

/// Tokens de cor do design system do FlowDesk, expostos como [ThemeExtension]
/// para acesso via `context` em qualquer widget.
///
/// Os valores replicam o design de referência (variáveis CSS do mockup),
/// baseado nas cores de sistema da Apple.
@immutable
class FlowDeskColors extends ThemeExtension<FlowDeskColors> {
  const FlowDeskColors({
    required this.window,
    required this.titlebar,
    required this.sidebar,
    required this.content,
    required this.panel,
    required this.panel2,
    required this.card,
    required this.cardHover,
    required this.cardBorder,
    required this.text,
    required this.text2,
    required this.text3,
    required this.separator,
    required this.hover,
    required this.selection,
    required this.blue,
    required this.blueSoft,
    required this.green,
    required this.orange,
    required this.red,
    required this.purple,
    required this.pink,
    required this.teal,
  });

  final Color window;
  final Color titlebar;
  final Color sidebar;
  final Color content;
  final Color panel;
  final Color panel2;
  final Color card;
  final Color cardHover;
  final Color cardBorder;
  final Color text;
  final Color text2;
  final Color text3;
  final Color separator;
  final Color hover;
  final Color selection;
  final Color blue;
  final Color blueSoft;
  final Color green;
  final Color orange;
  final Color red;
  final Color purple;
  final Color pink;
  final Color teal;

  /// Cores fixas, independentes de tema (semáforo do macOS).
  static const Color trafficRed = Color(0xFFFF5F57);
  static const Color trafficYellow = Color(0xFFFEBC2E);
  static const Color trafficGreen = Color(0xFF28C840);

  static const dark = FlowDeskColors(
    window: Color(0xFF232326),
    titlebar: Color(0xD12C2C30),
    sidebar: Color(0xB8242428),
    content: Color(0xFF1B1B1D),
    panel: Color(0xFF2A2A2E),
    panel2: Color(0xFF323236),
    card: Color(0x0BFFFFFF),
    cardHover: Color(0x13FFFFFF),
    cardBorder: Color(0x17FFFFFF),
    text: Color(0xFFF5F5F7),
    text2: Color(0x9EEBEBF5),
    text3: Color(0x57EBEBF5),
    separator: Color(0x17FFFFFF),
    hover: Color(0x0FFFFFFF),
    selection: Color(0x1FFFFFFF),
    blue: Color(0xFF0A84FF),
    blueSoft: Color(0x2E0A84FF),
    green: Color(0xFF30D158),
    orange: Color(0xFFFF9F0A),
    red: Color(0xFFFF453A),
    purple: Color(0xFFBF5AF2),
    pink: Color(0xFFFF375F),
    teal: Color(0xFF40C8E0),
  );

  static const light = FlowDeskColors(
    window: Color(0xFFFFFFFF),
    titlebar: Color(0xD9F6F6F8),
    sidebar: Color(0xC7EEEEF2),
    content: Color(0xFFFBFBFD),
    panel: Color(0xFFF4F4F6),
    panel2: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardHover: Color(0xFFFFFFFF),
    cardBorder: Color(0x14000000),
    text: Color(0xFF1D1D1F),
    text2: Color(0x993C3C43),
    text3: Color(0x4D3C3C43),
    separator: Color(0x14000000),
    hover: Color(0x0B000000),
    selection: Color(0x12000000),
    blue: Color(0xFF007AFF),
    blueSoft: Color(0x1F007AFF),
    green: Color(0xFF28B24B),
    orange: Color(0xFFF08600),
    red: Color(0xFFFF3B30),
    purple: Color(0xFF9F3FD8),
    pink: Color(0xFFFF2D55),
    teal: Color(0xFF00A5C4),
  );

  @override
  FlowDeskColors copyWith({
    Color? window,
    Color? titlebar,
    Color? sidebar,
    Color? content,
    Color? panel,
    Color? panel2,
    Color? card,
    Color? cardHover,
    Color? cardBorder,
    Color? text,
    Color? text2,
    Color? text3,
    Color? separator,
    Color? hover,
    Color? selection,
    Color? blue,
    Color? blueSoft,
    Color? green,
    Color? orange,
    Color? red,
    Color? purple,
    Color? pink,
    Color? teal,
  }) {
    return FlowDeskColors(
      window: window ?? this.window,
      titlebar: titlebar ?? this.titlebar,
      sidebar: sidebar ?? this.sidebar,
      content: content ?? this.content,
      panel: panel ?? this.panel,
      panel2: panel2 ?? this.panel2,
      card: card ?? this.card,
      cardHover: cardHover ?? this.cardHover,
      cardBorder: cardBorder ?? this.cardBorder,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      separator: separator ?? this.separator,
      hover: hover ?? this.hover,
      selection: selection ?? this.selection,
      blue: blue ?? this.blue,
      blueSoft: blueSoft ?? this.blueSoft,
      green: green ?? this.green,
      orange: orange ?? this.orange,
      red: red ?? this.red,
      purple: purple ?? this.purple,
      pink: pink ?? this.pink,
      teal: teal ?? this.teal,
    );
  }

  @override
  FlowDeskColors lerp(FlowDeskColors? other, double t) {
    if (other == null) return this;
    return FlowDeskColors(
      window: Color.lerp(window, other.window, t)!,
      titlebar: Color.lerp(titlebar, other.titlebar, t)!,
      sidebar: Color.lerp(sidebar, other.sidebar, t)!,
      content: Color.lerp(content, other.content, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      panel2: Color.lerp(panel2, other.panel2, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardHover: Color.lerp(cardHover, other.cardHover, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      hover: Color.lerp(hover, other.hover, t)!,
      selection: Color.lerp(selection, other.selection, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      blueSoft: Color.lerp(blueSoft, other.blueSoft, t)!,
      green: Color.lerp(green, other.green, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      red: Color.lerp(red, other.red, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
    );
  }
}

/// Atalho para acessar os tokens de cor a partir do [BuildContext].
extension FlowDeskColorsX on BuildContext {
  FlowDeskColors get colors => Theme.of(this).extension<FlowDeskColors>()!;
}
