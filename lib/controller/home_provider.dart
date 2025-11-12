import 'package:flutter/material.dart';
import 'package:food_fo/model/upload_response.dart';
import 'package:food_fo/service/http_service.dart';
import 'package:food_fo/ui/camera/camera_page.dart';
import 'package:food_fo/utils/helper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomeProvider extends ChangeNotifier {
  final HttpService _httpService;
  HomeProvider(this._httpService);

  String? imagePath;
  XFile? imageFile;

  bool isUploading = false;
  String? message;
  UploadResponse? uploadResponse;
  String? errorMessage;
  bool hasError = false;

  void _setImage(XFile? value) {
    imageFile = value;
    imagePath = value?.path;
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
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          // Modern Android styling
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
      // Convert CroppedFile to XFile
      final xFile = XFile(croppedFile.path);
      _setImage(xFile);
      _resetUploadState();
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

  void upload() async {
    if (imagePath == null || imageFile == null) return;

    isUploading = true;
    _resetUploadState();
    notifyListeners();

    try {
      final bytes = await imageFile!.readAsBytes();
      final filename = imageFile!.name;

      uploadResponse = await _httpService.uploadDocument(bytes, filename);
      message = uploadResponse?.message;
      logger.d("Success: ${uploadResponse?.message}");
      hasError = false;
    } catch (e) {
      logger.d(e.toString());
      hasError = true;
      errorMessage = 'Upload failed: please try again later';
      uploadResponse = null;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  void _resetUploadState() {
    message = null;
    uploadResponse = null;
    errorMessage = null;
    hasError = false;
    notifyListeners();
  }

  void clearError() {
    hasError = false;
    errorMessage = null;
    notifyListeners();
  }
}
