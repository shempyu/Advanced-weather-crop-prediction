import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AssamAgroApp());
}

class AssamAgroApp extends StatelessWidget {
  const AssamAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assam Agro Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        colorSchemeSeed: Colors.greenAccent,
      ),
      home: const HomeScreen(),
    );
  }
}
