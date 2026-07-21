import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:foodfo/model/local_model_metadata.dart';
import 'package:foodfo/model/model_release.dart';
import 'package:foodfo/service/i_model_download_service.dart';
import 'package:foodfo/utils/constant.dart';
import 'package:foodfo/utils/helper.dart';
import 'package:path_provider/path_provider.dart';

class GithubModelDownloadService implements IModelDownloadService {
  final Dio _dio = Dio();
  DateTime? _lastUpdateCheck;
  bool? _lastUpdateResult;

  Future<Directory> _modelDir() async {
    final dir = await getApplicationSupportDirectory();
    final modelDir = Directory('${dir.path}/models');
    if (!await modelDir.exists()) await modelDir.create(recursive: true);
    return modelDir;
  }

  Future<File> _modelFile() async => File(
    '${(await _modelDir()).path}/${ModelReleaseConstants.modelFileName}',
  );

  Future<File> _labelsFile() async => File(
    '${(await _modelDir()).path}/${ModelReleaseConstants.labelsFileName}',
  );

  Future<File> _metadataFile() async => File(
    '${(await _modelDir()).path}/${ModelReleaseConstants.metadataFileName}',
  );

  Future<LocalModelMetadata?> _readMetadata() async {
    final file = await _metadataFile();
    if (!await file.exists()) return null;
    try {
      final json = jsonDecode(await file.readAsString());
      return LocalModelMetadata.fromJson(json);
    } catch (e) {
      logger.e('Corrupt model metadata, ignoring: $e');
      return null;
    }
  }

  Future<void> _writeMetadata(LocalModelMetadata metadata) async {
    final file = await _metadataFile();
    await file.writeAsString(jsonEncode(metadata.toJson()));
  }

  @override
  Future<bool> isModelDownloaded() async {
    final modelFile = await _modelFile();
    final labelsFile = await _labelsFile();
    final metadata = await _readMetadata();

    return await modelFile.exists() &&
        await modelFile.length() > 0 &&
        await labelsFile.exists() &&
        await labelsFile.length() > 0 &&
        metadata != null;
  }

  @override
  Future<String> getModelPath() async => (await _modelFile()).path;

  @override
  Future<String> getLabelsPath() async => (await _labelsFile()).path;

  @override
  Future<ModelRelease> fetchLatestRelease() async {
    final response = await _dio.get(
      ModelReleaseConstants.latestReleaseApiUrl,
      options: Options(headers: {'Accept': 'application/vnd.github+json'}),
    );
    return ModelRelease.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> hasUpdateAvailable({bool force = false}) async {
    // Serve cached result if checked recently, unless forced.
    if (!force &&
        _lastUpdateCheck != null &&
        _lastUpdateResult != null &&
        DateTime.now().difference(_lastUpdateCheck!) <
            ModelReleaseConstants.updateCheckCooldown) {
      return _lastUpdateResult!;
    }

    final metadata = await _readMetadata();
    if (metadata == null) {
      // Nothing installed yet, not an "update", it's a first install
      return false;
    }

    try {
      final latest = await fetchLatestRelease();
      final hasUpdate = latest.tag != metadata.tag;
      _lastUpdateCheck = DateTime.now();
      _lastUpdateResult = hasUpdate;
      return hasUpdate;
    } catch (e) {
      logger.w('Update check failed (offline?): $e');
      return false;
    }
  }

  @override
  Stream<double> downloadModel(ModelRelease release) {
    final controller = StreamController<double>();

    () async {
      try {
        // Download both files (model & labels), then get the size
        // Model is ~20MB, labels ~25KB, so we use model size as ~100% of the bar
        final modelTemp = File('${(await _modelFile()).path}.tmp');
        final labelsTemp = File('${(await _labelsFile()).path}.tmp');

        await _dio.download(
          release.modelAsset.downloadUrl,
          modelTemp.path,
          onReceiveProgress: (received, total) {
            if (total <= 0) return;
            controller.add(
              (received / total) * 0.95,
            ); // reserve 5% for labels + verify
          },
        );

        await _dio.download(release.labelsAsset.downloadUrl, labelsTemp.path);
        controller.add(0.97);

        // Verify checksums if GitHub provided them
        await _verifyChecksum(modelTemp, release.modelAsset.sha256, 'model');
        await _verifyChecksum(labelsTemp, release.labelsAsset.sha256, 'labels');

        final modelFile = await _modelFile();
        final labelsFile = await _labelsFile();
        if (await modelFile.exists()) await modelFile.delete();
        if (await labelsFile.exists()) await labelsFile.delete();
        await modelTemp.rename(modelFile.path);
        await labelsTemp.rename(labelsFile.path);

        await _writeMetadata(
          LocalModelMetadata(
            tag: release.tag,
            modelSha256: release.modelAsset.sha256 ?? '',
            labelsSha256: release.labelsAsset.sha256 ?? '',
          ),
        );

        controller.add(1.0);
        await controller.close();
      } catch (e, st) {
        logger.e('Model download failed: $e', stackTrace: st);
        controller.addError(e);
        await controller.close();
      }
    }();

    return controller.stream;
  }

  Future<void> _verifyChecksum(
    File file,
    String? expectedSha256,
    String label,
  ) async {
    if (expectedSha256 == null || expectedSha256.isEmpty) {
      logger.w('No checksum provided for $label, skipping verification');
      return;
    }
    final bytes = await file.readAsBytes();
    final actual = sha256.convert(bytes).toString();
    if (actual != expectedSha256) {
      await file.delete();
      throw Exception(
        '$label checksum mismatch (expected $expectedSha256, got $actual) — download corrupted',
      );
    }
  }

  @override
  Future<void> deleteModel() async {
    final modelFile = await _modelFile();
    final labelsFile = await _labelsFile();
    final metadataFile = await _metadataFile();
    for (final f in [modelFile, labelsFile, metadataFile]) {
      if (await f.exists()) await f.delete();
    }
  }
}
