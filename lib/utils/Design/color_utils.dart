// lib/utils/color_utils.dart
import 'package:flutter/material.dart';

class ColorUtils {
  static const Color defaultColor = Color.fromARGB(255, 38, 71, 82);
  static const Color mainColor1 = Color.fromARGB(255, 42, 156, 142);
  static const Color mainColor2 = Color.fromARGB(255, 230, 111, 80);
  static const Color mainColor3 = Color.fromARGB(255, 245, 163, 97);
  static const Color mainColor4 = Color.fromARGB(255, 233, 197, 107);

  static const List<Color> availableColors = [
    defaultColor,
    Colors.green,
    mainColor1,
    Colors.cyan,
    Colors.blue,
    Colors.indigo,
    Colors.deepPurple,
    Colors.purple,
    Colors.pink,
    Colors.red,
    Colors.deepOrange,
    mainColor2,
    mainColor3,
    mainColor4,
    Colors.orange,
    Colors.brown,
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
