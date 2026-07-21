// lib/data/model/github_model_service.dart
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart' show CameraImage;
import 'package:flutter/services.dart';
import 'package:foodfo/service/i_image_classification_service.dart';
import 'package:foodfo/service/i_model_download_service.dart';
import 'package:foodfo/service/isolate_inference.dart';
import 'package:foodfo/utils/helper.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class GithubModelService implements IImageClassificationService {
  final IModelDownloadService _downloadService;

  GithubModelService(this._downloadService);

  late final IsolateInference isolateInference;

  final modelPath = 'assets/models/model.tflite';
  final labelsPath = 'assets/models/labels.txt';
  late final Interpreter interpreter;
  late final List<String> labels;
  late Tensor inputTensor;
  late Tensor outputTensor;

  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initHelper() async {
    if (_isInitialized) {
      logger.d('Github model service already initialized, skipping...');
      return;
    }

    if (!await _downloadService.isModelDownloaded()) {
      throw StateError(
        'Model not downloaded yet — call downloadModel() before initHelper()',
      );
    }

    await _loadLabels();
    await _loadModel();
    await _loadModel();
    isolateInference = IsolateInference();
    await isolateInference.start();

    _isInitialized = true;
    logger.d('Github model service initialized successfully');
  }

  Future<void> _loadModel() async {
    final modelPath = await _downloadService.getModelPath();
    final options = InterpreterOptions()
      ..useNnApiForAndroid = true
      ..useMetalDelegateForIOS = true;

    interpreter = Interpreter.fromFile(File(modelPath), options: options);
    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;

    logger.d('Github model loaded successfully from $modelPath');
    logger.d('Input shape: ${inputTensor.shape}');
    logger.d('Output shape: ${outputTensor.shape}');
  }

  Future<void> _loadLabels() async {
    final labelsPath = await _downloadService.getLabelsPath();
    final labelTxt = await File(labelsPath).readAsString();
    labels = labelTxt.split('\n').where((l) => l.trim().isNotEmpty).toList();
    logger.d('Loaded ${labels.length} labels from $labelsPath');
  }

  @override
  Future<Map<String, double>> inferenceCameraFrame(
    CameraImage cameraImage,
  ) async {
    var isolateModel = InferenceModel(
      cameraImage,
      interpreter.address,
      labels,
      inputTensor.shape,
      outputTensor.shape,
    );
    ReceivePort responsePort = ReceivePort();
    isolateInference.sendPort.send(
      isolateModel..responsePort = responsePort.sendPort,
    );
    return await responsePort.first;
  }

  @override
  Future<Map<String, double>> inferenceStaticImage(Uint8List imageBytes) async {
    var isolateModel = InferenceModel.fromBytes(
      imageBytes,
      interpreter.address,
      labels,
      inputTensor.shape,
      outputTensor.shape,
    );
    ReceivePort responsePort = ReceivePort();
    isolateInference.sendPort.send(
      isolateModel..responsePort = responsePort.sendPort,
    );
    return await responsePort.first;
  }

  @override
  Future<void> close() async {
    await isolateInference.close();
    interpreter.close();
  }
}
