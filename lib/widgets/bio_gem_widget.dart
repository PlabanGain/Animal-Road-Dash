import 'package:flutter/material.dart';

class BioGemWidget extends StatefulWidget {
  final double size;
  const BioGemWidget({this.size = 24.0, Key? key}) : super(key: key);

  @override
  State<BioGemWidget> createState() => _BioGemWidgetState();
}

class _BioGemWidgetState extends State<BioGemWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFCC).withOpacity(0.3 * _pulseAnimation.value),
                blurRadius: 10 * _pulseAnimation.value,
                spreadRadius: 1.0 * _pulseAnimation.value,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _BioGemPainter(pulseValue: _pulseAnimation.value),
            size: Size(widget.size, widget.size),
          ),
        );
      },
    );
  }
}

class _BioGemPainter extends CustomPainter {
  final double pulseValue;
  _BioGemPainter({required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset c = Offset(w / 2, h / 2);

    // Vertices of the hexagonal crystal pointing vertically
    final Offset v0 = Offset(w / 2, 0); // top
    final Offset v1 = Offset(w * 0.9, h * 0.25); // top-right
    final Offset v2 = Offset(w * 0.9, h * 0.75); // bottom-right
    final Offset v3 = Offset(w / 2, h); // bottom
    final Offset v4 = Offset(w * 0.1, h * 0.75); // bottom-left
    final Offset v5 = Offset(w * 0.1, h * 0.25); // top-left

    void drawFace(Offset p1, Offset p2, Color color) {
      final Path path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();
      final Paint paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    }

    // Split-tone light and shadow colors (bioluminescent cyan/emerald green)
    // The top faces catch neon light, the bottom faces stay in deep geometric shadow.
    // We adjust brightness slightly to simulate 3D gemstone cuts.
    final Color topLightColor = const Color(0xFF00FFCC).withOpacity(0.8 + 0.2 * pulseValue);
    final Color topMidColor = const Color(0xFF00E5B8).withOpacity(0.8 + 0.2 * pulseValue);
    final Color midColor = const Color(0xFF00B395);
    final Color shadowColor = const Color(0xFF006655);
    final Color deepShadowColor = const Color(0xFF004D40);
    final Color leftMidColor = const Color(0xFF00806A);

    drawFace(v5, v0, topLightColor); // Face 1: top-left
    drawFace(v0, v1, topMidColor);   // Face 2: top-right
    drawFace(v1, v2, midColor);      // Face 3: right
    drawFace(v2, v3, shadowColor);   // Face 4: bottom-right
    drawFace(v3, v4, deepShadowColor); // Face 5: bottom-left
    drawFace(v4, v5, leftMidColor);  // Face 6: left

    // Draw clean thin geometric lines on top of the cuts
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Path outline = Path()
      ..moveTo(v0.dx, v0.dy)
      ..lineTo(v1.dx, v1.dy)
      ..lineTo(v2.dx, v2.dy)
      ..lineTo(v3.dx, v3.dy)
      ..lineTo(v4.dx, v4.dy)
      ..lineTo(v5.dx, v5.dy)
      ..close();
    canvas.drawPath(outline, linePaint);

    canvas.drawLine(c, v0, linePaint);
    canvas.drawLine(c, v1, linePaint);
    canvas.drawLine(c, v2, linePaint);
    canvas.drawLine(c, v3, linePaint);
    canvas.drawLine(c, v4, linePaint);
    canvas.drawLine(c, v5, linePaint);
  }

  @override
  bool shouldRepaint(covariant _BioGemPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}
