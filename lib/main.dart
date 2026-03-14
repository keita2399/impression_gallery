import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ImpressionGalleryApp());
}

class ImpressionGalleryApp extends StatelessWidget {
  const ImpressionGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Impression Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
