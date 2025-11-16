import 'package:flutter/material.dart';
import 'package:foodfo/controller/food_detail_provider.dart';
import 'package:foodfo/controller/home_provider.dart';
import 'package:foodfo/controller/image_classification_provider.dart';
import 'package:foodfo/theme/theme.dart';
import 'package:foodfo/theme/util.dart';
import 'package:foodfo/service/image_classification_service.dart';
import 'package:foodfo/ui/home/home_screen.dart';
import 'package:provider/provider.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Work Sans", "Nunito Sans");
    MaterialTheme theme = MaterialTheme(textTheme);

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
        ChangeNotifierProvider(create: (_) => FoodDetailProvider()),
      ],
      child: MaterialApp(
        title: 'FoodFo',
        theme: theme.light(),
        darkTheme: theme.dark(),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
