/// Guardian-Angela logo widget — minimal shield + halo rendered via
/// [CustomPainter].
///
/// Used on the onboarding welcome page, the about screen, and
/// anywhere the brand needs to appear.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Simple shield + halo logo for Guardian Angela.
class GuardianAngelaLogo extends StatelessWidget {
  /// Creates a logo.
  const GuardianAngelaLogo({super.key, this.size = 96});

  /// Outer size in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(
          shieldColor: scheme.primary,
          haloColor: scheme.secondary,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.shieldColor, required this.haloColor});

  final Color shieldColor;
  final Color haloColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Halo ring.
    final halo = Paint()
      ..color = haloColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05;
    canvas.drawCircle(
      Offset(w / 2, h * 0.2),
      w * 0.12,
      halo,
    );

    // Shield body.
    final shield = Paint()
      ..color = shieldColor
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, h * 0.28)
      ..lineTo(w * 0.18, h * 0.42)
      ..lineTo(w * 0.18, h * 0.65)
      ..quadraticBezierTo(w * 0.18, h * 0.92, center.dx, h * 0.96)
      ..quadraticBezierTo(w * 0.82, h * 0.92, w * 0.82, h * 0.65)
      ..lineTo(w * 0.82, h * 0.42)
      ..close();
    canvas.drawPath(path, shield);

    // Halo centerline (thin wing hint).
    final wing = Paint()
      ..color = haloColor.withValues(alpha: 0.7)
      ..strokeWidth = w * 0.025
      ..style = PaintingStyle.stroke;
    final wingSpan = w * 0.35;
    canvas.drawLine(
      Offset(center.dx - wingSpan, h * 0.38),
      Offset(center.dx + wingSpan, h * 0.38),
      wing,
    );

    // Subtle ring around the shield.
    final ring = Paint()
      ..color = shieldColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.02;
    canvas.drawCircle(center, w * 0.48, ring);
    // Unused variable silence for `math`.
    math.pi.toString();
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) =>
      old.shieldColor != shieldColor || old.haloColor != haloColor;
}
