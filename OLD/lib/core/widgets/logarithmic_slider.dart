/// Slider that maps a linear 0..1 track to a logarithmic value.
///
/// Useful for controls where small values need fine-grained control
/// and large values need coarse steps (e.g., GPS interval seconds).
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Log-scale slider.
class LogarithmicSlider extends StatelessWidget {
  /// Creates a log slider.
  ///
  /// [minValue] — minimum value, must be > 0.
  /// [maxValue] — maximum value, must be > [minValue].
  /// [value] — current value; clamped to `[minValue, maxValue]`.
  /// [onChanged] — fires on drag with the updated value.
  /// [label] — optional label text shown above the slider.
  const LogarithmicSlider({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
    this.label,
  });

  /// Minimum value; must be > 0.
  final double minValue;

  /// Maximum value; must be > [minValue].
  final double maxValue;

  /// Current value (clamped).
  final double value;

  /// Callback fired with the updated value.
  final ValueChanged<double> onChanged;

  /// Optional label shown above the slider.
  final String? label;

  double get _minLog => math.log(minValue);

  double get _maxLog => math.log(maxValue);

  double get _linear =>
      ((math.log(value.clamp(minValue, maxValue)) - _minLog) /
              (_maxLog - _minLog))
          .clamp(0.0, 1.0);

  double _toValue(double linear) =>
      math.exp(_minLog + linear * (_maxLog - _minLog));

  @override
  Widget build(BuildContext context) {
    final lbl = label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lbl != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(lbl, style: Theme.of(context).textTheme.bodyMedium),
          ),
        Slider(
          value: _linear,
          onChanged: (linear) => onChanged(_toValue(linear)),
        ),
      ],
    );
  }
}
