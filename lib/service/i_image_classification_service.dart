import 'dart:typed_data';

import 'package:camera/camera.dart';

abstract class IImageClassificationService {
  Future<void> initHelper();
  Future<Map<String, double>> inferenceStaticImage(Uint8List imageBytes);
  Future<Map<String, double>> inferenceCameraFrame(CameraImage cameraImage);
  Future<void> close();
  bool get isInitialized;
}
