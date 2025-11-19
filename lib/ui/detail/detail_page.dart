import 'package:flutter/material.dart';
import 'package:foodfo/controller/detail_provider.dart';
import 'package:foodfo/ui/detail/detail_body.dart';
import 'package:provider/provider.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodName;
  final String imagePath;
  final double confidence;

  const FoodDetailScreen({
    super.key,
    required this.foodName,
    required this.imagePath,
    required this.confidence,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    if (!mounted) return;
    context.read<FoodDetailProvider>().fetchFoodDetails(widget.foodName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FoodDetailProvider>(
        builder: (context, provider, child) {
          // Show loading for meal details
          if (provider.isMealLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show detail body
          return DetailBody(
            foodName: widget.foodName,
            imagePath: widget.imagePath,
            confidence: widget.confidence,
          );
        },
      ),
    );
  }
}
