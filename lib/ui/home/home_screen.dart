import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_fo/controller/home_provider.dart';
import 'package:food_fo/ui/detail/detail_page.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: const Text('Food Classification'),
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

                  // Results Card
                  Consumer<HomeProvider>(
                    builder: (context, provider, child) {
                      if (provider.classifications.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _FoodResultsCard(
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
                        child: _ImageSourceButton(
                          icon: Icons.photo_library_outlined,
                          label: 'Gallery',
                          onPressed: () =>
                              context.read<HomeProvider>().openGallery(),
                        ),
                      ),
                      Expanded(
                        child: _ImageSourceButton(
                          icon: Icons.camera_alt_outlined,
                          label: 'Camera',
                          onPressed: () =>
                              context.read<HomeProvider>().openCamera(),
                        ),
                      ),
                      Expanded(
                        child: _ImageSourceButton(
                          icon: Icons.lens_blur_outlined,
                          label: 'Pro Camera',
                          onPressed: () => context
                              .read<HomeProvider>()
                              .openCustomCamera(context),
                        ),
                      ),
                      Expanded(
                        child: _ImageSourceButton(
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
                    Icons.restaurant,
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
                    'Choose an image to identify food',
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

class _FoodResultsCard extends StatelessWidget {
  final Map<String, num> classifications;
  final String? imagePath; // Add this parameter

  const _FoodResultsCard({required this.classifications, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = classifications.entries.toList();

    return Card(
      color: colorScheme.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: imagePath != null && entries.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodDetailScreen(
                      foodName: entries[0].key,
                      imagePath: imagePath!,
                    ),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Food Recognition Results',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Top prediction
              if (entries.isNotEmpty) ...[
                Text(
                  _formatFoodName(entries[0].key),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(entries[0].value * 100).toStringAsFixed(1)}% confidence',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],

              // Other predictions
              if (entries.length > 1) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Other possibilities:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ...entries
                    .skip(1)
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _formatFoodName(entry.key),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                            Text(
                              '${(entry.value * 100).toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatFoodName(String name) {
    // Capitalize first letter of each word
    return name
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
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
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
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
                'Take or select a photo of food to identify it using Machine Learning',
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
