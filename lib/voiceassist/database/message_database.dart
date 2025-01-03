// lib/voiceassist/database/message_database.dart

import 'dart:convert';
import 'dart:async';
import 'package:assisti_fy/notes/models/note_database.dart';
import 'package:assisti_fy/taskapp/modules/home/controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart'; // For GetX
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';

// Import your models and handlers
import 'package:assisti_fy/isar/isar_database.dart';
import 'package:assisti_fy/voiceassist/models/intent_response.dart';
import 'package:assisti_fy/voiceassist/models/message.dart';
import 'package:assisti_fy/voiceassist/handlers/task_handlers.dart';
import 'package:assisti_fy/voiceassist/handlers/note_handlers.dart';
import 'package:assisti_fy/voiceassist/handlers/habit_handlers.dart';

// Import your controllers and databases
import 'package:assisti_fy/habbittracker/database/habit_database.dart';

/// Enum to track the current state of the conversation
enum ConversationState {
  idle,
  awaitingConfirmation,
  performingAction,
}

/// MessageDatabase manages the conversation between the user and the assistant.
/// It handles sending user input to the API, receiving responses, managing
/// conversation state, and dispatching intents to appropriate handlers.
class MessageDatabase extends ChangeNotifier {
  /// List to store current messages in the conversation
  final List<Message> _currentMessages = [];
  List<Message> get currentMessages => _currentMessages;

  /// StreamController to handle incoming API responses
  final StreamController<IntentResponse> _apiResponseController =
      StreamController<IntentResponse>.broadcast();
  Stream<IntentResponse> get apiResponseStream => _apiResponseController.stream;

  /// Current state of the conversation
  ConversationState _conversationState = ConversationState.idle;

  /// Temporary storage for pending intents that require confirmation
  IntentResponse? _pendingIntent;

  /// Handler classes to manage different types of intents
  late final TaskHandlers _taskHandlers;
  late final NoteHandlers _noteHandlers;
  late final HabitHandlers _habitHandlers;

  /// References to controllers and databases
  final HomeController _homeController;
  final NoteDatabase _noteDatabase;
  final HabitDatabase _habitDatabase;

  /// Map to associate intent tags with their corresponding handler functions
  late final Map<String, Function(IntentResponse)> _intentHandlers;

  /// Constructor to initialize handlers and set up intent mappings
  MessageDatabase({
    required HomeController homeController,
    required NoteDatabase noteDatabase,
    required HabitDatabase habitDatabase,
  })  : _homeController = homeController,
        _noteDatabase = noteDatabase,
        _habitDatabase = habitDatabase {
    // Initialize handler classes with necessary dependencies
     _taskHandlers = TaskHandlers(homeController: _homeController);
     _noteHandlers = NoteHandlers(noteDatabase: _noteDatabase);
     _habitHandlers = HabitHandlers(habitDatabase: _habitDatabase);

    // Define the intent handlers map
    _intentHandlers = {
      // Task Intents
      'add_task': _taskHandlers.handleAddTask,
      'delete_task': _taskHandlers.handleDeleteTask,
      'update_task': _taskHandlers.handleUpdateTask,
      'add_todo': _taskHandlers.handleAddTodo,
      'delete_todo': _taskHandlers.handleDeleteTodo,
      'mark_todo_done': _taskHandlers.handleMarkTodoDone,
      'read_tasks': _taskHandlers.handleReadTasks,
      'read_completed_tasks': _taskHandlers.handleReadCompletedTasks,
      'read_remaining_tasks': _taskHandlers.handleReadRemainingTasks,
      // Note Intents
      'add_note': _noteHandlers.handleAddNote,
      'delete_note': _noteHandlers.handleDeleteNote,
      'update_note': _noteHandlers.handleUpdateNote,
      'read_notes': _noteHandlers.handleReadNotes,
      // Habit Intents
      'add_habit': _habitHandlers.handleAddHabit,
      'delete_habit': _habitHandlers.handleDeleteHabit,
      'update_habit': _habitHandlers.handleUpdateHabit,
      'mark_habit_done': _habitHandlers.handleMarkHabitDone,
      'read_habits': _habitHandlers.handleReadHabits,
      'read_completed_habits': _habitHandlers.handleReadCompletedHabits,
      'read_remaining_habits': _habitHandlers.handleReadRemainingHabits,
      // Add other intents and their handlers here
    };

    // Listen to API responses and handle them accordingly
    _apiResponseController.stream.listen(_handleApiResponse);
  }

  /// Adds a new message to the conversation.
  /// If the message is from the user, it sends the input to the API.
  Future<void> addMessage(String text, bool isUser) async {
    final message = Message(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    );
    _currentMessages.add(message);
    notifyListeners();

    if (isUser) {
      await _sendToApi(text);
    }
  }

  /// Sends user input to the API endpoint and processes the response.
 Future<void> _sendToApi(String userInput) async {
  try {
    final String apiUrl = 'http://192.168.100.237:8000/predict'; // Ensure this is correct
    debugPrint('Sending POST request to: $apiUrl with input: $userInput');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'input': userInput}),
    );

    debugPrint('API Response Status: ${response.statusCode}');
    debugPrint('API Response Body: ${response.body}'); // Log the response body

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final intentResponse = IntentResponse.fromJson(responseData);
      _apiResponseController.add(intentResponse);
    } else {
      _handleErrorResponse(
          'Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    _handleErrorResponse('Exception: $e');
  }
}


  /// Handles error responses from the API by adding an error message
  /// to the conversation and triggering an 'error' intent.
  void _handleErrorResponse(String errorMessage) {
    final intentResponse = IntentResponse(
      predictedIntent: 'error',
      tag: 'error',
      entities: [],
      prompt: [],
      confirmation: [],
      denial: [],
    );
    _apiResponseController.add(intentResponse);
    addMessage(errorMessage, false);
  }

  /// Processes API responses based on the current conversation state.
  void _handleApiResponse(IntentResponse intentResponse) {
    switch (_conversationState) {
      case ConversationState.idle:
        _handleIdleState(intentResponse);
        break;
      case ConversationState.awaitingConfirmation:
        _handleAwaitingConfirmationState(intentResponse);
        break;
      case ConversationState.performingAction:
        // Currently, no actions are performed in this state
        break;
    }
  }

  /// Handles API responses when the conversation is in the idle state.
  void _handleIdleState(IntentResponse intentResponse) {
    if (intentResponse.tag == 'confirmation' ||
        intentResponse.tag == 'denial') {
      // Unexpected confirmation or denial
      addMessage("I'm not sure what you're referring to.", false);
      return;
    }

    if (intentResponse.tag == 'unknown_command') {
      addMessage("Sorry, I didn't understand that.", false);
      return;
    }

    // Check if the intent requires user confirmation
    if (_requiresConfirmation(intentResponse)) {
      _pendingIntent = intentResponse;
      _conversationState = ConversationState.awaitingConfirmation;
      // Prompt the user for confirmation
      if (intentResponse.prompt.isNotEmpty) {
        addMessage(intentResponse.prompt.first, false);
      } else {
        addMessage("Can you please confirm that?", false);
      }
    } else {
      // Directly execute the intent without confirmation
      _executeIntent(intentResponse);
    }
  }

  /// Determines if a given intent requires user confirmation.
  bool _requiresConfirmation(IntentResponse intentResponse) {
    // Define which intents require confirmation
    const intentsRequiringConfirmation = [
      'add_task',
      'delete_task',
      'update_task',
      'add_note',
      'delete_note',
      'update_note',
      'add_habit',
      'delete_habit',
      'update_habit',
      'mark_habit_done',
      'add_todo',
      'delete_todo',
      'mark_todo_done',
      // Add other intents as needed
    ];
    return intentsRequiringConfirmation.contains(intentResponse.tag);
  }

  /// Handles API responses when the conversation is awaiting user confirmation.
  void _handleAwaitingConfirmationState(IntentResponse intentResponse) {
    if (intentResponse.tag == 'confirmation') {
      if (_pendingIntent != null) {
        // Execute the pending intent upon confirmation
        _executeIntent(_pendingIntent!);
      }
      _conversationState = ConversationState.idle;
      _pendingIntent = null;
    } else if (intentResponse.tag == 'denial') {
      addMessage("Okay, I won't proceed with that.", false);
      _conversationState = ConversationState.idle;
      _pendingIntent = null;
    } else {
      // Handle unexpected responses
      addMessage("Please confirm your request.", false);
    }
  }

  /// Dispatches the intent to the appropriate handler based on the intent tag.
  void _executeIntent(IntentResponse intentResponse) {
    final intent = intentResponse.tag;
    final handler = _intentHandlers[intent];
    if (handler != null) {
      handler(intentResponse);
    } else {
      addMessage("I'm not equipped to handle that yet.", false);
    }
  }

  /// Fetches all messages from the Isar database and updates the current messages list.
  Future<void> fetchMessages() async {
    try {
      final messages = await IsarDatabase.isar.messages
          .where()
          .sortByTimestamp() // Sort by timestamp ascending
          .findAll();
      _currentMessages.clear();
      _currentMessages.addAll(messages.map((msg) => Message(
            text: msg.text,
            isUser: msg.isUser,
            timestamp: msg.timestamp,
          )));
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch messages: $e');
    }
  }

  /// Closes the StreamController when disposing the object.
  @override
  void dispose() {
    _apiResponseController.close();
    super.dispose();
  }
}
