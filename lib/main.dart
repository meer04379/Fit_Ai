import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/chat_provider.dart';
import 'providers/fitness_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env) safely
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('[Main] Note: .env not loaded ($e). Falling back to environment variables.');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase safely with timeout so startup is never blocked
  try {
    await SupabaseService().initialize().timeout(
      const Duration(seconds: 2),
      onTimeout: () => debugPrint('[Main] Supabase init timed out, running offline mode'),
    );
  } catch (e) {
    debugPrint('[Main] Supabase init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FitnessProvider()..syncFromCloud(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
      ],
      child: const FitAIApp(),
    ),
  );
}

class FitAIApp extends StatelessWidget {
  const FitAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
