import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MiBolsilloApp());
}

class MiBolsilloApp extends StatelessWidget {
  const MiBolsilloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Bolsillo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const HomeScreen(),
    );
  }
}
