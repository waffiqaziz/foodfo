import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:foodfo/utils/helper.dart';
import 'package:foodfo/utils/image_utils.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

class IsolateInference {
  static const String _debugName = "TFLITE_INFERENCE";
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;
  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );
    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final InferenceModel isolateModel in port) {
      List<List<List<num>>> imageMatrix;

      // Check if it's a camera image or static image bytes
      if (isolateModel.cameraImage != null) {
        // Process camera frame
        final cameraImage = isolateModel.cameraImage!;
        imageMatrix = _imagePreProcessing(cameraImage, isolateModel.inputShape);
      } else if (isolateModel.imageBytes != null) {
        // Process static image from bytes
        imageMatrix = _processStaticImage(
          isolateModel.imageBytes!,
          isolateModel.inputShape,
        );
      } else {
        // No valid input
        logger.e("Isolated: No valid input");
        isolateModel.responsePort.send(<String, double>{});
        continue;
      }

      // Run inference
      final input = [imageMatrix];
      final output = [List<int>.filled(isolateModel.outputShape[1], 0)];
      final address = isolateModel.interpreterAddress;
      final result = _runInference(input, output, address);

      // Result preparation
      int maxScore = result.reduce((a, b) => a + b);
      final keys = isolateModel.labels;
      final values = result
          .map((e) => e.toDouble() / maxScore.toDouble())
          .toList();
      var classification = Map.fromIterables(keys, values);

      // Filter out any incorrect labels
      classification.removeWhere(
        (key, value) =>
            key.toLowerCase() == '__background__' ||
            key.contains('/g/') ||
            RegExp(r'\d').hasMatch(key),
      );

      // Sort and return top 3
      final sortedEntries = classification.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topResults = Map.fromEntries(sortedEntries.take(3));

      isolateModel.responsePort.send(topResults);
    }
  }

  static List<List<List<num>>> _processStaticImage(
    Uint8List imageBytes,
    List<int> inputShape,
  ) {
    // Decode image
    image_lib.Image? img = image_lib.decodeImage(imageBytes);

    if (img == null) {
      throw Exception('Failed to decode image');
    }

    // Resize to model input size
    image_lib.Image imageInput = image_lib.copyResize(
      img,
      width: inputShape[1],
      height: inputShape[2],
    );

    // Convert to matrix format
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(imageInput.width, (x) {
        final pixel = imageInput.getPixel(x, y);
        return [pixel.r, pixel.g, pixel.b];
      }),
    );

    return imageMatrix;
  }

  static List<List<List<num>>> _imagePreProcessing(
    CameraImage cameraImage,
    List<int> inputShape,
  ) {
    image_lib.Image? img;
    img = ImageUtils.convertCameraImage(cameraImage);

    // Resize original image to match model shape
    image_lib.Image imageInput = image_lib.copyResize(
      img!,
      width: inputShape[1],
      height: inputShape[2],
    );

    if (Platform.isAndroid) {
      imageInput = image_lib.copyRotate(imageInput, angle: 90);
    }

    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(imageInput.width, (x) {
        final pixel = imageInput.getPixel(x, y);
        return [pixel.r, pixel.g, pixel.b];
      }),
    );

    return imageMatrix;
  }

  static List<int> _runInference(
    List<List<List<List<num>>>> input,
    List<List<int>> output,
    int interpreterAddress,
  ) {
    Interpreter interpreter = Interpreter.fromAddress(interpreterAddress);
    interpreter.run(input, output);

    // Get first output tensor
    final result = output.first;
    return result;
  }

  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }
}

class InferenceModel {
  CameraImage? cameraImage;
  Uint8List? imageBytes;
  int interpreterAddress;
  List<String> labels;
  List<int> inputShape;
  List<int> outputShape;
  late SendPort responsePort;

  InferenceModel(
    this.cameraImage,
    this.interpreterAddress,
    this.labels,
    this.inputShape,
    this.outputShape,
  );

  // Named constructor for static image bytes
  InferenceModel.fromBytes(
    this.imageBytes,
    this.interpreterAddress,
    this.labels,
    this.inputShape,
    this.outputShape,
  ) : cameraImage = null;
}
