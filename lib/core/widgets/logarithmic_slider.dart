import 'dart:math';

import 'package:flutter/material.dart';

/// Converts a duration in seconds to a human-readable string.
/// Examples: "5s", "30s", "1 min", "5 min", "1 hr", "6 hrs", "24 hrs".
String humanDuration(int seconds) {
  if (seconds < 60) return '${seconds}s';
  if (seconds < 3600) {
    final mins = seconds ~/ 60;
    return '$mins min';
  }
  final hrs = seconds ~/ 3600;
  return hrs == 1 ? '1 hr' : '$hrs hrs';
}

/// A slider that maps a linear 0.0..1.0 screen position to a logarithmic
/// value range [min..max].
///
/// Formula: value = min * (max / min) ^ t, where t in [0..1].
class LogarithmicSlider extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;

  /// Builds a label string from the current value. Defaults to
  /// [humanDuration] applied to the rounded integer value.
  final String Function(double value)? labelBuilder;

  const LogarithmicSlider({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.labelBuilder,
  });

  /// Convert a logarithmic value to a linear 0..1 position.
  double _valueToT(double v) {
    final clamped = v.clamp(min, max);
    if (min == max) return 0;
    return log(clamped / min) / log(max / min);
  }

  /// Convert a linear 0..1 position to a logarithmic value.
  double _tToValue(double t) {
    return min * pow(max / min, t).toDouble();
  }

  String _defaultLabel(double v) => humanDuration(v.round());

  @override
  Widget build(BuildContext context) {
    final label = (labelBuilder ?? _defaultLabel)(value);
    final t = _valueToT(value);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: t.clamp(0.0, 1.0),
          onChanged: (newT) => onChanged(_tToValue(newT)),
          label: label,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (labelBuilder ?? _defaultLabel)(min),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                (labelBuilder ?? _defaultLabel)(max),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
