import 'package:flutter/material.dart';
import 'package:food_fo/service/image_classification_service.dart';
import 'package:food_fo/ui/camera/camera_page.dart';
import 'package:food_fo/ui/camera/real_time_camera_page.dart';
import 'package:food_fo/utils/helper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomeProvider extends ChangeNotifier {
  final ImageClassificationService _classificationService;

  HomeProvider(this._classificationService) {
    _initializeService();
  }

  String? imagePath;
  XFile? imageFile;

  bool isAnalyzing = false;
  Map<String, num> classifications = {};
  String? errorMessage;
  bool hasError = false;

  Future<void> _initializeService() async {
    try {
      await _classificationService.initHelper();
    } catch (e) {
      logger.e('Failed to initialize classification service: $e');
    }
  }

  void _setImage(XFile? value) {
    imageFile = value;
    imagePath = value?.path;
    // Clear previous results when new image is selected
    classifications = {};
    notifyListeners();
  }

  Future<void> _cropImage(String sourcePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: const Color(0xFF6750A4),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          backgroundColor: Colors.black,
          activeControlsWidgetColor: const Color(0xFF6750A4),
          cropFrameColor: const Color(0xFF6750A4),
          cropGridColor: Colors.white38,
          cropFrameStrokeWidth: 4,
          cropGridRowCount: 3,
          cropGridColumnCount: 3,
          cropGridStrokeWidth: 2,
          showCropGrid: true,
          hideBottomControls: false,
          dimmedLayerColor: Colors.black.withValues(alpha: 0.8),
          statusBarLight: true,
        ),
      ],
    );

    if (croppedFile != null) {
      final xFile = XFile(croppedFile.path);
      _setImage(xFile);
      _resetAnalysisState();
    }
  }

  void openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      await _cropImage(pickedFile.path);
    }
  }

  void openGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _cropImage(pickedFile.path);
    }
  }

  void openCustomCamera(BuildContext context) async {
    final XFile? resultImageFile = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraPage()),
    );

    if (resultImageFile != null) {
      await _cropImage(resultImageFile.path);
    }
  }

  void openRealtimeCamera(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RealtimeCameraPage()),
    );
  }

  Future<void> analyzeImage() async {
    if (imagePath == null || imageFile == null) return;

    isAnalyzing = true;
    _resetAnalysisState();
    notifyListeners();

    try {
      // Read image bytes
      final bytes = await imageFile!.readAsBytes();

      // Run classification using isolate (prevent freeze UI)
      classifications = await _classificationService.inferenceStaticImage(
        bytes,
      );

      hasError = false;
      logger.d("Classification successful: $classifications");
    } catch (e) {
      logger.e('Classification failed: $e');
      hasError = true;
      errorMessage = 'Analysis failed: please try again later';
      classifications = {};
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }

  void _resetAnalysisState() {
    classifications = {};
    errorMessage = null;
    hasError = false;
    notifyListeners();
  }

  void clearError() {
    hasError = false;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _classificationService.close();
    super.dispose();
  }
}
