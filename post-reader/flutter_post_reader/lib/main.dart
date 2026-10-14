import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/posts_screen.dart';
import 'screens/details_screen.dart';
import 'screens/favorites_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  // Hive Initialization Requirements:
  // 1. Ensure Flutter widget bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive for Flutter (sets up application document directory storage)
  await Hive.initFlutter();

  // 3. Open the Hive box for storing favorites
  await Hive.openBox('favoritesBox');

  // 4. Run the app only after Hive has initialized successfully
  runApp(const PostReaderApp());
}

class PostReaderApp extends StatelessWidget {
  const PostReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Reader & Favorites',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Navigation Requirements:
      // Define named routes in MaterialApp:
      // '/' for Posts
      // 'details' for Post Details
      // 'favorites' for Favorites
      initialRoute: '/',
      routes: {
        '/': (context) => const PostsScreen(),
        'details': (context) => const DetailsScreen(),
        'favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}
