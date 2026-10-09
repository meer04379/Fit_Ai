import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/gemini_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _gemini = GeminiService();

  final List<ChatMessage> _messages = [];
  String _currentUserName = 'Athlete';
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  /// Ensures the chat starts with a warm personalized greeting for the current user
  void initChat(String userName) {
    _currentUserName = userName;
    if (_messages.isEmpty) {
      _messages.add(
        ChatMessage(
          id: 'msg_welcome',
          text: "Hi $userName! 👋\nI'm your AI Fitness Coach.\nHow can I help you achieve your goals today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
    }
  }

  Future<void> sendMessage(
    String text, {
    int remainingCalories = 760,
    String goal = 'gainMuscle',
    List<MealLogItem> todayMeals = const [],
    String userName = 'Athlete',
  }) async {
    if (text.trim().isEmpty) return;

    _currentUserName = userName;
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    // Call Gemini Free Conversational Model
    try {
      final aiMessage = await _gemini.getCoachAdvice(
        userMessage: text.trim(),
        remainingCalories: remainingCalories,
        goal: goal,
        todayMeals: todayMeals,
        userName: userName,
      );

      _messages.add(aiMessage);
    } catch (_) {
      // Fallback
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: "Hi $userName, you have $remainingCalories kcal remaining today! Keeping your protein high and drinking plenty of water will help you achieve your $goal goal.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat([String? userName]) {
    final name = userName ?? _currentUserName;
    _messages.clear();
    _messages.add(
      ChatMessage(
        id: 'msg_welcome_${DateTime.now().millisecondsSinceEpoch}',
        text: "Hi $name! 👋\nI'm your AI Fitness Coach.\nHow can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
