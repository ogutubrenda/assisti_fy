import 'package:assisti_fy/taskapp/data/models/task.dart';
import 'package:assisti_fy/taskapp/data/providers/task/provider.dart';
import 'package:isar/isar.dart';

class TaskRepository {
  TaskProvider taskProvider;
  TaskRepository({required this.taskProvider, required Isar isar});

  List<Task> readTasks() => taskProvider.readTasks();
  void writeTasks(List<Task> tasks) => taskProvider.writeTasks(tasks);
}