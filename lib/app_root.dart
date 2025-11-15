import 'package:flutter/material.dart';
import 'package:food_fo/controller/home_provider.dart';
import 'package:food_fo/controller/image_classification_provider.dart';
import 'package:food_fo/service/image_classification_service.dart';
import 'package:food_fo/theme/app_theme.dart';
import 'package:food_fo/ui/home/home_screen.dart';
import 'package:provider/provider.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ImageClassificationService()),
        ChangeNotifierProvider(
          create: (context) =>
              HomeProvider(context.read<ImageClassificationService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ImageClassificationViewmodel(
            context.read<ImageClassificationService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'FoodFo',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
