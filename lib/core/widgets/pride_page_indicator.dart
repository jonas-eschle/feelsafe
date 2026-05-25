import 'package:flutter/material.dart';

/// Pride-flag colored page indicator used by onboarding and any
/// horizontally paginated flow.
///
/// Active page renders a pride-gradient bar; inactive pages are muted
/// dots. Reuses Material's color scheme so it adapts to dark mode.
class PridePageIndicator extends StatelessWidget {
  /// Creates a [PridePageIndicator].
  const PridePageIndicator({
    super.key,
    required this.currentIndex,
    required this.pageCount,
  }) : assert(pageCount > 0, 'pageCount must be > 0'),
       assert(
         currentIndex >= 0 && currentIndex < pageCount,
         'currentIndex must be within [0, pageCount)',
       );

  /// Index of the currently visible page.
  final int currentIndex;

  /// Total number of pages.
  final int pageCount;

  static const List<Color> _prideColors = <Color>[
    Color(0xFFE40303),
    Color(0xFFFF8C00),
    Color(0xFFFFED00),
    Color(0xFF008026),
    Color(0xFF004CFF),
    Color(0xFF732982),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < pageCount; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 8,
              width: i == currentIndex ? 32 : 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: i == currentIndex
                    ? const LinearGradient(colors: _prideColors)
                    : null,
                color: i == currentIndex
                    ? null
                    : scheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
      ],
    );
  }
}
