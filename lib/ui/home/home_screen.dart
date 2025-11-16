import 'package:flutter/material.dart';
import 'package:food_fo/controller/home_provider.dart';
import 'package:food_fo/theme/crop_image_theme.dart';
import 'package:food_fo/ui/home/food_results_card.dart';
import 'package:food_fo/ui/home/image_preview_card.dart';
import 'package:food_fo/ui/home/image_source_button.dart';
import 'package:food_fo/ui/home/info_card.dart';
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
                    builder: (context, provider, child) {
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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

                  // Analyze Button
                  Consumer<HomeProvider>(
                    builder: (context, provider, child) {
                      final hasImage = provider.imagePath != null;

                      if (provider.hasError && provider.errorMessage != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(provider.errorMessage!)),
                                ],
                              ),
                              backgroundColor: Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Dismiss',
                                textColor: Colors.white,
                                onPressed: () {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                },
                              ),
                            ),
                          );
                          provider.clearError();
                        });
                      }

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
                    },
                  ),

                  const SizedBox(height: 24),

                  // Info Card
                  InfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
