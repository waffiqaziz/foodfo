import 'package:flutter/material.dart';
import 'package:food_fo/controller/home_provider.dart';
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
        ChangeNotifierProvider(create: (_) => HomeProvider(ImageClassificationService())),
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
