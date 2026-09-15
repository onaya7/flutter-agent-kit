import 'package:flutter/material.dart';
import 'package:kit_template_app/core/constants/app_color.dart';

/// One field per mode-varying role; invariant values live on [AppColor].
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.textHeading,
    required this.textSubheading,
    required this.subtext,
    required this.textLink,
    required this.background,
    required this.cards,
    required this.cardFill,
    required this.stroke,
    required this.strokeFill,
    required this.fill,
    required this.divider,
    required this.modalSurface,
    required this.icon,
    required this.iconBg,
    required this.iconLow,
    required this.iconInactive,
    required this.primary,
  });

  final Color textHeading;
  final Color textSubheading;
  final Color subtext;
  final Color textLink;
  final Color background;
  final Color cards;

  /// Outline-only in light, a filled surface in dark.
  final Color cardFill;
  final Color stroke;
  final Color strokeFill;
  final Color fill;
  final Color divider;
  final Color modalSurface;
  final Color icon;
  final Color iconBg;
  final Color iconLow;
  final Color iconInactive;
  final Color primary;

  static const light = AppThemeColors(
    textHeading: AppColor.grey900,
    textSubheading: AppColor.grey700,
    subtext: AppColor.grey500,
    textLink: AppColor.primary,
    background: AppColor.grey50,
    cards: AppColor.white,
    cardFill: Colors.transparent,
    stroke: AppColor.grey200,
    strokeFill: AppColor.grey100,
    fill: AppColor.grey300,
    divider: AppColor.grey100,
    modalSurface: AppColor.white90,
    icon: AppColor.grey800,
    iconBg: AppColor.black10,
    iconLow: AppColor.grey500,
    iconInactive: AppColor.grey300,
    primary: AppColor.primary,
  );

  static const dark = AppThemeColors(
    textHeading: AppColor.grey50,
    textSubheading: AppColor.grey300,
    subtext: AppColor.grey400,
    textLink: AppColor.primaryLight,
    background: AppColor.grey950,
    cards: AppColor.grey900,
    cardFill: AppColor.grey900,
    stroke: AppColor.grey800,
    strokeFill: AppColor.grey900,
    fill: AppColor.grey700,
    divider: AppColor.grey800,
    modalSurface: AppColor.black90,
    icon: AppColor.grey100,
    iconBg: AppColor.white10,
    iconLow: AppColor.grey400,
    iconInactive: AppColor.grey700,
    primary: AppColor.primaryLight,
  );

  static AppThemeColors of(BuildContext context) =>
      Theme.of(context).extension<AppThemeColors>()!;

  @override
  AppThemeColors copyWith({
    Color? textHeading,
    Color? textSubheading,
    Color? subtext,
    Color? textLink,
    Color? background,
    Color? cards,
    Color? cardFill,
    Color? stroke,
    Color? strokeFill,
    Color? fill,
    Color? divider,
    Color? modalSurface,
    Color? icon,
    Color? iconBg,
    Color? iconLow,
    Color? iconInactive,
    Color? primary,
  }) {
    return AppThemeColors(
      textHeading: textHeading ?? this.textHeading,
      textSubheading: textSubheading ?? this.textSubheading,
      subtext: subtext ?? this.subtext,
      textLink: textLink ?? this.textLink,
      background: background ?? this.background,
      cards: cards ?? this.cards,
      cardFill: cardFill ?? this.cardFill,
      stroke: stroke ?? this.stroke,
      strokeFill: strokeFill ?? this.strokeFill,
      fill: fill ?? this.fill,
      divider: divider ?? this.divider,
      modalSurface: modalSurface ?? this.modalSurface,
      icon: icon ?? this.icon,
      iconBg: iconBg ?? this.iconBg,
      iconLow: iconLow ?? this.iconLow,
      iconInactive: iconInactive ?? this.iconInactive,
      primary: primary ?? this.primary,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      textHeading: Color.lerp(textHeading, other.textHeading, t)!,
      textSubheading: Color.lerp(textSubheading, other.textSubheading, t)!,
      subtext: Color.lerp(subtext, other.subtext, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      background: Color.lerp(background, other.background, t)!,
      cards: Color.lerp(cards, other.cards, t)!,
      cardFill: Color.lerp(cardFill, other.cardFill, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      strokeFill: Color.lerp(strokeFill, other.strokeFill, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      modalSurface: Color.lerp(modalSurface, other.modalSurface, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      iconBg: Color.lerp(iconBg, other.iconBg, t)!,
      iconLow: Color.lerp(iconLow, other.iconLow, t)!,
      iconInactive: Color.lerp(iconInactive, other.iconInactive, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
    );
  }
}
