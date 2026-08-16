import 'package:camera/camera.dart';
class CameraService {
  CameraController? controller;
  Future<void> init() async {
    final cams = await availableCameras();
    controller = CameraController(cams.first, ResolutionPreset.medium, enableAudio: false);
    await controller!.initialize();
  }
  Future<XFile?> capture() async => controller?.takePicture();
  Future<void> dispose() async => controller?.dispose();
}
