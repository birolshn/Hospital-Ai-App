import 'package:flutter/material.dart';
import 'pages/predict_page.dart';

void main() {
  runApp(const HospitalAIApp());
}

class HospitalAIApp extends StatelessWidget {
  const HospitalAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital AI Predictor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PredictPage(),
    );
  }
}
