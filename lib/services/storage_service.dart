import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const usersBox = 'users';
  static const recipesBox = 'recipes';
  static const mealPlansBox = 'mealplans';
  static const shoppingBox = 'shopping';
  static const sessionBox = 'session';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(usersBox),
      Hive.openBox(recipesBox),
      Hive.openBox(mealPlansBox),
      Hive.openBox(shoppingBox),
      Hive.openBox(sessionBox),
    ]);
  }

  static Box get users => Hive.box(usersBox);
  static Box get recipes => Hive.box(recipesBox);
  static Box get mealPlans => Hive.box(mealPlansBox);
  static Box get shopping => Hive.box(shoppingBox);
  static Box get session => Hive.box(sessionBox);
}