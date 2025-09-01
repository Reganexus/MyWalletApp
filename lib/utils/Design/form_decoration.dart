import 'package:flutter/material.dart';

InputDecoration buildInputDecoration(
  String label, {
  Widget? prefixIcon,
  required Color color,
  required bool isFocused,
  required BuildContext context,
}) {
  final theme = Theme.of(context);
  final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
  final unfocusedBorderColor = theme.dividerColor;
  final fillColor = theme.inputDecorationTheme.fillColor ?? theme.cardColor;

  return InputDecoration(
    labelText: label,
    prefixIcon:
        prefixIcon != null
            ? IconTheme(
              data: IconThemeData(
                color: isFocused ? color : theme.disabledColor,
              ),
              child: prefixIcon,
            )
            : null,
    filled: true,
    fillColor: fillColor,
    labelStyle: TextStyle(color: textColor),
    floatingLabelStyle: TextStyle(color: isFocused ? color : textColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: unfocusedBorderColor, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: unfocusedBorderColor, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 2),
    ),
  );
}
