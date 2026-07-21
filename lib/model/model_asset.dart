class ModelAsset {
  final String name;
  final String downloadUrl;
  final String? sha256;
  final int size;

  ModelAsset({
    required this.name,
    required this.downloadUrl,
    required this.sha256,
    required this.size,
  });

  factory ModelAsset.fromJson(Map<String, dynamic> json) {
    String? sha;
    final digest = json['digest'] as String?;
    if (digest != null && digest.startsWith('sha256:')) {
      sha = digest.substring('sha256:'.length);
    }
    return ModelAsset(
      name: json['name'] as String,
      downloadUrl: json['browser_download_url'] as String,
      sha256: sha,
      size: json['size'] as int? ?? 0,
    );
  }
}
