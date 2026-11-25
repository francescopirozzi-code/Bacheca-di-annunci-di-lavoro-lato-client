import 'package:flutter/material.dart';
import 'screens/bacheca_pubblica_screen.dart';

void main() {
  runApp(const BachecaLavoroApp());
}

class BachecaLavoroApp extends StatelessWidget {
  const BachecaLavoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bacheca Lavoro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF0000),
            primary: const Color(0xFFFF0000)
        ),
        useMaterial3: true,
      ),
      home: const BachecaPubblicaScreen(),
    );
  }
}