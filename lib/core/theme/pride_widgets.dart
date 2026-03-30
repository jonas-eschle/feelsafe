import 'package:flutter/material.dart';
import 'app_colors.dart';

/// A thin pride-gradient divider used as a section separator.
class PrideDivider extends StatelessWidget {
  const PrideDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: const BoxDecoration(gradient: AppColors.prideGradient),
    );
  }
}

/// A thin pride-gradient progress bar.
class PrideProgressBar extends StatelessWidget {
  /// Progress value from 0.0 to 1.0.
  final double progress;

  const PrideProgressBar({super.key, this.progress = 1.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
      ),
    );
  }

  // Custom paint version for the gradient effect.
  // ignore: unused_element
  static Widget gradient({double progress = 1.0, Key? key}) {
    return _PrideProgressBarGradient(progress: progress, key: key);
  }
}

class _PrideProgressBarGradient extends StatelessWidget {
  final double progress;

  const _PrideProgressBarGradient({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              Container(
                width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                decoration: const BoxDecoration(
                  gradient: AppColors.prideGradient,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Page indicator dots where each dot uses a different pride color.
class PridePageIndicator extends StatelessWidget {
  final int count;
  final int current;

  const PridePageIndicator({
    super.key,
    required this.count,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.prideColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isCurrent = index == current;
        final color = colors[index % colors.length];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isCurrent ? color : color.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}

/// A PreferredSize widget that shows a thin pride gradient line,
/// for use as AppBar's `bottom` property.
class PrideAppBarBottom extends StatelessWidget implements PreferredSizeWidget {
  const PrideAppBarBottom({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(2);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: const BoxDecoration(gradient: AppColors.prideGradient),
    );
  }
}
