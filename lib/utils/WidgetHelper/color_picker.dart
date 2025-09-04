import 'package:flutter/material.dart';

class ColorPickerGrid extends StatelessWidget {
  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;
  final int crossAxisCount;

  const ColorPickerGrid({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
    this.crossAxisCount = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children:
          colors.map((color) {
            final isSelected = selectedColor == color;

            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border:
                      isSelected
                          ? Border.all(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                            width: 3,
                          )
                          : null,
                ),
                child:
                    isSelected
                        ? Icon(
                          Icons.check,
                          color:
                              ThemeData.estimateBrightnessForColor(color) ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                        )
                        : null,
              ),
            );
          }).toList(),
    );
  }
}
