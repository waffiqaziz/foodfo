import 'package:flutter/material.dart';
import 'package:foodfo/service/image_classification_service.dart';
import 'package:foodfo/theme/crop_image_theme.dart';
import 'package:foodfo/ui/camera/custom_camera_page.dart';
import 'package:foodfo/ui/camera/real_time_camera_page.dart';
import 'package:foodfo/utils/helper.dart';
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

  Future<void> _cropImage(String sourcePath, CropImageTheme theme) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: theme.toolbarColor,
          toolbarWidgetColor: theme.toolbarWidgetColor,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          backgroundColor: theme.backgroundColor,
          activeControlsWidgetColor: theme.activeControlsColor,
          cropFrameColor: theme.cropFrameColor,
          cropGridColor: theme.cropGridColor,
          cropFrameStrokeWidth: 4,
          cropGridRowCount: 3,
          cropGridColumnCount: 3,
          cropGridStrokeWidth: 2,
          showCropGrid: true,
          hideBottomControls: false,
          dimmedLayerColor: theme.dimmedLayerColor,
          statusBarLight: theme.statusBarLight,
        ),
      ],
    );

    if (croppedFile != null) {
      final xFile = XFile(croppedFile.path);
      _setImage(xFile);
      _resetAnalysisState();
    }
  }

  Future<void> openCamera(CropImageTheme theme) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      await _cropImage(pickedFile.path, theme);
    }
  }

  Future<void> openGallery(CropImageTheme theme) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _cropImage(pickedFile.path, theme);
    }
  }

  Future<void> openCustomCamera(
    BuildContext context,
    CropImageTheme theme,
  ) async {
    final XFile? resultImageFile = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomCameraPage()),
    );

    if (resultImageFile != null) {
      await _cropImage(resultImageFile.path, theme);
    }
  }

  void openRealtimeCamera(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RealtimeCameraPage()),
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
