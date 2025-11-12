import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_fo/controller/home_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: const Text('Cancer Detection'),
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
                      return _ImagePreviewCard(imagePath: provider.imagePath);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Result Card
                  Consumer<HomeProvider>(
                    builder: (context, provider, child) {
                      final response = provider.uploadResponse;
                      if (response?.data == null) {
                        return const SizedBox.shrink();
                      }
                      return _ResultCard(
                        result: response!.data!.result,
                        confidence: response.data!.confidenceScore,
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
                        child: _ImageSourceButton(
                          icon: Icons.photo_library_outlined,
                          label: 'Gallery',
                          onPressed: () =>
                              context.read<HomeProvider>().openGallery(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ImageSourceButton(
                          icon: Icons.camera_alt_outlined,
                          label: 'Camera',
                          onPressed: () =>
                              context.read<HomeProvider>().openCamera(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ImageSourceButton(
                          icon: Icons.lens_blur_outlined,
                          label: 'Pro Camera',
                          onPressed: () => context
                              .read<HomeProvider>()
                              .openCustomCamera(context),
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
                          // Clear error after showing snackbar
                          provider.clearError();
                        });
                      }

                      return FilledButton.icon(
                        onPressed: hasImage && !provider.isUploading
                            ? () => provider.upload()
                            : null,
                        icon: provider.isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.analytics_outlined),
                        label: Text(
                          provider.isUploading
                              ? 'Analyzing...'
                              : 'Analyze Image',
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
                  _InfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreviewCard extends StatelessWidget {
  final String? imagePath;

  const _ImagePreviewCard({this.imagePath});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: imagePath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 80,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No image selected',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose an image source below',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              )
            : Image.file(File(imagePath!), fit: BoxFit.cover),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String result;
  final double confidence;

  const _ResultCard({required this.result, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHighConfidence = confidence >= 70;

    return Card(
      color: isHighConfidence
          ? colorScheme.primaryContainer
          : colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: isHighConfidence
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  'Analysis Result',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isHighConfidence
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              result,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isHighConfidence
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onTertiaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Confidence: ',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isHighConfidence
                        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                        : colorScheme.onTertiaryContainer.withValues(
                            alpha: 0.8,
                          ),
                  ),
                ),
                Text(
                  '${confidence.round()}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isHighConfidence
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: colorScheme.onSecondaryContainer,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Select an image and tap "Analyze" to detect cancer cells using AI',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
