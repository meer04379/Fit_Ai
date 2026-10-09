enum GoalType {
  loseWeight,
  gainMuscle,
  maintain;

  String get title {
    switch (this) {
      case GoalType.loseWeight:
        return 'Lose Weight';
      case GoalType.gainMuscle:
        return 'Gain Muscle';
      case GoalType.maintain:
        return 'Maintain';
    }
  }

  String get description {
    switch (this) {
      case GoalType.loseWeight:
        return 'Burn calories and lose body fat';
      case GoalType.gainMuscle:
        return 'Build muscle and get stronger';
      case GoalType.maintain:
        return 'Stay healthy and maintain weight';
    }
  }

  String get emoji {
    switch (this) {
      case GoalType.loseWeight:
        return '🏃';
      case GoalType.gainMuscle:
        return '🏋️';
      case GoalType.maintain:
        return '🧘';
    }
  }
}

enum MealCategory {
  breakfast,
  lunch,
  dinner,
  snacks;

  String get title {
    switch (this) {
      case MealCategory.breakfast:
        return 'Breakfast';
      case MealCategory.lunch:
        return 'Lunch';
      case MealCategory.dinner:
        return 'Dinner';
      case MealCategory.snacks:
        return 'Snacks';
    }
  }

  static MealCategory fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'breakfast':
        return MealCategory.breakfast;
      case 'lunch':
        return MealCategory.lunch;
      case 'dinner':
        return MealCategory.dinner;
      case 'snacks':
      case 'snack':
        return MealCategory.snacks;
      default:
        return MealCategory.lunch;
    }
  }
}

class DetectedIngredient {
  final String name;
  final int calories;
  final String icon;

  const DetectedIngredient({
    required this.name,
    required this.calories,
    this.icon = '🥗',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'icon': icon,
      };

  factory DetectedIngredient.fromJson(Map<String, dynamic> json) {
    return DetectedIngredient(
      name: json['name'] as String? ?? 'Ingredient',
      calories: (json['calories'] as num?)?.toInt() ?? 50,
      icon: json['icon'] as String? ?? '🥗',
    );
  }
}

class MealLogItem {
  final String id;
  final String title;
  final MealCategory category;
  final int calories;
  final String time;
  final String? imageUrl;
  final String? emoji;
  final double protein;
  final double carbs;
  final double fat;
  final int aiConfidence;
  final List<DetectedIngredient> ingredients;
  final bool isLogged;

  const MealLogItem({
    required this.id,
    required this.title,
    required this.category,
    required this.calories,
    required this.time,
    this.imageUrl,
    this.emoji = '🍲',
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.aiConfidence = 95,
    this.ingredients = const [],
    this.isLogged = true,
  });

  MealLogItem copyWith({
    String? id,
    String? title,
    MealCategory? category,
    int? calories,
    String? time,
    String? imageUrl,
    String? emoji,
    double? protein,
    double? carbs,
    double? fat,
    int? aiConfidence,
    List<DetectedIngredient>? ingredients,
    bool? isLogged,
  }) {
    return MealLogItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      time: time ?? this.time,
      imageUrl: imageUrl ?? this.imageUrl,
      emoji: emoji ?? this.emoji,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      ingredients: ingredients ?? this.ingredients,
      isLogged: isLogged ?? this.isLogged,
    );
  }

  Map<String, dynamic> toSupabaseMap(String userId) => {
        'id': id,
        'user_id': userId,
        'title': title,
        'category': category.name,
        'calories': calories,
        'time': time,
        'image_url': imageUrl,
        'emoji': emoji,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'ai_confidence': aiConfidence,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
      };

  factory MealLogItem.fromSupabaseMap(Map<String, dynamic> map) {
    List<DetectedIngredient> ingredientsList = [];
    if (map['ingredients'] != null) {
      final list = map['ingredients'] as List;
      ingredientsList = list
          .map((item) =>
              DetectedIngredient.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return MealLogItem(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? 'Meal',
      category: MealCategory.fromString(map['category'] as String?),
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      time: map['time'] as String? ?? '12:00 PM',
      imageUrl: map['image_url'] as String?,
      emoji: map['emoji'] as String? ?? '🍲',
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      aiConfidence: (map['ai_confidence'] as num?)?.toInt() ?? 95,
      ingredients: ingredientsList,
      isLogged: true,
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<MealSuggestion>? suggestions;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
  });
}

class MealSuggestion {
  final String name;
  final int calories;
  final String description;

  const MealSuggestion({
    required this.name,
    required this.calories,
    this.description = '',
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) {
    return MealSuggestion(
      name: json['name'] as String? ?? 'Healthy Meal',
      calories: (json['calories'] as num?)?.toInt() ?? 450,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'description': description,
      };
}

class WeightDataPoint {
  final String label;
  final double weight;

  const WeightDataPoint({
    required this.label,
    required this.weight,
  });
}
