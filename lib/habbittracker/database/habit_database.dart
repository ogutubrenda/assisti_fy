import 'package:assisti_fy/habbittracker/models/app_settings.dart';
import 'package:assisti_fy/habbittracker/models/habit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:isar/isar.dart';
import 'package:flutter/cupertino.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:assisti_fy/isar/isar_database.dart';

class HabitDatabase extends ChangeNotifier{
  // static late Isar isar;

  // static Future<void> initialize() async{
  //   final dir = await getApplicationDocumentsDirectory();
  //   isar = await Isar.open(
  //     [HabitSchema, AppSettingsSchema],
  //     directory: dir.path,);
  // }

  Future<void> saveFirstLaunchDate() async{
    final existingSettings = await IsarDatabase.isar.appSettings.where().findFirst();
    if (existingSettings == null){
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await IsarDatabase.isar.writeTxn(() => IsarDatabase.isar.appSettings.put(settings));
    }
  }

  Future<DateTime?> getFirstLaunchDate() async{
    final settings = await IsarDatabase.isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  final List<Habit> currentHabits = [];

  //create new habit
  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName;

    await IsarDatabase.isar.writeTxn(() => IsarDatabase.isar.habits.put(newHabit));

    readHabits();
  }

  Future<void> readHabits() async{
    List<Habit> fetchedHabits = await IsarDatabase.isar.habits.where().findAll();

    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    notifyListeners();
  }

  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
  final habit = await IsarDatabase.isar.habits.get(id);

  if (habit != null) {
    await IsarDatabase.isar.writeTxn(() async {
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      if (isCompleted && !habit.completedDays.contains(normalizedToday)) {
        // Add today's date to the completedDays list
        habit.completedDays.add(normalizedToday);
      } else {
        // Remove today's date from the completedDays list
        habit.completedDays.removeWhere((date) =>
            date.year == normalizedToday.year &&
            date.month == normalizedToday.month &&
            date.day == normalizedToday.day);
      }

      // Save the updated habit object back to the database
      await IsarDatabase.isar.habits.put(habit); // Must stay inside writeTxn
    });
  }

  // Refresh habits after the update
  await readHabits();
}


  Future<void> updateHabitName (int id, String newName) async {
    final habit = await IsarDatabase.isar.habits.get(id);

    if(habit != null){
      await IsarDatabase.isar.writeTxn(() async {
        habit.name = newName;
        
        await IsarDatabase.isar.habits.put(habit);
      });
    }

    readHabits();
  }

  Future<void> deleteHabit (int id) async {
    await IsarDatabase.isar.writeTxn(() async {
      await IsarDatabase.isar.habits.delete(id);
    });

    readHabits();
  }

  /// Finds a habit by its name. Returns null if no habit is found.
Habit? findHabitByName(String name) {
  for (final habit in currentHabits) {
    if (habit.name == name) {
      return habit;
    }
  }
  return null;
}

/// Method to show messages to the user via SnackBar using GetX
  void showMessage(String message) {
    Get.snackbar(
      'Assistify',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      backgroundColor: Colors.black54,
      colorText: Colors.white,
      margin: EdgeInsets.all(10),
      borderRadius: 8,
    );
  }




  
}