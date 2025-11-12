import 'package:flutter/material.dart';
import 'package:food_fo/controller/home_provider.dart';
import 'package:food_fo/service/http_service.dart';
import 'package:food_fo/theme/app_theme.dart';
import 'package:food_fo/ui/home/home_screen.dart';
import 'package:provider/provider.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider(HttpService())),
      ],
      child: MaterialApp(
        title: 'Cancer Detection',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
