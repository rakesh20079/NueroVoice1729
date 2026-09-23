import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/screening_state.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScreeningSessionProvider()),
      ],
      child: const NeuroVoiceApp(),
    ),
  );
}

class NeuroVoiceApp extends StatelessWidget {
  const NeuroVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroVoice',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}
