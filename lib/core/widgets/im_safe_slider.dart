/// Swipe-to-confirm "I'm safe" slider.
///
/// Users drag a handle from left to right. Releasing at the far end
/// calls [onConfirmed]; releasing earlier snaps back.
library;

import 'package:flutter/material.dart';

import 'package:guardianangela/core/theme/theme_extensions.dart';

/// Slider users swipe to confirm.
class ImSafeSlider extends StatefulWidget {
  /// Creates a swipe-to-confirm slider.
  const ImSafeSlider({
    super.key,
    required this.label,
    required this.onConfirmed,
  });

  /// Label shown on the track.
  final String label;

  /// Called when the user completes the swipe.
  final VoidCallback onConfirmed;

  @override
  State<ImSafeSlider> createState() => _ImSafeSliderState();
}

class _ImSafeSliderState extends State<ImSafeSlider> {
  double _fraction = 0;
  static const double _threshold = 0.9;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 60,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colors.safe.withValues(alpha: 0.15 + _fraction * 0.4),
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Positioned(
                left: _fraction * (width - 60),
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) {
                    setState(() {
                      _fraction = (_fraction + d.delta.dx / (width - 60))
                          .clamp(0.0, 1.0);
                    });
                  },
                  onHorizontalDragEnd: (_) {
                    if (_fraction >= _threshold) {
                      widget.onConfirmed();
                    }
                    setState(() => _fraction = 0);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colors.safe,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: colors.safeOn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
