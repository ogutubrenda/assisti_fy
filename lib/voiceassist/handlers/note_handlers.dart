// lib/voiceassist/handlers/note_handlers.dart

//import 'package:assisti_fy/notes/database/note_database.dart';
import 'package:assisti_fy/notes/models/note_database.dart';
import 'package:assisti_fy/voiceassist/models/intent_response.dart';

class NoteHandlers {
  final NoteDatabase noteDatabase;

  NoteHandlers({required this.noteDatabase});

  /// Handler for 'add_note' intent
  void handleAddNote(IntentResponse intentResponse) {
    final noteTextEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'note_text',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (noteTextEntity.value != null && noteTextEntity.value is String) {
      final noteText = noteTextEntity.value as String;

      noteDatabase.addNote(noteText);
      noteDatabase.showMessage("Note added successfully.");
    } else {
      noteDatabase.showMessage("I couldn't understand the note text. Please try again.");
    }
  }

  /// Handler for 'delete_note' intent
  void handleDeleteNote(IntentResponse intentResponse) {
    final noteTextEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'note_text',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (noteTextEntity.value != null && noteTextEntity.value is String) {
      final noteText = noteTextEntity.value as String;

      final note = noteDatabase.findNoteByText(noteText);

      if (note != null) {
        noteDatabase.deleteNote(note.id!);
        noteDatabase.showMessage("Note deleted successfully.");
      } else {
        noteDatabase.showMessage("Note not found.");
      }
    } else {
      noteDatabase.showMessage("I couldn't understand the note text. Please try again.");
    }
  }

  /// Handler for 'update_note' intent
  void handleUpdateNote(IntentResponse intentResponse) {
    final noteTextEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'note_text',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    final newNoteTextEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'new_note_text',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (noteTextEntity.value != null &&
        noteTextEntity.value is String &&
        newNoteTextEntity.value != null &&
        newNoteTextEntity.value is String) {
      final noteText = noteTextEntity.value as String;
      final newNoteText = newNoteTextEntity.value as String;

      final note = noteDatabase.findNoteByText(noteText);

      if (note != null) {
        noteDatabase.updateNote(note.id!, newNoteText);
        noteDatabase.showMessage("Note updated successfully.");
      } else {
        noteDatabase.showMessage("Note not found.");
      }
    } else {
      noteDatabase.showMessage("I couldn't understand the note texts. Please try again.");
    }
  }

  /// Handler for 'read_notes' intent
  void handleReadNotes(IntentResponse intentResponse) {
    final notes = noteDatabase.getAllNotes();

    if (notes.isNotEmpty) {
      String noteList = "Here are your notes:\n";
      for (var note in notes) {
        noteList += "- ${note.text}\n";
      }
      noteDatabase.showMessage(noteList);
    } else {
      noteDatabase.showMessage("You have no notes.");
    }
  }

  
}
