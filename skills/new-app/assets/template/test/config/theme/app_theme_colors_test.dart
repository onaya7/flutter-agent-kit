import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kit_template_app/config/theme/app_theme.dart';
import 'package:kit_template_app/config/theme/app_theme_colors.dart';

const _light = <String, int>{
  'textHeading': 0xFF18181B,
  'textSubheading': 0xFF3F3F46,
  'subtext': 0xFF71717A,
  'textLink': 0xFF4F46E5,
  'background': 0xFFFAFAFA,
  'cards': 0xFFFFFFFF,
  'cardFill': 0x00000000,
  'stroke': 0xFFE4E4E7,
  'strokeFill': 0xFFF4F4F5,
  'fill': 0xFFD4D4D8,
  'divider': 0xFFF4F4F5,
  'modalSurface': 0xE6FFFFFF,
  'icon': 0xFF27272A,
  'iconBg': 0x1A000000,
  'iconLow': 0xFF71717A,
  'iconInactive': 0xFFD4D4D8,
  'primary': 0xFF4F46E5,
};

const _dark = <String, int>{
  'textHeading': 0xFFFAFAFA,
  'textSubheading': 0xFFD4D4D8,
  'subtext': 0xFFA1A1AA,
  'textLink': 0xFFA5B4FC,
  'background': 0xFF09090B,
  'cards': 0xFF18181B,
  'cardFill': 0xFF18181B,
  'stroke': 0xFF27272A,
  'strokeFill': 0xFF18181B,
  'fill': 0xFF3F3F46,
  'divider': 0xFF27272A,
  'modalSurface': 0xE6000000,
  'icon': 0xFFF4F4F5,
  'iconBg': 0x1AFFFFFF,
  'iconLow': 0xFFA1A1AA,
  'iconInactive': 0xFF3F3F46,
  'primary': 0xFFA5B4FC,
};

Map<String, Color> _roles(AppThemeColors c) => {
  'textHeading': c.textHeading,
  'textSubheading': c.textSubheading,
  'subtext': c.subtext,
  'textLink': c.textLink,
  'background': c.background,
  'cards': c.cards,
  'cardFill': c.cardFill,
  'stroke': c.stroke,
  'strokeFill': c.strokeFill,
  'fill': c.fill,
  'divider': c.divider,
  'modalSurface': c.modalSurface,
  'icon': c.icon,
  'iconBg': c.iconBg,
  'iconLow': c.iconLow,
  'iconInactive': c.iconInactive,
  'primary': c.primary,
};

String _hex(int argb) =>
    '#${argb.toRadixString(16).toUpperCase().padLeft(8, '0')}';

void main() {
  group('AppThemeColors pins every role to the palette', () {
    for (final (mode, expected, actual) in [
      ('light', _light, _roles(AppThemeColors.light)),
      ('dark', _dark, _roles(AppThemeColors.dark)),
    ]) {
      test('$mode table covers every role', () {
        expect(actual.keys.toSet(), expected.keys.toSet());
      });

      for (final entry in expected.entries) {
        test('$mode.${entry.key}', () {
          final value = actual[entry.key]!.toARGB32();
          expect(
            value,
            entry.value,
            reason:
                '$mode "${entry.key}" expected ${_hex(entry.value)}, got ${_hex(value)}',
          );
        });
      }
    }
  });

  group('AppTheme', () {
    test('light and dark carry their extension', () {
      expect(
        AppTheme.lightTheme.extension<AppThemeColors>(),
        AppThemeColors.light,
      );
      expect(
        AppTheme.darkTheme.extension<AppThemeColors>(),
        AppThemeColors.dark,
      );
    });

    test('scaffold background is the background role', () {
      expect(
        AppTheme.lightTheme.scaffoldBackgroundColor.toARGB32(),
        _light['background'],
      );
      expect(
        AppTheme.darkTheme.scaffoldBackgroundColor.toARGB32(),
        _dark['background'],
      );
    });
  });
}
