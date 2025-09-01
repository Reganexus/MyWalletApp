import 'package:flutter/material.dart';

class ChartLegend extends StatelessWidget {
  final List<String> labels;
  final List<Color>? colors;

  const ChartLegend({super.key, required this.labels, this.colors});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          labels.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final color =
                colors != null && index < colors!.length
                    ? colors![index]
                    : Colors.primaries[index % Colors.primaries.length]
                        .withAlpha(204);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(label, style: const TextStyle(fontSize: 13)),
                ],
              ),
            );
          }).toList(),
    );
  }
}
