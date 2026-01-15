
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ahp_provider.dart';
import 'screens/setup_screen.dart';
import 'utils/styles.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AhpProvider()),
      ],
      child: const AgroAHPApp(),
    ),
  );
}

class AgroAHPApp extends StatelessWidget {
  const AgroAHPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agro-AHP Pro',
      theme: AgroStyles.themeData,
      debugShowCheckedModeBanner: false,
      home: const SetupScreen(),
    );
  }
}
