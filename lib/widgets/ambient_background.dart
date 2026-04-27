// Subtle full-screen gradient and optional soft blob for a premium, minimal landing feel on web.

import 'package:flutter/material.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';

/// Paints a dark gradient "studio" background behind the main shell or auth form.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child, this.blobs = true});
  final Widget child;
  final bool blobs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.ambientGradient,
          stops: <double>[0, 0.5, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          if (blobs) ...<Widget>[
            _glow(Alignment.topLeft, 0.2, const Color(0xFFFF5C28), 1.0),
            _glow(Alignment.topRight, 0.1, const Color(0xFFC9E63C), 0.75),
            _glow(Alignment(-0.15, 0.4), 0.07, const Color(0xFFEA580C), 0.9),
            _glow(Alignment.bottomRight, 0.12, const Color(0xFFFF8F5C), 0.7),
          ],
          child,
        ],
      ),
    );
  }

  Widget _glow(Alignment a, double o, Color c, double s) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _GlowPaint(alignment: a, opacity: o, color: c, scale: s),
        ),
      ),
    );
  }
}

class _GlowPaint extends CustomPainter {
  const _GlowPaint({required this.alignment, required this.opacity, required this.color, required this.scale});
  final Alignment alignment;
  final double opacity;
  final Color color;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Offset(
      (alignment.x + 1) * 0.5 * size.width,
      (alignment.y + 1) * 0.5 * size.height,
    );
    final r = (size.width + size.height) * 0.22 * scale;
    final paint = Paint()..color = color.withValues(alpha: opacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(p, r, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowPaint oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.color != color;
  }
}
