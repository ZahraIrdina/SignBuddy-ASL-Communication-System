import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/hand_landmarker_service.dart';
import '../services/text_to_speech_service.dart';
import '../services/tflite_service.dart';
import '../widgets/hand_landmark_painter.dart';

class DeafToHearingScreen extends StatefulWidget {
  const DeafToHearingScreen({super.key});

  @override
  State<DeafToHearingScreen> createState() => _DeafToHearingScreenState();
}

class _DeafToHearingScreenState extends State<DeafToHearingScreen> {
  final TfliteService _tfliteService = TfliteService();
  final TextToSpeechService _ttsService = TextToSpeechService();
  final HandLandmarkerService _handService = HandLandmarkerService();

  CameraController? _cameraController;

  bool _isCameraReady = false;
  bool _isLoading = false;
  bool _isStreaming = false;
  bool _isDetecting = false; // guard: skip frame if previous still processing
  bool _handDetected = false;

  Rect? _latestHandBox;
  List<Offset> _landmarks = [];

  String _currentPrediction = '-';
  String _currentConfidence = '-';
  String _sentence = '';
  String _selectedLanguage = 'en';

  final Map<String, String> _languages = {
    'English': 'en',
    'Bahasa Melayu': 'ms',
    '中文': 'zh-cn',
    'தமிழ்': 'ta',
  };

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // v1.0.0: initialize() is async
      await _handService.initialize();
      await _cameraController!.initialize();
      await _cameraController!.setFocusMode(FocusMode.auto);
      await _cameraController!.setExposureMode(ExposureMode.auto);

      if (!mounted) return;
      setState(() => _isCameraReady = true);
      await _startHandStream();
    } catch (e) {
      _showMessage('Camera error: $e');
    }
  }

  Future<void> _startHandStream() async {
    if (_cameraController == null || _isStreaming) return;
    _isStreaming = true;

    await _cameraController!.startImageStream((CameraImage image) async {
      // Skip frame if still processing previous one
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        // v1.0.0: detect() is async
        final result = await _handService.detect(
          image,
          _cameraController!.description.sensorOrientation,
          isFrontCamera: _cameraController!.description.lensDirection ==
              CameraLensDirection.front,
        );

        if (!mounted) return;
        setState(() {
          _handDetected = result.hasHand;
          _latestHandBox = result.normalizedBox;
          _landmarks = result.landmarks;
        });
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<void> _stopHandStream() async {
    if (_cameraController == null || !_isStreaming) return;
    await _cameraController!.stopImageStream();
    _isStreaming = false;
  }

  Future<void> _detectSign() async {
    if (!_isCameraReady || _cameraController == null) {
      _showMessage('Camera not ready.');
      return;
    }
    if (!_handDetected || _latestHandBox == null) {
      _showMessage('No hand detected. Show your hand clearly.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _stopHandStream();

      final image = await _cameraController!.takePicture();
      final result = await _tfliteService.predictImageCropped(
        image.path,
        _latestHandBox!,
      );

      final label = _extractLabel(result);
      final confidence = _extractConfidence(result);
      final confValue = double.tryParse(confidence.replaceAll('%', '')) ?? 0;

      if (!mounted) return;
      setState(() {
        _currentPrediction = confValue < 5 ? '-' : label;
        _currentConfidence = confidence;
      });

      if (confValue < 5) _showMessage('Please show sign clearly.');
    } catch (e) {
      _showMessage('Detection error: $e');
    } finally {
      try {
        await _startHandStream();
      } catch (_) {}
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _extractLabel(String result) =>
      result.contains('(') ? result.split('(').first.trim() : result.trim();

  String _extractConfidence(String result) {
    final match = RegExp(r'\((.*?)\)').firstMatch(result);
    return match?.group(1) ?? '-';
  }

  void _addLetter() {
    if (_currentPrediction == '-' || _currentPrediction.isEmpty) {
      _showMessage('Detect a sign first.');
      return;
    }
    setState(() => _sentence += _currentPrediction);
  }

  void _addSpace() {
    setState(() {
      if (_sentence.isNotEmpty && !_sentence.endsWith(' ')) _sentence += ' ';
    });
  }

  void _deleteLast() {
    if (_sentence.isEmpty) return;
    setState(() => _sentence = _sentence.substring(0, _sentence.length - 1));
  }

  void _clearSentence() {
    setState(() {
      _sentence = '';
      _currentPrediction = '-';
      _currentConfidence = '-';
    });
  }

  Future<void> _speakSentence() async {
    if (_sentence.trim().isEmpty) {
      _showMessage('Sentence is empty.');
      return;
    }
    await _ttsService.setLanguage(_selectedLanguage);
    await _ttsService.speak(_sentence.trim());
  }

  Widget _cameraBox() {
    if (!_isCameraReady || _cameraController == null) {
      return AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: OverflowBox(
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(3.141592653589793),
                  child: CameraPreview(_cameraController!),
                ),
                CustomPaint(
                  size: Size.infinite,
                  painter: HandLandmarkPainter(landmarks: _landmarks),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _handDetected
                          ? Colors.green.withValues(alpha: 0.85)
                          : Colors.red.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _handDetected ? 'Hand detected' : 'No hand',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F8),
      appBar: AppBar(
        title: const Text('Deaf-Mute → Hearing'),
        backgroundColor: const Color(0xFFFFF7F8),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            _languageSelector(),
            const SizedBox(height: 12),
            _cameraBox(),
            const SizedBox(height: 16),
            _infoCard(),
            const SizedBox(height: 12),
            _sentenceCard(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _detectSign,
              icon: const Icon(Icons.camera),
              label: Text(_isLoading ? 'Detecting...' : 'Detect Sign'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: _addLetter, child: const Text('Add'))),
                const SizedBox(width: 8),
                Expanded(
                    child: ElevatedButton(
                        onPressed: _addSpace, child: const Text('Space'))),
                const SizedBox(width: 8),
                Expanded(
                    child: ElevatedButton(
                        onPressed: _deleteLast, child: const Text('Delete'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearSentence,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _speakSentence,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Speak'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Prediction', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(_currentPrediction,
              style:
                  const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Confidence: $_currentConfidence',
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _sentenceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFFFEEF2),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sentence', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            _sentence.isEmpty ? 'No sentence yet' : _sentence,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _languageSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedLanguage,
          underline: const SizedBox(),
          items: _languages.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.value,
              child: Text(entry.key),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLanguage = value!;
            });
          },
        ),
      ),
    );
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _stopHandStream();
    _cameraController?.dispose();
    _handService.dispose();
    super.dispose();
  }
}
