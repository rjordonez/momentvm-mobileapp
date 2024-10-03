import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprint5/chatgpt.dart';
import 'onboarding.dart'; // Import the OnboardingPage here
void main() {
  
  runApp(MultiProvider(
      providers: [
        Provider<OpenAIService>(
          create: (_) => OpenAIService(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const OnboardingPage(), // Start with OnboardingPage
    );
  }
}
