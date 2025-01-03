import 'package:assisti_fy/habbittracker/database/habit_database.dart';
import 'package:assisti_fy/habbittracker/pages/home_page.dart';
import 'package:assisti_fy/isar/isar_database.dart';
import 'package:assisti_fy/notes/pages/notes_page.dart';
import 'package:assisti_fy/taskapp/data/providers/task/provider.dart';
import 'package:assisti_fy/taskapp/data/services/storage/repository.dart';
import 'package:assisti_fy/taskapp/data/services/storage/services.dart';
import 'package:assisti_fy/taskapp/modules/home/binding.dart';
import 'package:assisti_fy/taskapp/modules/home/controller.dart';
import 'package:assisti_fy/taskapp/modules/home/view.dart';
import 'package:assisti_fy/theme/theme_provider.dart';

import 'package:assisti_fy/voiceassist/database/message_database.dart';
import 'package:assisti_fy/voiceassist/home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'notes/models/note_database.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Get.putAsync(() => StorageService().init());
  //Initialize note isar database
  await IsarDatabase.initialize();
  //await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLaunchDate();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => NoteDatabase()),
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => HabitDatabase()),
      ChangeNotifierProvider(create: (context) => MessageDatabase(homeController: HomeController(taskRepository: TaskRepository(taskProvider: TaskProvider(), isar: IsarDatabase.isar)), noteDatabase: NoteDatabase(), habitDatabase: HabitDatabase())),
     
    ],
    child: const MyApp(),
  )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
 Widget build(BuildContext context) {
  return GetMaterialApp(
    title: 'Assistify',
    debugShowCheckedModeBanner: false,
    theme: Provider.of<ThemeProvider>(context).themeData,
    home: const VoicePage(),
    initialBinding: HomeBinding(),
    builder: EasyLoading.init(),
  );
}
}
