// import 'dart:async';
// import 'package:assisti_fy/taskapp/data/models/task.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:assisti_fy/voiceassist/database/message_database.dart';
// import 'package:assisti_fy/notes/models/note_database.dart';
// import 'package:assisti_fy/habbittracker/database/habit_database.dart';
// import 'package:assisti_fy/taskapp/modules/home/controller.dart';
// import 'package:assisti_fy/voiceassist/models/intent_response.dart';

// class ApiController extends StatefulWidget {
//   const ApiController({Key? key}) : super(key: key);

//   @override
//   State<ApiController> createState() => _ApiControllerState();
// }

// class _ApiControllerState extends State<ApiController> {
//   late StreamSubscription<IntentResponse> _subscription;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final messageDatabase =
//           Provider.of<MessageDatabase>(context, listen: false);
//       _subscription = messageDatabase.apiResponseStream.listen((intentResponse) {
//         _handleApiResponse(intentResponse);
//       });
//     });
//   }

//   void _handleApiResponse(IntentResponse intentResponse) {
//     debugPrint('Received intent: ${intentResponse.tag}');

//     switch (intentResponse.tag) {
//       case 'add_note':
//         _handleAddNote(intentResponse);
//         break;
//       case 'update_note':
//         _handleUpdateNote(intentResponse);
//         break;
//       case 'delete_note':
//         _handleDeleteNote(intentResponse);
//         break;
//       case 'read_notes':
//         _handleReadNotes(intentResponse);
//         break;
//       case 'add_habit':
//       case 'update_habit':
//       case 'delete_habit':
//       case 'mark_habit_done':
//       case 'read_habits':
//         _handleHabit(intentResponse);
//         break;
//       case 'add_task':
//       case 'update_task':
//       case 'delete_task':
//       case 'add_todo':
//       case 'update_todo':
//       case 'delete_todo':
//       case 'mark_todo_done':
//       case 'read_tasks':
//         _handleTaskOrTodo(intentResponse);
//         break;
//       case 'unknown_command':
//         _showNotification("Sorry, I couldn't understand the command.");
//         break;
//       default:
//         _showResponse(intentResponse);
//     }
//   }

//   /// Handles adding a note
//   void _handleAddNote(IntentResponse intentResponse) async {
//     final noteContent = intentResponse.entities['note_content'];
//     if (noteContent == null || noteContent.isEmpty) {
//       _showNotification("No note content provided.");
//       return;
//     }

//     bool? isConfirmed = await _showConfirmationDialog(
//       title: "Add Note",
//       content: intentResponse.prompt.first.replaceAll("{note_content}", noteContent),
//     );

//     if (isConfirmed == true) {
//       final noteDatabase = Provider.of<NoteDatabase>(context, listen: false);
//       await noteDatabase.addNote(noteContent);
//       _showNotification("Note added: $noteContent");
//     } else {
//       _showNotification(intentResponse.denial.first);
//     }
//   }

//   /// Handles updating a note
//   void _handleUpdateNote(IntentResponse intentResponse) async {
//     final noteContent = intentResponse.entities['note_content'];
//     final newContent = intentResponse.entities['new_content'];
//     if (noteContent == null || noteContent.isEmpty || newContent == null || newContent.isEmpty) {
//       _showNotification("Required note information missing.");
//       return;
//     }

//     final noteDatabase = Provider.of<NoteDatabase>(context, listen: false);
//     final note = noteDatabase.findNoteByText(noteContent);

//     if (note != null) {
//       await noteDatabase.updateNote(note.id, newContent);
//       _showNotification("Note updated: $newContent");
//     } else {
//       _showNotification("Note not found: $noteContent");
//     }
//   }

//   /// Handles deleting a note
//   void _handleDeleteNote(IntentResponse intentResponse) async {
//     final noteContent = intentResponse.entities['note_content'];
//     if (noteContent == null || noteContent.isEmpty) {
//       _showNotification("No note content provided.");
//       return;
//     }

//     final noteDatabase = Provider.of<NoteDatabase>(context, listen: false);
//     final note = noteDatabase.findNoteByText(noteContent);

//     if (note != null) {
//       await noteDatabase.deleteNote(note.id);
//       _showNotification("Note deleted: $noteContent");
//     } else {
//       _showNotification("Note not found: $noteContent");
//     }
//   }

//   /// Handles reading notes
//   void _handleReadNotes(IntentResponse intentResponse) async {
//     final noteDatabase = Provider.of<NoteDatabase>(context, listen: false);
//     await noteDatabase.fetchNotes();

//     final notes = noteDatabase.currentNotes;
//     if (notes.isEmpty) {
//       _showNotification("No notes available.");
//     } else {
//       for (final note in notes) {
//         _showNotification("Note: ${note.text}");
//       }
//     }
//   }

//   /// Handles habits
//   void _handleHabit(IntentResponse intentResponse) async {
//     final habitName = intentResponse.entities['habit_name'];
//     if (habitName == null || habitName.isEmpty) {
//       _showNotification("No habit name provided.");
//       return;
//     }

//     final habitDatabase = Provider.of<HabitDatabase>(context, listen: false);

//     switch (intentResponse.tag) {
//       case 'add_habit':
//         await habitDatabase.addHabit(habitName);
//         _showNotification("Habit added: $habitName");
//         break;

//       case 'delete_habit':
//         final habit = habitDatabase.findHabitByName(habitName);
//         if (habit != null) {
//           await habitDatabase.deleteHabit(habit.id);
//           _showNotification("Habit deleted: $habitName");
//         } else {
//           _showNotification("Habit not found: $habitName");
//         }
//         break;

//       case 'mark_habit_done':
//         final habit = habitDatabase.findHabitByName(habitName);
//         if (habit != null) {
//           await habitDatabase.updateHabitCompletion(habit.id, true);
//           _showNotification("Habit marked as done: $habitName");
//         } else {
//           _showNotification("Habit not found: $habitName");
//         }
//         break;

//       case 'read_habits':
//         await habitDatabase.readHabits();
//         final habits = habitDatabase.currentHabits;
//         if (habits.isEmpty) {
//           _showNotification("No habits available.");
//         } else {
//           for (final habit in habits) {
//             _showNotification("Habit: ${habit.name}");
//           }
//         }
//         break;
//     }
//   }

//   /// Handles tasks and todos
//   void _handleTaskOrTodo(IntentResponse intentResponse) async {
//     final taskOrTodo = intentResponse.entities['task_or_todo'];
//     if (taskOrTodo == null || taskOrTodo.isEmpty) {
//       _showNotification("No task or todo provided.");
//       return;
//     }

//     final homeController = Provider.of<HomeController>(context, listen: false);

//     switch (intentResponse.tag) {
//       case 'add_task':
//         final task = Task(title: taskOrTodo, todos: []);
//         if (homeController.addTask(task)) {
//           _showNotification("Task added: $taskOrTodo");
//         } else {
//           _showNotification("Task already exists.");
//         }
//         break;

//       case 'delete_task':
//         final task = homeController.findTaskByTitle(taskOrTodo);
//         if (task != null) {
//           homeController.deleteTask(task);
//           _showNotification("Task deleted: $taskOrTodo");
//         } else {
//           _showNotification("Task not found: $taskOrTodo");
//         }
//         break;

//       case 'mark_todo_done':
//         homeController.doneTodo(taskOrTodo);
//         _showNotification("Todo marked as done: $taskOrTodo");
//         break;

//       case 'read_tasks':
//         final tasks = homeController.tasks;
//         if (tasks.isEmpty) {
//           _showNotification("No tasks available.");
//         } else {
//           for (final task in tasks) {
//             _showNotification("Task: ${task.title}");
//           }
//         }
//         break;
//     }
//   }

//   /// Displays a SnackBar notification
//   void _showNotification(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   /// Directly shows a response
//   void _showResponse(IntentResponse intentResponse) {
//     if (intentResponse.responses.isNotEmpty) {
//       final response = intentResponse.responses.first;
//       final messageDatabase =
//           Provider.of<MessageDatabase>(context, listen: false);
//       messageDatabase.addMessage(response, false);
//     }
//   }

//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const SizedBox.shrink();
//   }
// }
