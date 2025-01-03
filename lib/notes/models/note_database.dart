import 'package:assisti_fy/notes/models/note.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:isar/isar.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:assisti_fy/isar/isar_database.dart';

class NoteDatabase extends ChangeNotifier{
  // static late Isar isar;

  // static Future<void> initialize() async{
  //   final dir = await getApplicationCacheDirectory();
  //   isar = await Isar.open(
  //     [NoteSchema],
  //     directory: dir.path,
  //     );
  // }

  final List<Note> currentNotes = [];

  Future<void> addNote(String textFromUser) async {
     final newNote = Note()..text = textFromUser;

     await IsarDatabase.isar.writeTxn(() => IsarDatabase.isar.notes.put(newNote));

      fetchNotes();
  }     

 
  Future<void> fetchNotes() async {
    List<Note> fetchedNotes = await IsarDatabase.isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners();
  }

  Future<void> updateNote (int id,String newText) async {
    final existingNote = await IsarDatabase.isar.notes.get(id);
    if (existingNote != null){
      existingNote.text = newText;
      await IsarDatabase.isar.writeTxn(() => IsarDatabase.isar.notes.put(existingNote));
      await fetchNotes();
        }
   }

   Future<void> deleteNote (int id) async {
    await IsarDatabase.isar.writeTxn(() => IsarDatabase.isar.notes.delete(id));
    await fetchNotes();
   }

   /// Finds a note by its text. Returns null if no note is found.
Note? findNoteByText(String text) {
  for (final note in currentNotes) {
    if (note.text == text) {
      return note;
    }
  }
  return null;
}

/// Method to show messages to the user via SnackBar
  void showMessage(String message) {
    Get.snackbar(
      'Assistify',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }

/// Get all notes
  List<Note> getAllNotes() {
    return currentNotes.toList();
  }

}