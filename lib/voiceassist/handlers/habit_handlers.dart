// lib/voiceassist/handlers/habit_handlers.dart

import 'package:assisti_fy/habbittracker/database/habit_database.dart';
import 'package:assisti_fy/habbittracker/models/habit.dart';
import 'package:assisti_fy/voiceassist/models/intent_response.dart';

class HabitHandlers {
  final HabitDatabase habitDatabase;

  HabitHandlers({required this.habitDatabase});

  /// Handler for 'add_habit' intent
  Future<void> handleAddHabit(IntentResponse intentResponse) async {
    final habitNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'habit_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (habitNameEntity.value != null && habitNameEntity.value is String) {
      final habitName = habitNameEntity.value as String;

      // Check if habit already exists
      final existingHabit = habitDatabase.findHabitByName(habitName);
      if (existingHabit != null) {
        habitDatabase.showMessage("Habit '$habitName' already exists.");
        return;
      }

      // Add the new habit
      await habitDatabase.addHabit(habitName);
      habitDatabase.showMessage("Habit '$habitName' added successfully.");
    } else {
      habitDatabase.showMessage("I couldn't find the habit name. Please try again.");
    }
  }

  /// Handler for 'delete_habit' intent
  Future<void> handleDeleteHabit(IntentResponse intentResponse) async {
    final habitNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'habit_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (habitNameEntity.value != null && habitNameEntity.value is String) {
      final habitName = habitNameEntity.value as String;

      final habit = habitDatabase.findHabitByName(habitName);

      if (habit != null) {
        await habitDatabase.deleteHabit(habit.id);
        habitDatabase.showMessage("Habit '$habitName' has been deleted.");
      } else {
        habitDatabase.showMessage("Habit '$habitName' not found.");
      }
    } else {
      habitDatabase.showMessage("I couldn't find the habit name. Please try again.");
    }
  }

  /// Handler for 'update_habit' intent
  Future<void> handleUpdateHabit(IntentResponse intentResponse) async {
    final habitNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'habit_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    final newHabitNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'new_habit_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (habitNameEntity.value != null &&
        habitNameEntity.value is String &&
        newHabitNameEntity.value != null &&
        newHabitNameEntity.value is String) {
      final habitName = habitNameEntity.value as String;
      final newHabitName = newHabitNameEntity.value as String;

      final habit = habitDatabase.findHabitByName(habitName);

      if (habit != null) {
        await habitDatabase.updateHabitName(habit.id, newHabitName);
        habitDatabase.showMessage("Habit '$habitName' has been updated to '$newHabitName'.");
      } else {
        habitDatabase.showMessage("Habit '$habitName' not found.");
      }
    } else {
      habitDatabase.showMessage("I couldn't find the habit names. Please try again.");
    }
  }

  /// Handler for 'mark_habit_done' intent
  Future<void> handleMarkHabitDone(IntentResponse intentResponse) async {
    final habitNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'habit_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (habitNameEntity.value != null && habitNameEntity.value is String) {
      final habitName = habitNameEntity.value as String;

      final habit = habitDatabase.findHabitByName(habitName);

      if (habit != null) {
        // Assuming that marking as done updates the completion status
        // Here, we set the current day as completed
        await habitDatabase.updateHabitCompletion(habit.id, true);
        habitDatabase.showMessage("Habit '$habitName' marked as done.");
      } else {
        habitDatabase.showMessage("Habit '$habitName' not found.");
      }
    } else {
      habitDatabase.showMessage("I couldn't find the habit name. Please try again.");
    }
  }

  /// Handler for 'read_habits' intent
  void handleReadHabits(IntentResponse intentResponse) {
    final habits = habitDatabase.currentHabits;

    if (habits.isNotEmpty) {
      String habitList = "Here are your habits:\n";
      for (var habit in habits) {
        habitList += "- ${habit.name} (${habit.completedDays.contains(DateTime.now()) ? 'Done' : 'Not Done'})\n";
      }
      habitDatabase.showMessage(habitList);
    } else {
      habitDatabase.showMessage("You have no habits.");
    }
  }

  /// Handler for 'read_completed_habits' intent
  void handleReadCompletedHabits(IntentResponse intentResponse) {
    final completedHabits = habitDatabase.currentHabits.where((habit) =>
        habit.completedDays.contains(DateTime.now()) // Adjust as needed
    ).toList();

    if (completedHabits.isNotEmpty) {
      String habitList = "Here are your completed habits:\n";
      for (var habit in completedHabits) {
        habitList += "- ${habit.name}\n";
      }
      habitDatabase.showMessage(habitList);
    } else {
      habitDatabase.showMessage("You have no completed habits.");
    }
  }

  /// Handler for 'read_remaining_habits' intent
  void handleReadRemainingHabits(IntentResponse intentResponse) {
    final remainingHabits = habitDatabase.currentHabits.where((habit) =>
        !habit.completedDays.contains(DateTime.now()) // Adjust as needed
    ).toList();

    if (remainingHabits.isNotEmpty) {
      String habitList = "Here are your remaining habits:\n";
      for (var habit in remainingHabits) {
        habitList += "- ${habit.name}\n";
      }
      habitDatabase.showMessage(habitList);
    } else {
      habitDatabase.showMessage("You have no remaining habits.");
    }
  }

}
