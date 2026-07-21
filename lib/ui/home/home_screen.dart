import 'package:flutter/material.dart';
import 'package:foodfo/controller/home_provider.dart';
import 'package:foodfo/theme/crop_image_theme.dart';
import 'package:foodfo/ui/home/food_results_card.dart';
import 'package:foodfo/ui/home/image_preview_card.dart';
import 'package:foodfo/ui/home/image_source_button.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cropTheme = CropImageTheme.fromColorScheme(
      theme.colorScheme,
      theme.brightness,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(
              'Food Classification',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            floating: false,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Preview Card
                  Consumer<HomeProvider>(
                    builder: (_, provider, _) {
                      return ImagePreviewCard(imagePath: provider.imagePath);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Results Card
                  Consumer<HomeProvider>(
                    builder: (context, provider, child) {
                      if (provider.classifications.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return FoodResultsCard(
                        classifications: provider.classifications,
                        imagePath: provider.imagePath,
                      );
                    },
                  ),

                  // Action Buttons Section
                  const SizedBox(height: 24),
                  Text(
                    'Select Image Source',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),

                  // Image Source Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ImageSourceButton(
                          icon: Icons.photo_library_outlined,
                          label: 'Gallery',
                          onPressed: () => context
                              .read<HomeProvider>()
                              .openGallery(cropTheme),
                        ),
                      ),
                      Expanded(
                        child: ImageSourceButton(
                          icon: Icons.camera_alt_outlined,
                          label: 'Camera',
                          onPressed: () => context
                              .read<HomeProvider>()
                              .openCamera(cropTheme),
                        ),
                      ),
                      Expanded(
                        child: ImageSourceButton(
                          icon: Icons.lens_blur_outlined,
                          label: 'Pro Camera',
                          onPressed: () => context
                              .read<HomeProvider>()
                              .openCustomCamera(context, cropTheme),
                        ),
                      ),
                      Expanded(
                        child: ImageSourceButton(
                          icon: Icons.video_camera_back_outlined,
                          label: 'Real-time',
                          onPressed: () => context
                              .read<HomeProvider>()
                              .openRealtimeCamera(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // analyze
                  Consumer<HomeProvider>(
                    builder: (context, provider, child) {
                      switch (provider.modelStatus) {
                        case ModelDownloadStatus.checking:
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );

                        case ModelDownloadStatus.notDownloaded:
                        case ModelDownloadStatus.error:
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (provider.modelErrorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    provider.modelErrorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              FilledButton.icon(
                                onPressed: () => provider.downloadModel(),
                                icon: const Icon(Icons.download_outlined),
                                label: const Text('Download Model to Continue'),
                              ),
                            ],
                          );

                        case ModelDownloadStatus.downloading:
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              LinearProgressIndicator(
                                value: provider.downloadProgress,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Downloading model... ${(provider.downloadProgress * 100).toStringAsFixed(0)}%',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );

                        case ModelDownloadStatus.ready:
                          final hasImage = provider.imagePath != null;
                          return FilledButton.icon(
                            onPressed: hasImage && !provider.isAnalyzing
                                ? () => provider.analyzeImage()
                                : null,
                            icon: provider.isAnalyzing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.restaurant_menu),
                            label: Text(
                              provider.isAnalyzing
                                  ? 'Analyzing...'
                                  : 'Identify Food',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );

                        case ModelDownloadStatus.updateAvailable:
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Material(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => provider.downloadModel(),
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.system_update_outlined),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'A newer model is available — tap to update',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // ...same "ready" button as before, since the current model still works
                            ],
                          );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
