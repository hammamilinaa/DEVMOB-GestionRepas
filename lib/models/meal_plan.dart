enum MealSlot { breakfast, lunch, dinner }

extension MealSlotLabel on MealSlot {
  String get label {
    switch (this) {
      case MealSlot.breakfast:
        return 'Petit-déjeuner';
      case MealSlot.lunch:
        return 'Déjeuner';
      case MealSlot.dinner:
        return 'Dîner';
    }
  }
}

class MealPlan {
  final String id;
  final String userId;
  final String date; // format 2026-11-05
  final MealSlot slot;
  final String recipeId;

  MealPlan({
    required this.id,
    required this.userId,
    required this.date,
    required this.slot,
    required this.recipeId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'date': date,
        'slot': slot.name,
        'recipeId': recipeId,
      };

  factory MealPlan.fromMap(Map map) => MealPlan(
        id: map['id'] as String,
        userId: map['userId'] as String,
        date: map['date'] as String,
        slot: MealSlot.values.byName(map['slot'] as String),
        recipeId: map['recipeId'] as String,
      );
}
