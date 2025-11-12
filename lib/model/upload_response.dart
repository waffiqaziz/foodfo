class UploadResponse {
  final String message;
  final ResponseData? data;
  UploadResponse({required this.message, required this.data});

  factory UploadResponse.fromJson(Map<String, dynamic> map) {
    return UploadResponse(
      message: map['message'] as String,
      data: map["data"] == null
          ? null
          : ResponseData.fromJson(map['data'] as Map<String, dynamic>),
    );
  }
}

class ResponseData {
  final String id;
  final String result;
  final double confidenceScore;
  final bool isAboveThreshold;
  final String createdAt;
  ResponseData({
    required this.id,
    required this.result,
    required this.confidenceScore,
    required this.isAboveThreshold,
    required this.createdAt,
  });

  factory ResponseData.fromJson(Map<String, dynamic> map) {
    return ResponseData(
      id: map['id'] as String,
      result: map['result'] as String,
      confidenceScore: map['confidenceScore'].toDouble() as double,
      isAboveThreshold: map['isAboveThreshold'] as bool,
      createdAt: map['createdAt'] as String,
    );
  }
}
