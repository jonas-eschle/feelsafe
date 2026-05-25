import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Snap-stops applied to the logarithmic [TimingSlider].
///
/// Mirrors spec 04 §TimingSlider — 1s, 5s, 30s, 1min, 5min, 30min, 1h,
/// 6h, 1d, 1w, 1mo, 1y. The slider drag snaps to the nearest stop; the
/// numeric chip accepts any integer in `[minSeconds, maxSeconds]`.
const List<int> kTimingSliderStops = <int>[
  0,
  1,
  5,
  15,
  30,
  60,
  5 * 60,
  15 * 60,
  30 * 60,
  60 * 60,
  6 * 60 * 60,
  24 * 60 * 60,
  7 * 24 * 60 * 60,
  30 * 24 * 60 * 60,
  365 * 24 * 60 * 60,
];

/// Logarithmic-scale duration picker used wherever the user selects a
/// time interval (step wait/duration/grace, retry intervals, GPS
/// tracking, alarm ramp). Promoted from DE-1.
///
/// Backed by [kTimingSliderStops]; the numeric chip below the slider
/// opens a manual entry dialog. `onChanged` fires on slider release and
/// on numeric submit — never during drag.
class TimingSlider extends StatefulWidget {
  /// Creates a [TimingSlider].
  const TimingSlider({
    super.key,
    required this.valueSeconds,
    required this.onChanged,
    this.minSeconds = 0,
    this.maxSeconds = 365 * 24 * 60 * 60,
    this.label,
  }) : assert(minSeconds >= 0, 'minSeconds must be >= 0'),
       assert(maxSeconds > minSeconds, 'maxSeconds must be > minSeconds');

  /// Current value in seconds.
  final int valueSeconds;

  /// Called when the user commits a new value (slider release or chip
  /// submit). Never fires during drag.
  final ValueChanged<int> onChanged;

  /// Minimum allowed value. Defaults to 0.
  final int minSeconds;

  /// Maximum allowed value. Defaults to 1 year.
  final int maxSeconds;

  /// Optional label rendered above the slider.
  final String? label;

  @override
  State<TimingSlider> createState() => _TimingSliderState();
}

class _TimingSliderState extends State<TimingSlider> {
  late double _draft;

  @override
  void initState() {
    super.initState();
    _draft = _toLog(
      widget.valueSeconds.clamp(widget.minSeconds, widget.maxSeconds),
    );
  }

  @override
  void didUpdateWidget(covariant TimingSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.valueSeconds != oldWidget.valueSeconds) {
      _draft = _toLog(
        widget.valueSeconds.clamp(widget.minSeconds, widget.maxSeconds),
      );
    }
  }

  double _toLog(int seconds) {
    if (seconds <= 0) return 0;
    return math.log(seconds + 1);
  }

  int _fromLog(double logVal) {
    if (logVal <= 0) return 0;
    final raw = math.exp(logVal) - 1;
    return _snap(raw.round());
  }

  int _snap(int seconds) {
    final clamped = seconds.clamp(widget.minSeconds, widget.maxSeconds);
    int best = kTimingSliderStops.first;
    int bestDiff = (clamped - best).abs();
    for (final stop in kTimingSliderStops) {
      if (stop < widget.minSeconds || stop > widget.maxSeconds) continue;
      final diff = (clamped - stop).abs();
      if (diff < bestDiff) {
        best = stop;
        bestDiff = diff;
      }
    }
    return best;
  }

  String _format(int seconds) {
    if (seconds <= 0) return '0 s (immediate)';
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
    return '${d}d';
  }

  Future<void> _editManually() async {
    final controller = TextEditingController(text: '${widget.valueSeconds}');
    final newValue = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogCtx) => AlertDialog(
        title: const Text('Enter duration (seconds)'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: 's'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              if (parsed == null) {
                Navigator.of(dialogCtx).pop();
                return;
              }
              Navigator.of(
                dialogCtx,
              ).pop(parsed.clamp(widget.minSeconds, widget.maxSeconds));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newValue != null && newValue != widget.valueSeconds) {
      widget.onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final minLog = _toLog(widget.minSeconds);
    final maxLog = _toLog(widget.maxSeconds);
    final value = _draft.clamp(minLog, maxLog);
    final currentSeconds = _fromLog(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null)
          Text(widget.label!, style: textTheme.labelLarge),
        Slider(
          value: value,
          min: minLog,
          max: maxLog,
          onChanged: (double v) => setState(() => _draft = v),
          onChangeEnd: (double v) {
            final snapped = _fromLog(v);
            setState(() => _draft = _toLog(snapped));
            widget.onChanged(snapped);
          },
          label: _format(currentSeconds),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ActionChip(
            label: Text(_format(currentSeconds)),
            onPressed: _editManually,
          ),
        ),
      ],
    );
  }
}
