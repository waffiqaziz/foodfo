import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:foodfo/utils/helper.dart';

class CustomCameraPage extends StatelessWidget {
  const CustomCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: const _CameraBody(),
    );
  }
}

class _CameraBody extends StatefulWidget {
  const _CameraBody();

  @override
  State<_CameraBody> createState() => _CameraBodyState();
}

class _CameraBodyState extends State<_CameraBody> with WidgetsBindingObserver {
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];
  CameraController? controller;
  bool _isBackCameraSelected = true;
  bool _isCapturing = false;

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await previousCameraController?.dispose();

    try {
      await cameraController.initialize();
      if (mounted) {
        setState(() {
          controller = cameraController;
          _isCameraInitialized = controller!.value.isInitialized;
        });
      }
    } catch (e) {
      logger.e('Error initializing camera: $e');
    }
  }

  void initCamera() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    if (_cameras.isNotEmpty) {
      await onNewCameraSelected(_cameras.first);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        title: const Text('Camera'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          if (_isCameraInitialized)
            ClipRect(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller!.value.previewSize!.height,
                    height: controller!.value.previewSize!.width,
                    child: CameraPreview(controller!),
                  ),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Flash button placeholder
                    IconButton(
                      icon: const Icon(Icons.flash_off, color: Colors.white),
                      iconSize: 32,
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),

                    // Capture Button
                    _CaptureButton(
                      isCapturing: _isCapturing,
                      onPressed: _isCameraInitialized ? _onCaptureImage : null,
                    ),

                    // Switch Camera Button
                    IconButton(
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                      ),
                      iconSize: 32,
                      onPressed: _cameras.length > 1 ? _onCameraSwitch : null,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Grid overlay (optional)
          if (_isCameraInitialized)
            IgnorePointer(
              child: CustomPaint(painter: _GridPainter(), size: Size.infinite),
            ),
        ],
      ),
    );
  }

  void _onCaptureImage() async {
    if (_isCapturing || controller == null) return;

    setState(() => _isCapturing = true);

    try {
      final image = await controller!.takePicture();
      if (mounted) {
        Navigator.of(context).pop(image);
      }
    } catch (e) {
      logger.e('Error capturing image: $e');
      setState(() => _isCapturing = false);
    }
  }

  void _onCameraSwitch() async {
    if (_cameras.length <= 1) return;

    setState(() => _isCameraInitialized = false);

    await onNewCameraSelected(_cameras[_isBackCameraSelected ? 1 : 0]);

    setState(() => _isBackCameraSelected = !_isBackCameraSelected);
  }
}

class _CaptureButton extends StatelessWidget {
  final bool isCapturing;
  final VoidCallback? onPressed;

  const _CaptureButton({required this.isCapturing, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCapturing ? Colors.red : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 2 / 3, 0),
      Offset(size.width * 2 / 3, size.height),
      paint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 2 / 3),
      Offset(size.width, size.height * 2 / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
