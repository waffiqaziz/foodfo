import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:foodfo/service/firebase_model_service.dart';

class RealTimeClassificationViewmodel extends ChangeNotifier {
  final FirebaseModelService _firebaseModelService;

  RealTimeClassificationViewmodel(this._firebaseModelService) {
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

  Future<void> resetClassification() async {
    _classifications = {};
    notifyListeners();
  }
}
