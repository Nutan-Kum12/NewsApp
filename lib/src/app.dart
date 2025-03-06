import 'package:flutter/material.dart';
import 'package:news/src/services/news_services.dart';
import 'package:news/src/themes/app_theme.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

class NewsApp extends StatelessWidget {
  const NewsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);

    return MaterialApp(
      title: 'News Aggregator',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: authProvider.isAuthenticated
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
