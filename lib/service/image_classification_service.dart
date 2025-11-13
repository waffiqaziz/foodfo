import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:food_fo/service/isolate_inference.dart';
import 'package:food_fo/utils/helper.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassificationService {
  late final IsolateInference isolateInference;

  final modelPath = 'assets/models/model.tflite';
  final labelsPath = 'assets/models/labels.txt';
  late final Interpreter interpreter;
  late final List<String> labels;
  late Tensor inputTensor;
  late Tensor outputTensor;

  Future<void> initHelper() async {
    await _loadLabels();
    await _loadModel();
    isolateInference = IsolateInference();
    await isolateInference.start();
  }

  Future<void> _loadModel() async {
    final options = InterpreterOptions()
      ..useNnApiForAndroid = true
      ..useMetalDelegateForIOS = true;
    
    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;
    
    logger.d('Interpreter loaded successfully');
    logger.d('Input shape: ${inputTensor.shape}');
    logger.d('Output shape: ${outputTensor.shape}');
  }

  Future<void> _loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelsPath);
    labels = labelTxt.split('\n').where((label) => label.trim().isNotEmpty).toList();
    logger.d('Loaded ${labels.length} labels');
  }

  // For camera stream (real-time classification)
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
    
    var results = await responsePort.first;
    return results;
  }

  // For static images (gallery/camera capture) - runs in isolate
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
    
    var results = await responsePort.first;
    return results;
  }

  Future<void> close() async {
    await isolateInference.close();
    interpreter.close();
  }
}
