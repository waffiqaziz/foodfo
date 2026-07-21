import 'package:foodfo/model/model_asset.dart';
import 'package:foodfo/utils/constant.dart';

class ModelRelease {
  final String tag;
  final ModelAsset modelAsset;
  final ModelAsset labelsAsset;

  ModelRelease({
    required this.tag,
    required this.modelAsset,
    required this.labelsAsset,
  });

  factory ModelRelease.fromJson(Map<String, dynamic> json) {
    final assets = (json['assets'] as List).cast<Map<String, dynamic>>();

    final modelJson = assets.firstWhere(
      (a) => a['name'] == ModelReleaseConstants.modelAssetName,
      orElse: () => throw StateError('Release is missing model.tflite asset'),
    );
    final labelsJson = assets.firstWhere(
      (a) => a['name'] == ModelReleaseConstants.labelsAssetName,
      orElse: () => throw StateError('Release is missing labels.txt asset'),
    );

    return ModelRelease(
      tag: json['tag_name'] as String,
      modelAsset: ModelAsset.fromJson(modelJson),
      labelsAsset: ModelAsset.fromJson(labelsJson),
    );
  }
}
