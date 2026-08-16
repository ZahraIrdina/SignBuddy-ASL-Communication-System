import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

class HandDetectionResult {
  final bool hasHand;
  final Rect? normalizedBox;
  final List<Offset> landmarks;

  HandDetectionResult({
    required this.hasHand,
    this.normalizedBox,
    this.landmarks = const [],
  });
}

class HandLandmarkerService {
  HandLandmarkerPlugin? _plugin;
  bool _busy = false;

  Future<void> initialize() async {
    _plugin ??= await HandLandmarkerPlugin.create();
  }

  Future<HandDetectionResult> detect(
    CameraImage image,
    int sensorOrientation, {
    bool isFrontCamera = false,
  }) async {
    if (_busy || _plugin == null) {
      return HandDetectionResult(hasHand: false);
    }

    _busy = true;

    try {
      final hands = await _plugin!.detect(image, sensorOrientation);

      if (hands.isEmpty) {
        return HandDetectionResult(hasHand: false);
      }

      final rawLandmarks = hands.first.landmarks;

      final points = rawLandmarks.map((lm) {
        final x = lm.x.toDouble();
        final y = lm.y.toDouble();

        // Fix: plugin returns landscape landmark while camera preview is portrait.
        if (isFrontCamera) {
          return Offset(y, 1 - x);
        } else {
          return Offset(y, 1 - x);
        }
      }).toList();

      double minX = 1.0;
      double minY = 1.0;
      double maxX = 0.0;
      double maxY = 0.0;

      for (final p in points) {
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy > maxY) maxY = p.dy;
      }

      const margin = 0.12;

      final box = Rect.fromLTRB(
        (minX - margin).clamp(0.0, 1.0),
        (minY - margin).clamp(0.0, 1.0),
        (maxX + margin).clamp(0.0, 1.0),
        (maxY + margin).clamp(0.0, 1.0),
      );

      return HandDetectionResult(
        hasHand: true,
        normalizedBox: box,
        landmarks: points,
      );
    } catch (e) {
      debugPrint('Hand landmark error: $e');
      return HandDetectionResult(hasHand: false);
    } finally {
      _busy = false;
    }
  }

  Future<void> dispose() async {
    await _plugin?.dispose();
    _plugin = null;
  }
}
