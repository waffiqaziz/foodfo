const double confidenceThreshold = 0.15;

class ModelReleaseConstants {
  static const String repoOwner = 'waffiqaziz';
  static const String repoName = 'foodfo-models';

  static String get latestReleaseApiUrl =>
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  static const String modelAssetName = 'model.tflite';
  static const String labelsAssetName = 'labels.txt';

  static const String modelFileName = 'model.tflite';
  static const String labelsFileName = 'labels.txt';
  static const String metadataFileName = 'model_metadata.json';

  static const Duration updateCheckCooldown = Duration(hours: 6);
}
