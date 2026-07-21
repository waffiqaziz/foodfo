import 'package:flutter/material.dart';
import 'package:foodfo/model/model_release.dart';
import 'package:foodfo/service/github_model_service.dart';
import 'package:foodfo/service/i_model_download_service.dart';
import 'package:foodfo/theme/crop_image_theme.dart';
import 'package:foodfo/ui/custom_camera/custom_camera_page.dart';
import 'package:foodfo/ui/real_time_camera/real_time_camera_page.dart';
import 'package:foodfo/utils/helper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

enum ModelDownloadStatus {
  checking,
  notDownloaded,
  downloading,
  ready,
  updateAvailable,
  error,
}

class HomeProvider extends ChangeNotifier {
  final GithubModelService _githubModelService;
  final IModelDownloadService _downloadService;

  HomeProvider(this._githubModelService, this._downloadService) {
    _checkModelStatus();
  }

  ModelRelease? _pendingRelease;

  String? imagePath;
  XFile? imageFile;

  bool isAnalyzing = false;
  Map<String, num> classifications = {};
  String? errorMessage;
  bool hasError = false;

  ModelDownloadStatus modelStatus = ModelDownloadStatus.checking;
  double downloadProgress = 0.0;
  String? modelErrorMessage;

  bool get isModelReady => modelStatus == ModelDownloadStatus.ready;

  Future<void> _checkModelStatus() async {
    final downloaded = await _downloadService.isModelDownloaded();
    if (!downloaded) {
      modelStatus = ModelDownloadStatus.notDownloaded;
      notifyListeners();
      return;
    }

    await _initModelService(); // get inference working immediately, don't block on network

    // After the model is usable, quietly check for updates in the background.
    _checkForUpdateInBackground();
  }

  Future<void> _checkForUpdateInBackground() async {
    final hasUpdate = await _downloadService.hasUpdateAvailable();
    if (hasUpdate && modelStatus == ModelDownloadStatus.ready) {
      modelStatus = ModelDownloadStatus.updateAvailable;
      notifyListeners();
    }
  }

  Future<void> downloadModel() async {
    modelStatus = ModelDownloadStatus.downloading;
    downloadProgress = 0.0;
    modelErrorMessage = null;
    notifyListeners();

    try {
      final release =
          _pendingRelease ?? await _downloadService.fetchLatestRelease();
      await for (final progress in _downloadService.downloadModel(release)) {
        downloadProgress = progress;
        notifyListeners();
      }
      _pendingRelease = null;
      await _initModelService();
    } catch (e) {
      logger.e('Model download failed: $e');
      modelStatus = ModelDownloadStatus.error;
      modelErrorMessage =
          'Failed to download model. Please check your connection and try again.';
      notifyListeners();
    }
  }

  Future<void> _initModelService() async {
    try {
      await _githubModelService.initHelper();
      modelStatus = ModelDownloadStatus.ready;
      notifyListeners();
    } catch (e) {
      logger.e('Failed to initialize model service: $e');
      modelStatus = ModelDownloadStatus.error;
      modelErrorMessage = 'Failed to load model. Please try again.';
      notifyListeners();
    }
  }

  void retryModelSetup() {
    modelErrorMessage = null;
    // If the file's on disk but init failed, recheck
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

  // --- single identify-food entrypoint (replaces analyzeImageLocal/Cloud) ---
  Future<void> analyzeImage() async {
    if (imagePath == null || imageFile == null) return;
    if (!isModelReady) return;

    isAnalyzing = true;
    _resetAnalysisState();
    notifyListeners();

    try {
      final bytes = await imageFile!.readAsBytes();
      classifications = await _githubModelService.inferenceStaticImage(bytes);
      hasError = false;
      logger.d("Classification successful: $classifications");
    } catch (e) {
      logger.e('Classification failed: $e');
      hasError = true;
      errorMessage = 'Analysis failed: please try again';
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
    _githubModelService.close();
    super.dispose();
  }
}
