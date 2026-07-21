class LocalModelMetadata {
  final String tag;
  final String modelSha256;
  final String labelsSha256;

  LocalModelMetadata({
    required this.tag,
    required this.modelSha256,
    required this.labelsSha256,
  });

  Map<String, dynamic> toJson() => {
    'tag': tag,
    'modelSha256': modelSha256,
    'labelsSha256': labelsSha256,
  };

  factory LocalModelMetadata.fromJson(Map<String, dynamic> json) =>
      LocalModelMetadata(
        tag: json['tag'] as String,
        modelSha256: json['modelSha256'] as String,
        labelsSha256: json['labelsSha256'] as String,
      );
}
