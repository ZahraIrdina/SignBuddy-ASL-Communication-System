import 'package:flutter/material.dart';

class HandLandmarkPainter extends CustomPainter {
  final List<Offset> landmarks;

  HandLandmarkPainter({required this.landmarks});

  static const Color _thumbColor = Color(0xFFFFD700); // yellow
  static const Color _indexColor = Color(0xFF00CC44); // green
  static const Color _middleColor = Color(0xFFFF4444); // red
  static const Color _ringColor = Color(0xFF9B59B6); // purple
  static const Color _pinkyColor = Color(0xFFFFE4A0); // cream
  static const Color _palmColor = Color(0xFF888888); // gray

  static const List<(List<int>, Color)> _coloredConnections = [
    // Palm
    ([0, 1], _thumbColor),
    ([0, 5], _palmColor),
    ([0, 17], _palmColor),
    ([5, 9], _palmColor),
    ([9, 13], _palmColor),
    ([13, 17], _palmColor),
    // Thumb
    ([1, 2], _thumbColor),
    ([2, 3], _thumbColor),
    ([3, 4], _thumbColor),
    // Index
    ([5, 6], _indexColor),
    ([6, 7], _indexColor),
    ([7, 8], _indexColor),
    // Middle
    ([9, 10], _middleColor),
    ([10, 11], _middleColor),
    ([11, 12], _middleColor),
    // Ring
    ([13, 14], _ringColor),
    ([14, 15], _ringColor),
    ([15, 16], _ringColor),
    // Pinky
    ([17, 18], _pinkyColor),
    ([18, 19], _pinkyColor),
    ([19, 20], _pinkyColor),
  ];

  static Color _dotColor(int i) {
    if (i >= 1 && i <= 4) return _thumbColor;
    if (i >= 5 && i <= 8) return _indexColor;
    if (i >= 9 && i <= 12) return _middleColor;
    if (i >= 13 && i <= 16) return _ringColor;
    if (i >= 17 && i <= 20) return _pinkyColor;
    return _palmColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    // landmarks are already in 0.0–1.0 screen-space from the package.
    // Simply multiply by the widget size — no aspect-ratio math needed
    // because the painter is drawn at Size.infinite over CameraPreview.
    Offset map(Offset p) => Offset(p.dx * size.width, p.dy * size.height);

    for (final (pair, color) in _coloredConnections) {
      if (pair[0] < landmarks.length && pair[1] < landmarks.length) {
        canvas.drawLine(
          map(landmarks[pair[0]]),
          map(landmarks[pair[1]]),
          Paint()
            ..color = color
            ..strokeWidth = 3.0
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
      }
    }

    for (int i = 0; i < landmarks.length; i++) {
      final pt = map(landmarks[i]);
      canvas.drawCircle(
          pt,
          6,
          Paint()
            ..color = _dotColor(i)
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          pt,
          6,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.6)
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant HandLandmarkPainter old) =>
      old.landmarks != landmarks;
}
