/// Timing slider with logarithmic snap stops, zero minimum, and
/// optional direct numeric entry.
///
/// Spec 11 §DE-1. Used for ChainStep timing fields (wait, duration,
/// grace), event-defaults timing, and any other places that pick a
/// duration in seconds.
///
/// The slider track is divided into discrete steps drawn from
/// [kTimingSnapStops] — a human-friendly list spanning
/// 0s → 1 year (31 536 000 s). Values between snap stops are
/// reachable only via direct numeric entry (tap the value chip).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Spec 11 §DE-1 — snap stops in seconds. Sorted ascending. Used by
/// [TimingSlider] as the discrete positions the slider can land on.
const List<int> kTimingSnapStops = <int>[
  // Seconds (10).
  0, 1, 2, 3, 5, 10, 15, 20, 30, 45,
  // Minutes (9).
  60, 120, 180, 300, 600, 900, 1200, 1800, 2700,
  // Hours (9).
  3600, 7200, 10800, 14400, 21600, 28800, 43200, 64800, 86400,
  // Days (10).
  172800, 259200, 432000, 604800, 1209600, 2592000,
  5184000, 7776000, 15552000, 31536000,
];

/// Maximum seconds enforced by direct numeric entry. Spec 11 §DE-1.
const int kTimingMaxSeconds = 31536000;

/// Formats [seconds] as a compact duration label.
///
/// 0 → "0s (immediate)", `<60` → "Ns", `<3600` → "Nm" or "Nm Ns",
/// `<86400` → "Nh" or "Nh Nm", and `>=86400` → "Nd" or "Nd Nh".
String formatTimingLabel(int seconds) {
  if (seconds <= 0) return '0s (immediate)';
  if (seconds < 60) return '${seconds}s';
  if (seconds < 3600) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }
  if (seconds < 86400) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
  final d = seconds ~/ 86400;
  final h = (seconds % 86400) ~/ 3600;
  return h == 0 ? '${d}d' : '${d}d ${h}h';
}

/// Returns the index in [kTimingSnapStops] closest to [value]. Used
/// to project an arbitrary value back onto the slider track.
int closestSnapStopIndex(int value) {
  if (value <= kTimingSnapStops.first) return 0;
  if (value >= kTimingSnapStops.last) return kTimingSnapStops.length - 1;
  var bestIdx = 0;
  var bestDelta = (kTimingSnapStops[0] - value).abs();
  for (var i = 1; i < kTimingSnapStops.length; i++) {
    final delta = (kTimingSnapStops[i] - value).abs();
    if (delta < bestDelta) {
      bestDelta = delta;
      bestIdx = i;
    }
  }
  return bestIdx;
}

/// Snap-stop slider for timing fields.
class TimingSlider extends StatelessWidget {
  /// Creates a timing slider.
  ///
  /// [label] — optional caption shown above the row.
  /// [seconds] — current value; snapped to the nearest stop on the
  /// track and editable to any value via direct numeric entry.
  /// [onChanged] — fires with the new value on slider release or
  /// after the user submits a typed value.
  /// [enabled] — disables the slider and chip when false.
  const TimingSlider({
    super.key,
    required this.seconds,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  /// Caption rendered above the slider row.
  final String? label;

  /// Current value in seconds.
  final int seconds;

  /// Fires with the new value on slider release or on dialog confirm.
  final ValueChanged<int> onChanged;

  /// When false, slider + chip ignore taps.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final lbl = label;
    final stops = kTimingSnapStops;
    final idx = closestSnapStopIndex(seconds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lbl != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(lbl, style: Theme.of(context).textTheme.bodyMedium),
          ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: idx.toDouble(),
                min: 0,
                max: (stops.length - 1).toDouble(),
                divisions: stops.length - 1,
                label: formatTimingLabel(stops[idx]),
                onChanged: enabled
                    ? (v) => onChanged(stops[v.round()])
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            ActionChip(
              label: Text(formatTimingLabel(seconds)),
              onPressed: enabled ? () => _editNumeric(context) : null,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _editNumeric(BuildContext context) async {
    final ctrl = TextEditingController(text: seconds.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter seconds'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            helperText: '0 to 31 536 000 (1 year)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final raw = int.tryParse(ctrl.text.trim());
              if (raw == null) {
                Navigator.of(ctx).pop();
                return;
              }
              final clamped = raw.clamp(0, kTimingMaxSeconds);
              Navigator.of(ctx).pop(clamped);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null) onChanged(result);
  }
}
