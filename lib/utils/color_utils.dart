// lib/utils/color_utils.dart
import 'package:flutter/material.dart';

class ColorUtils {
  /// A curated list of background colors where white text is legible.
  static const List<Color> availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    Colors.deepOrange,
    Colors.cyan,
    Colors.deepPurple,
  ];

  /// Ensures text contrast is accessible (white or black depending on bg).
  static Color getContrastingTextColor(Color bgColor) {
    return bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  // ---------- Color Helpers ----------
  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String colorToHex(Color color, {bool includeAlpha = false}) {
    final argb = color.toARGB32();
    final a = (argb >> 24) & 0xFF;
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return includeAlpha
        ? '#${a.toRadixString(16).padLeft(2, '0')}${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'
        : '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }
}
