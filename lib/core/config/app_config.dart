import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String? _runtimeGeminiApiKey;
  static String? _runtimeSupabaseUrl;
  static String? _runtimeSupabaseAnonKey;

  /// Google Gemini Free API Key
  /// Loaded priority: Runtime override -> .env file -> --dart-define
  static String get geminiApiKey {
    if (_runtimeGeminiApiKey != null && _runtimeGeminiApiKey!.trim().isNotEmpty) {
      return _runtimeGeminiApiKey!.trim();
    }
    try {
      final envVal = dotenv.maybeGet('GEMINI_API_KEY');
      if (envVal != null && envVal.trim().isNotEmpty) {
        return envVal.trim();
      }
    } catch (_) {}
    return const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '').trim();
  }

  /// Supabase Project URL
  /// Loaded priority: Runtime override -> .env file -> --dart-define
  static String get supabaseUrl {
    if (_runtimeSupabaseUrl != null && _runtimeSupabaseUrl!.trim().isNotEmpty) {
      return _runtimeSupabaseUrl!.trim();
    }
    try {
      final envVal = dotenv.maybeGet('SUPABASE_URL');
      if (envVal != null && envVal.trim().isNotEmpty) {
        return envVal.trim();
      }
    } catch (_) {}
    return const String.fromEnvironment('SUPABASE_URL', defaultValue: '').trim();
  }

  /// Supabase Anon Public API Key
  /// Loaded priority: Runtime override -> .env file -> --dart-define
  static String get supabaseAnonKey {
    if (_runtimeSupabaseAnonKey != null && _runtimeSupabaseAnonKey!.trim().isNotEmpty) {
      return _runtimeSupabaseAnonKey!.trim();
    }
    try {
      final envVal = dotenv.maybeGet('SUPABASE_ANON_KEY');
      if (envVal != null && envVal.trim().isNotEmpty) {
        return envVal.trim();
      }
    } catch (_) {}
    return const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '').trim();
  }

  /// Helper flags
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  /// Allows setting keys dynamically at runtime (e.g. from UI, settings, or storage)
  static void updateKeys({
    String? geminiKey,
    String? newSupabaseUrl,
    String? newSupabaseAnonKey,
  }) {
    if (geminiKey != null) _runtimeGeminiApiKey = geminiKey.trim();
    if (newSupabaseUrl != null) _runtimeSupabaseUrl = newSupabaseUrl.trim();
    if (newSupabaseAnonKey != null) _runtimeSupabaseAnonKey = newSupabaseAnonKey.trim();
  }
}
