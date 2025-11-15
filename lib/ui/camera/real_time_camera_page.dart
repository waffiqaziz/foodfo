import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:food_fo/controller/image_classification_provider.dart';
import 'package:food_fo/service/image_classification_service.dart';
import 'package:food_fo/ui/camera/camera_view.dart';
import 'package:food_fo/ui/camera/rounded_corner_border.dart';
import 'package:provider/provider.dart';

class RealtimeCameraPage extends StatelessWidget {
  const RealtimeCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ImageClassificationViewmodel(
        context.read<ImageClassificationService>(),
      ),
      child: Theme(
        data: ThemeData.dark(useMaterial3: true),
        child: const _RealtimeCameraBody(),
      ),
    );
  }
}

class _RealtimeCameraBody extends StatefulWidget {
  const _RealtimeCameraBody();

  @override
  State<_RealtimeCameraBody> createState() => _RealtimeCameraBodyState();
}

class _RealtimeCameraBodyState extends State<_RealtimeCameraBody> {
  bool _isStreamingEnabled = true;
  late ImageClassificationViewmodel _viewModel;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ImageClassificationViewmodel>();
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
        backgroundColor: Colors.black.withValues(alpha: 0.3),
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
          child: Consumer<ImageClassificationViewmodel>(
            builder: (context, viewModel, child) {
              final classifications = viewModel.classifications;

              if (!isStreamingEnabled) {
                return const _PausedState();
              }

              if (classifications.isEmpty) {
                return const _ScanningState();
              }

              return _ClassificationResults(classifications: classifications);
            },
          ),
        ),
      ),
    );
  }
}

class _ScanningState extends StatelessWidget {
  const _ScanningState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Point camera at food',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Detection will appear here',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _PausedState extends StatelessWidget {
  const _PausedState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.pause_circle_outline,
          size: 48,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 12),
        Text(
          'Detection Paused',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap play to resume',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ClassificationResults extends StatelessWidget {
  final Map<String, num> classifications;

  const _ClassificationResults({required this.classifications});

  @override
  Widget build(BuildContext context) {
    final entries = classifications.entries.toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Detected',
                    style: TextStyle(
                      color: Colors.green.shade200,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Icon(
              Icons.restaurant,
              size: 20,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Top prediction
        if (entries.isNotEmpty) ...[
          Text(
            _formatFoodName(entries[0].key),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ConfidenceBar(confidence: entries[0].value.toDouble()),
              ),
              const SizedBox(width: 12),
              Text(
                '${(entries[0].value * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],

        // Other predictions
        if (entries.length > 1) ...[
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 12),
          ...entries
              .skip(1)
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatFoodName(entry.key),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${(entry.value * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ],
    );
  }

  String _formatFoodName(String name) {
    return name
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}

class _ConfidenceBar extends StatelessWidget {
  final double confidence;

  const _ConfidenceBar({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = confidence * 100;
    Color barColor;

    if (percentage >= 70) {
      barColor = Colors.green;
    } else if (percentage >= 40) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.red;
    }

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: confidence.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [barColor.withValues(alpha: 0.7), barColor],
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: barColor.withValues(alpha: 0.4), blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}
