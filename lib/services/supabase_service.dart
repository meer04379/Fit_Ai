import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';
import '../models/models.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  SupabaseClient? get client {
    if (!_isInitialized) return null;
    return Supabase.instance.client;
  }

  String get currentUserId {
    return client?.auth.currentUser?.id ?? 'guest_user';
  }

  bool get isLoggedIn {
    return client?.auth.currentUser != null;
  }

  bool get isGuest {
    return client?.auth.currentUser?.isAnonymous ?? false;
  }

  String? get currentUserEmail {
    return client?.auth.currentUser?.email;
  }

  /// Signs up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    if (!_isInitialized || client == null) {
      throw Exception('Supabase is not initialized');
    }
    final response = await client!.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password.trim(),
      data: name != null ? {'full_name': name.trim()} : null,
    );
    return response;
  }

  /// Signs in with existing email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (!_isInitialized || client == null) {
      throw Exception('Supabase is not initialized');
    }
    final response = await client!.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password.trim(),
    );
    return response;
  }

  /// Sends a password reset email
  Future<void> resetPassword(String email) async {
    if (!_isInitialized || client == null) {
      throw Exception('Supabase is not initialized');
    }
    await client!.auth.resetPasswordForEmail(email.trim().toLowerCase());
  }

  /// Signs in anonymously as a guest
  Future<AuthResponse> signInAnonymously() async {
    if (!_isInitialized || client == null) {
      throw Exception('Supabase is not initialized');
    }
    return await client!.auth.signInAnonymously();
  }

  /// Logs out the current user session
  Future<void> signOut() async {
    if (!_isInitialized || client == null) return;
    try {
      await client!.auth.signOut();
    } catch (e) {
      debugPrint('[SupabaseService] Sign out error: $e');
    }
  }

  /// Initializes Supabase if credentials are provided in AppConfig
  Future<void> initialize() async {
    if (!AppConfig.hasSupabaseConfig) {
      debugPrint('[SupabaseService] Supabase credentials not set. Running in offline/local mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: AppConfig.supabaseAnonKey,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Successfully connected to Supabase.');
    } catch (e) {
      debugPrint('[SupabaseService] Supabase initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Fetches meals logged today from Supabase
  Future<List<MealLogItem>?> fetchTodayMeals() async {
    if (!_isInitialized || client == null) return null;

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

      final response = await client!
          .from('meal_logs')
          .select()
          .eq('user_id', currentUserId)
          .gte('created_at', startOfDay)
          .order('created_at', ascending: true);

      final list = response as List;
      return list.map((item) => MealLogItem.fromSupabaseMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[SupabaseService] Error fetching meals: $e');
      return null;
    }
  }

  /// Inserts a new meal into Supabase
  Future<bool> saveMeal(MealLogItem meal) async {
    if (!_isInitialized || client == null) return false;

    try {
      await client!.from('meal_logs').insert(meal.toSupabaseMap(currentUserId));
      debugPrint('[SupabaseService] Saved meal: ${meal.title}');
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Error saving meal: $e');
      return false;
    }
  }

  /// Deletes a meal from Supabase
  Future<bool> deleteMeal(String mealId) async {
    if (!_isInitialized || client == null) return false;

    try {
      await client!.from('meal_logs').delete().eq('id', mealId).eq('user_id', currentUserId);
      debugPrint('[SupabaseService] Deleted meal: $mealId');
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Error deleting meal: $e');
      return false;
    }
  }

  /// Saves or updates the user profile
  Future<bool> saveProfile({
    required String name,
    required String goal,
    required int targetCalories,
    required double currentWeight,
    required double goalWeight,
  }) async {
    if (!_isInitialized || client == null) return false;

    try {
      await client!.from('profiles').upsert({
        'id': currentUserId,
        'name': name,
        'goal': goal,
        'target_calories': targetCalories,
        'current_weight': currentWeight,
        'goal_weight': goalWeight,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Error saving profile: $e');
      return false;
    }
  }

  /// Fetches saved user profile from Supabase
  Future<Map<String, dynamic>?> fetchProfile() async {
    if (!_isInitialized || client == null) return null;
    try {
      final res = await client!
          .from('profiles')
          .select()
          .eq('id', currentUserId)
          .maybeSingle();
      return res;
    } catch (e) {
      debugPrint('[SupabaseService] Error fetching profile: $e');
      return null;
    }
  }

  /// Logs weight entry to weight_logs table
  Future<bool> logWeight(double weight) async {
    if (!_isInitialized || client == null) return false;

    try {
      await client!.from('weight_logs').insert({
        'user_id': currentUserId,
        'weight': weight,
        'recorded_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] Error logging weight: $e');
      return false;
    }
  }
}
