import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:news/src/services/news_services.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/news_provider.dart';
import 'src/providers/bookmark_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider(NewsService())),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
      ],
      child: const NewsApp(),
    ),
  );
}

