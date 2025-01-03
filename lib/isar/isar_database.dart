import 'package:assisti_fy/habbittracker/models/app_settings.dart';
import 'package:assisti_fy/habbittracker/models/habit.dart';
import 'package:assisti_fy/voiceassist/models/message.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:assisti_fy/notes/models/note.dart';

class IsarDatabase extends ChangeNotifier{
  static late Isar isar;

  static Future<void> initialize() async{
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema, NoteSchema, MessageSchema],
      directory: dir.path,);
  }

}