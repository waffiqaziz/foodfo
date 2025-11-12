import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:food_fo/model/upload_response.dart';
import 'package:http/http.dart' as http;

class HttpService {
  Future<UploadResponse> uploadDocument(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      const String url =
          "https://classification-api.dicoding.dev/skin-cancer/predict";

      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      final http.MultipartFile multiPartFile = http.MultipartFile.fromBytes(
        "photo",
        bytes,
        filename: fileName,
      );
      final Map<String, String> headers = {
        "Content-type": "multipart/form-data",
      };

      request.files.add(multiPartFile);
      request.headers.addAll(headers);

      final http.StreamedResponse streamedResponse = await request.send();
      final int statusCode = streamedResponse.statusCode;

      final Uint8List responseList = await streamedResponse.stream.toBytes();
      final String responseData = String.fromCharCodes(responseList);

      if (statusCode == 200 || statusCode == 201 || statusCode == 413) {
        return UploadResponse.fromJson(jsonDecode(responseData));
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      throw Exception("Caught an error: $e");
    }
  }
}
