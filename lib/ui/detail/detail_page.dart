import 'package:flutter/material.dart';
import 'package:foodfo/controller/food_detail_provider.dart';
import 'package:foodfo/ui/detail/detail_body.dart';
import 'package:foodfo/ui/detail/error_view.dart';
import 'package:provider/provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodName;
  final String imagePath;

  const FoodDetailScreen({
    super.key,
    required this.foodName,
    required this.imagePath,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  @override
  void initState() {
    Future.microtask(() {
      if (mounted) {
        context.read<FoodDetailProvider>().fetchFoodDetails(widget.foodName);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FoodDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return ErrorView(
              message: provider.errorMessage ?? 'Failed to load food details',
              onRetry: () => provider.fetchFoodDetails(widget.foodName),
            );
          }

          if (provider.mealDetail == null) {
            return const Center(child: Text('No data available'));
          }

          return DetailBody(
            meal: provider.mealDetail!,
            imagePath: widget.imagePath,
          );
        },
      ),
    );
  }
}
