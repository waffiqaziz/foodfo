import 'package:foodfo/model/model_release.dart';

abstract class IModelDownloadService {
  Future<bool> isModelDownloaded();
  Future<String> getModelPath();
  Future<String> getLabelsPath();
  Future<ModelRelease> fetchLatestRelease();
  Future<bool> hasUpdateAvailable({bool force = false});
  Stream<double> downloadModel(ModelRelease release);
  Future<void> deleteModel();
}
