import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:foodfo/service/firebase_model_service.dart';

class ImageClassificationViewmodel extends ChangeNotifier {
  final FirebaseModelService _firebaseModelService;

  ImageClassificationViewmodel(this._firebaseModelService) {
    _firebaseModelService.initHelper();
  }

  Map<String, num> _classifications = {};
  Map<String, num> get classifications => Map.fromEntries(
    (_classifications.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value)))
        .reversed
        .take(3),
  );

  Future<void> runClassification(CameraImage camera) async {
    _classifications = await _firebaseModelService.inferenceCameraFrame(camera);
    notifyListeners();
  }
}
