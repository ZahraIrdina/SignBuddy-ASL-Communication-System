import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  Future<void> load() async {
    _interpreter ??= await Interpreter.fromAsset(
      'assets/models/asl_model.tflite',
    );

    if (_labels.isEmpty) {
      final labelData = await rootBundle.loadString('assets/models/labels.txt');

      _labels = labelData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }

  Future<String> predictImageCropped(
    String imagePath,
    Rect normalizedBox,
  ) async {
    await load();

    final bytes = await File(imagePath).readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      return 'Unable to read image';
    }

    final w = originalImage.width;
    final h = originalImage.height;

    final cropX = (normalizedBox.left * w).round().clamp(0, w - 1);
    final cropY = (normalizedBox.top * h).round().clamp(0, h - 1);
    final cropW = (normalizedBox.width * w).round().clamp(1, w - cropX);
    final cropH = (normalizedBox.height * h).round().clamp(1, h - cropY);

    final cropped = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );

    return _predictFromImage(cropped);
  }

  String _predictFromImage(img.Image inputImage) {
    final resizedImage = img.copyResize(
      inputImage,
      width: 64,
      height: 64,
    );

    final input = List.generate(
      1,
      (_) => List.generate(
        64,
        (y) => List.generate(
          64,
          (x) {
            final pixel = resizedImage.getPixel(x, y);

            // Do NOT divide by 255 here because model already has Rescaling(1/255)
            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    );

    final output = List.generate(
      1,
      (_) => List.filled(_labels.length, 0.0),
    );

    _interpreter!.run(input, output);

    final probabilities = output[0];

    int maxIndex = 0;
    double maxConfidence = probabilities[0];

    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        maxIndex = i;
      }
    }

    final label = maxIndex < _labels.length ? _labels[maxIndex] : 'Unknown';
    final confidence = (maxConfidence * 100).toStringAsFixed(2);

    return '$label ($confidence%)';
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
