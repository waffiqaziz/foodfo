import 'package:flutter/material.dart';
import 'package:foodfo/service/asset_model_service.dart';
import 'package:foodfo/service/firebase_model_service.dart';
import 'package:foodfo/theme/crop_image_theme.dart';
import 'package:foodfo/ui/camera/custom_camera_page.dart';
import 'package:foodfo/ui/camera/real_time_camera_page.dart';
import 'package:foodfo/utils/helper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomeProvider extends ChangeNotifier {
  final AssetModelService _assetModelService;
  final FirebaseModelService _firebaseModelService;

  HomeProvider(this._assetModelService, this._firebaseModelService) {
    _initializeServices();
  }

  String? imagePath;
  XFile? imageFile;

  bool isAnalyzing = false;
  Map<String, num> classifications = {};
  String? errorMessage;
  bool hasError = false;

  Future<void> _initializeServices() async {
    try {
      // Initialize both services
      await _assetModelService.initHelper();
      await _firebaseModelService.initHelper();
    } catch (e) {
      logger.e('Failed to initialize services: $e');
    }
  }

  void _setImage(XFile? value) {
    imageFile = value;
    imagePath = value?.path;
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

  // analyze with local asset model
  Future<void> analyzeImageLocal() async {
    if (imagePath == null || imageFile == null) return;

    isAnalyzing = true;
    _resetAnalysisState();
    notifyListeners();

    try {
      final bytes = await imageFile!.readAsBytes();
      classifications = await _assetModelService.inferenceStaticImage(bytes);
      hasError = false;
      logger.d("Local classification successful: $classifications");
    } catch (e) {
      logger.e('Local classification failed: $e');
      hasError = true;
      errorMessage = 'Local analysis failed: please try again';
      classifications = {};
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }

  // // analyze with cloud firebase asset model
  Future<void> analyzeImageCloud() async {
    if (imagePath == null || imageFile == null) return;

    isAnalyzing = true;
    _resetAnalysisState();
    notifyListeners();

    try {
      final bytes = await imageFile!.readAsBytes();
      classifications = await _firebaseModelService.inferenceStaticImage(bytes);
      hasError = false;
      logger.d("Cloud classification successful: $classifications");
    } catch (e) {
      logger.e('Cloud classification failed: $e');
      hasError = true;
      errorMessage = 'Cloud analysis failed: please check connection';
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
    _assetModelService.close();
    _firebaseModelService.close();
    super.dispose();
  }
}
