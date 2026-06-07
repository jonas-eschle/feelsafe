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

/// A multi-line message-template editor with placeholder-insert chips.
///
/// Edits a nullable template string (spec 02 §smsContact Message Template):
/// an empty field commits as `null`, meaning "use the seeded default
/// template"; any non-empty text overrides it. Each chip in [placeholders]
/// inserts its token (e.g. `{name}`, `{location}`) at the caret and commits
/// immediately, mirroring the spec's "insert placeholder buttons" (02:304).
class MessageTemplateField extends StatefulWidget {
  /// Creates a [MessageTemplateField].
  const MessageTemplateField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.placeholders,
    required this.onChanged,
  });

  /// Field label.
  final String label;

  /// Hint shown when the field is empty (describes the default behaviour).
  final String hint;

  /// Current template, or null to use the seeded default.
  final String? value;

  /// The placeholder tokens offered as insert chips, in display order.
  final List<String> placeholders;

  /// Called with the new template when editing completes; null = use default.
  final ValueChanged<String?> onChanged;

  @override
  State<MessageTemplateField> createState() => _MessageTemplateFieldState();
}

class _MessageTemplateFieldState extends State<MessageTemplateField> {
  late final TextEditingController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(covariant MessageTemplateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String incoming = widget.value ?? '';
    if (oldWidget.value != widget.value && incoming != _ctl.text) {
      _ctl.text = incoming;
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  /// Commits the current text: blank → null (use default), else the text.
  void _commit() {
    final String text = _ctl.text;
    widget.onChanged(text.trim().isEmpty ? null : text);
  }

  /// Inserts [token] at the caret (or appends), then commits.
  void _insert(String token) {
    final TextSelection sel = _ctl.selection;
    final String text = _ctl.text;
    final int start = sel.start < 0 ? text.length : sel.start;
    final int end = sel.end < 0 ? text.length : sel.end;
    final String next = text.replaceRange(start, end, token);
    _ctl.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + token.length),
    );
    _commit();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _ctl,
            minLines: 3,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              alignLabelWithHint: true,
            ),
            onEditingComplete: _commit,
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
              _commit();
            },
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              for (final String token in widget.placeholders)
                ActionChip(label: Text(token), onPressed: () => _insert(token)),
            ],
          ),
        ],
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
