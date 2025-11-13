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

  // For static images (gallery/camera capture)
  Future<Map<String, double>> inferenceImage(
    List<List<List<num>>> imageMatrix,
  ) async {
    try {
      // Prepare input
      final input = [imageMatrix];
      final output = [List<int>.filled(outputTensor.shape[1], 0)];

      // Run inference
      interpreter.run(input, output);

      // Process results
      final result = output.first;
      int maxScore = result.reduce((a, b) => a + b);
      
      final values = result
          .map((e) => e.toDouble() / maxScore.toDouble())
          .toList();
      
      var classification = Map.fromIterables(labels, values);
      
      // Filter out zero values and background
      classification.removeWhere((key, value) => 
        value == 0 || key.toLowerCase() == '__background__'
      );

      // Sort by confidence and return top 3
      final sortedEntries = classification.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return Map.fromEntries(sortedEntries.take(3));
    } catch (e) {
      logger.e('Inference error: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await isolateInference.close();
    interpreter.close();
  }
}
