import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:foodfo/controller/real_time_classification_provider.dart';
import 'package:foodfo/ui/real_time_camera/camera_view.dart';
import 'package:foodfo/ui/real_time_camera/rounded_corner_border.dart';
import 'package:foodfo/ui/real_time_camera/classification_results_view.dart';
import 'package:foodfo/ui/real_time_camera/paused_state_view.dart';
import 'package:foodfo/ui/real_time_camera/scanning_state_view.dart';
import 'package:provider/provider.dart';

class RealtimeCameraPage extends StatefulWidget {
  const RealtimeCameraPage({super.key});

  @override
  State<RealtimeCameraPage> createState() => RealtimeCameraBodySPage();
}

class RealtimeCameraBodySPage extends State<RealtimeCameraPage> {
  bool _isStreamingEnabled = true;
  late RealTimeClassificationViewmodel _viewModel;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<RealTimeClassificationViewmodel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.resetClassification();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _handleClassification(CameraImage cameraImage) async {
    if (!_isDisposed && mounted) {
      await _viewModel.runClassification(cameraImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _isStreamingEnabled = false;
            Navigator.of(context).pop();
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        title: const Text('Real-time Food Detection'),
        actions: [
          IconButton(
            icon: Icon(_isStreamingEnabled ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              setState(() {
                _isStreamingEnabled = !_isStreamingEnabled;
              });
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview - CameraView handles all camera logic
          CameraView(
            onImage: _isStreamingEnabled ? _handleClassification : null,
          ),

          // Frame overlay
          Center(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 150,
                bottom: 260.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 350,
                child: CustomPaint(
                  painter: RoundedCornerBorderPainter(
                    color: Colors.white.withValues(alpha: 0.5),
                    strokeWidth: 2,
                    cornerSize: 40,
                    cornerRadius: 14,
                  ),
                ),
              ),
            ),
          ),

          // Results sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _RealtimeResultsSheet(
              isStreamingEnabled: _isStreamingEnabled,
            ),
          ),

          // Scanning banner
          if (_isStreamingEnabled)
            Positioned(
              top: 85,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Scanning for food...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RealtimeResultsSheet extends StatelessWidget {
  final bool isStreamingEnabled;

  const _RealtimeResultsSheet({required this.isStreamingEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.95),
            Colors.black.withValues(alpha: 0.85),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Consumer<RealTimeClassificationViewmodel>(
            builder: (context, viewModel, child) {
              final classifications = viewModel.classifications;

              if (!isStreamingEnabled) {
                return const PausedState();
              }

              if (classifications.isEmpty) {
                return const ScanningState();
              }

              return ClassificationResults(classifications: classifications);
            },
          ),
        ),
      ),
    );
  }
}
