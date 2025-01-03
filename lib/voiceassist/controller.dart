// lib/controllers/command_controller.dart

import 'package:assisti_fy/habbittracker/database/habit_database.dart';
import 'package:flutter/material.dart';
//import 'package:assisti_fy/habbittracker/models/habit_database.dart';
import 'package:assisti_fy/notes/models/note_database.dart';
import 'package:provider/provider.dart';

class CommandController {
  final BuildContext context;

  CommandController(this.context);

  // Handle Greeting Intent
  void handleGreeting(String response) {
    // Provide TTS feedback
    // Assuming you have access to TextToSpeechService
    // You might need to pass it or access via Provider
    // For simplicity, let's assume TTS is handled elsewhere
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response)),
    );
  }

  // Handle Add Note Intent
  void handleAddNote(String noteContent) {
    if (noteContent.isNotEmpty) {
      Provider.of<NoteDatabase>(context, listen: false).addNote(noteContent);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added note: $noteContent")),
      );
    } else {
      // Handle empty note content
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No note content provided.")),
      );
    }
  }

  // Handle Add Habit Intent
  void handleAddHabit(String habitName) {
    if (habitName.isNotEmpty) {
      Provider.of<HabitDatabase>(context, listen: false).addHabit(habitName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Added habit: $habitName")),
      );
    } else {
      // Handle empty habit name
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No habit name provided.")),
      );
    }
  }

  // Handle Other Intents...
  // Add more handler methods as needed
}
