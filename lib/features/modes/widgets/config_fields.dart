/// Reusable field-editor widgets shared by the step-config UIs.
///
/// Used by [EventSpecificConfig] (type-specific config) and
/// `StepConfigPanel` (timing + retry config) so the editors render
/// identically in the Mode Editor and the Event Defaults screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A labelled dropdown over an enum-like list of [values].
class EnumDropdownField<T> extends StatelessWidget {
  /// Creates an [EnumDropdownField].
  const EnumDropdownField({
    super.key,
    required this.label,
    required this.values,
    required this.value,
    required this.labelFor,
    required this.onChanged,
  });

  /// Field label.
  final String label;

  /// Selectable values.
  final List<T> values;

  /// Currently selected value.
  final T value;

  /// Maps a value to its display string.
  final String Function(T) labelFor;

  /// Called with the newly selected value.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            items: <DropdownMenuItem<T>>[
              for (final v in values)
                DropdownMenuItem<T>(value: v, child: Text(labelFor(v))),
            ],
            onChanged: (T? v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }
}

/// A labelled slider over a continuous [min]–[max] range.
class DoubleSliderField extends StatelessWidget {
  /// Creates a [DoubleSliderField].
  const DoubleSliderField({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  /// Field label.
  final String label;

  /// Current value.
  final double value;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Called with the new value as the slider moves.
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('$label: ${value.toStringAsFixed(2)}'),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// A labelled integer stepper with −/+ buttons, bounded to [min]–[max].
///
/// Best for small ranges (retry counts, short durations). For larger
/// ranges use [IntTextField].
class IntSpinnerField extends StatelessWidget {
  /// Creates an [IntSpinnerField].
  const IntSpinnerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    required this.max,
  });

  /// Field label.
  final String label;

  /// Current value.
  final int value;

  /// Called with the new value.
  final ValueChanged<int> onChanged;

  /// Minimum value (inclusive).
  final int min;

  /// Maximum value (inclusive).
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value <= min ? null : () => onChanged(value - 1),
          ),
          Text(value.toString()),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value >= max ? null : () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

/// A labelled free-text field that commits on submit / blur.
class LabeledTextField extends StatefulWidget {
  /// Creates a [LabeledTextField].
  const LabeledTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// Field label.
  final String label;

  /// Current text.
  final String value;

  /// Called with the new text when editing completes.
  final ValueChanged<String> onChanged;

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late final TextEditingController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant LabeledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != _ctl.text) {
      _ctl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: _ctl,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: widget.onChanged,
        onEditingComplete: () => widget.onChanged(_ctl.text),
      ),
    );
  }
}

/// A labelled integer text field, min-clamped to [min].
///
/// Suited to wide ranges (the wait/duration/grace timing values) where a
/// −/+ stepper would be impractical. Empty or non-numeric input commits as
/// [min]. Commits on submit / blur.
class IntTextField extends StatefulWidget {
  /// Creates an [IntTextField].
  const IntTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
  });

  /// Field label.
  final String label;

  /// Current value.
  final int value;

  /// Called with the parsed, clamped value when editing completes.
  final ValueChanged<int> onChanged;

  /// Minimum value (inclusive).
  final int min;

  @override
  State<IntTextField> createState() => _IntTextFieldState();
}

class _IntTextFieldState extends State<IntTextField> {
  late final TextEditingController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant IntTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        widget.value.toString() != _ctl.text) {
      _ctl.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _commit(String raw) {
    final parsed = int.tryParse(raw) ?? widget.min;
    final clamped = parsed < widget.min ? widget.min : parsed;
    if (clamped.toString() != _ctl.text) _ctl.text = clamped.toString();
    widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: _ctl,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: _commit,
        onEditingComplete: () => _commit(_ctl.text),
      ),
    );
  }
}
