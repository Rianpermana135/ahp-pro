
import 'package:flutter/material.dart';

class ComparisonSlider extends StatelessWidget {
  final String labelLeft;
  final String labelRight;
  final double value; // Scale -9 to 9 (0 = Equal)
  final ValueChanged<double> onChanged;

  const ComparisonSlider({
    super.key,
    required this.labelLeft,
    required this.labelRight,
    required this.value,
    required this.onChanged,
  });

  String get _statusText {
    if (value.abs() < 1) return "Sama Penting (1)";
    int v = value.abs().round();
    if (v == 0) return "Sama Penting (1)";
    
    // Saaty values: 1, 3, 5, 7, 9 typically.
    // Here we allow continuous or steps.
    String direction = value < 0 ? labelLeft : labelRight;
    return "$direction lebih penting ($v)";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(labelLeft, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left)),
                Expanded(child: Text(labelRight, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
            Slider(
              value: value,
              min: -9,
              max: 9,
              divisions: 18,
              label: value.round().toString(),
              activeColor: Colors.green,
              onChanged: onChanged,
            ),
            Text(_statusText, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
