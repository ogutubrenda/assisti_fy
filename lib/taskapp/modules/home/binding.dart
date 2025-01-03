import 'package:assisti_fy/isar/isar_database.dart';
import 'package:assisti_fy/taskapp/data/providers/task/provider.dart';
import 'package:assisti_fy/taskapp/data/services/storage/repository.dart';
import 'package:assisti_fy/taskapp/modules/home/controller.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController(
      
      taskRepository: TaskRepository(
        taskProvider: TaskProvider(), isar: IsarDatabase.isar,
      ),
    ),
    );
  }
  }
