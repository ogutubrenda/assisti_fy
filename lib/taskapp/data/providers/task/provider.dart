import 'dart:convert';

import 'package:assisti_fy/taskapp/core/utils/keys.dart';
import 'package:assisti_fy/taskapp/data/models/task.dart';
import 'package:assisti_fy/taskapp/data/services/storage/services.dart';
import 'package:get/get.dart';

//import '../../services/storage/repository.dart';

class TaskProvider {
  final _storage = Get.find<StorageService>();

  // {'tasks':[
  //   {'title': 'Work',
  //   'color': '#ff123456'
  //   'icon': 0xe123}
  // ]}

  List<Task> readTasks() {
  var tasks = <Task>[];
  var storedData = _storage.read(taskKey);

  if (storedData != null) {
    jsonDecode(storedData.toString())
        .forEach((e) => tasks.add(Task.fromJson(e)));
  }

  return tasks;
}


  void writeTasks(List<Task> tasks){
    _storage.write(taskKey, jsonEncode(tasks));
  }
}