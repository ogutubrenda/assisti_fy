// lib/taskapp/controllers/home_controller.dart

import 'package:assisti_fy/taskapp/data/models/task.dart';
import 'package:assisti_fy/taskapp/data/services/storage/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class HomeController extends GetxController {
  final TaskRepository taskRepository;
  HomeController({required this.taskRepository});
  final formKey = GlobalKey<FormState>();
  final editCtrl = TextEditingController();
  final chipIndex = 0.obs;
  final tabIndex = 0.obs;
  final deleting = false.obs;
  final tasks = <Task>[].obs;
  final task = Rx<Task?>(null);
  final doingTodos = <dynamic>[].obs;
  final doneTodos = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    tasks.assignAll(taskRepository.readTasks());
    ever(tasks, (_) => taskRepository.writeTasks(tasks));
  }

  @override
  void onClose() {
    editCtrl.dispose();
    super.onClose();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  void changeChipIndex(int value) {
    chipIndex.value = value;
  }

  void changeDeleting(bool value) {
    deleting.value = value;
  }

  void changeTask(Task? select) {
    task.value = select;
  }

  void changeTodos(List<dynamic> select) {
    doingTodos.clear();
    doneTodos.clear();
    for (var todo in select) {
      var status = todo['done'];
      if (status == true) {
        doneTodos.add(todo);
      } else {
        doingTodos.add(todo);
      }
    }
  }

  bool addTask(Task task) {
    if (tasks.contains(task)) {
      return false;
    }
    tasks.add(task);
    taskRepository.writeTasks(tasks);
    return true;
  }

  void deleteTask(Task task) {
    tasks.remove(task);
  }

  bool updateTask(Task task, String title) {
    var todos = task.todos;
    if (containeTodo(todos, title)) {
      return false;
    }
    var todo = {'title': title, 'done': false};
    todos.add(todo);
    var newTask = task.copyWith(todos: todos);
    int oldIdx = tasks.indexOf(task);
    tasks[oldIdx] = newTask;
    tasks.refresh();
    return true;
  }

  bool containeTodo(List todos, String title) {
    return todos.any((element) => element['title'] == title);
  }

  bool addTodo(String title) {
    var todo = {'title': title, 'done': false};
    if (doingTodos.any((element) => mapEquals<String, dynamic>(todo, element))) {
      return false;
    }
    var doneTodo = {'title': title, 'done': true};
    if (doneTodos.any((element) => mapEquals<String, dynamic>(doneTodo, element))) {
      return false;
    }
    doingTodos.add(todo);
    return true;
  }

  void updateTodos() {
    var newTodos = <Map<String, dynamic>>[];
    newTodos.addAll([
      ...doingTodos,
      ...doneTodos,
    ]);
    var newTask = task.value!.copyWith(todos: newTodos);
    int oldIdx = tasks.indexOf(task.value);
    tasks[oldIdx] = newTask;
    tasks.refresh();
  }

  void doneTodo(String title) {
    var doingTodo = {'title': title, 'done': false};
    int index = doingTodos.indexWhere((element) => mapEquals<String, dynamic>(doingTodo, element));
    if (index != -1) {
      doingTodos.removeAt(index);
      var doneTodo = {'title': title, 'done': true};
      doneTodos.add(doneTodo);
    }
    doingTodos.refresh();
    doneTodos.refresh();
  }

  void deleteDoneTodo(dynamic doneTodo) {
    int index = doneTodos.indexWhere((element) => mapEquals<String, dynamic>(doneTodo, element));
    if (index != -1) {
      doneTodos.removeAt(index); // Fixed from `doneTodos.remove(index)`
    }
    doneTodos.refresh();
  }

  bool isTodoEmpty(Task task) {
    return task.todos.isEmpty;
  }

  int getDoneTodo(Task task) {
    var res = 0;
    for (var todo in task.todos) {
      if (todo['done'] == true) {
        res += 1;
      }
    }
    return res;
  }

  int getTotalTask() {
    var res = 0;
    for (var task in tasks) {
      if (task.todos.isNotEmpty) {
        res += task.todos.length;
      }
    }
    return res;
  }

  int getTotalDoneTask() {
    var res = 0;
    for (var task in tasks) {
      for (var todo in task.todos) {
        if (todo['done'] == true) {
          res += 1;
        }
      }
    }
    return res;
  }

  /// Finds a task by its title. Returns null if no task is found.
  Task? findTaskByTitle(String title) {
    for (final task in tasks) {
      if (task.title == title) {
        return task;
      }
    }
    return null;
  }

  /// Method to show messages to the user via SnackBar using GetX
  void showMessage(String message) {
    Get.snackbar(
      'Assistify',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      backgroundColor: Colors.black54,
      colorText: Colors.white,
      margin: EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  /// Adds a todo to a specific task. Returns true if successful, false otherwise.
  bool addTodoToTask(Task task, String todoTitle) {
    if (containeTodo(task.todos, todoTitle)) {
      return false;
    }
    task.todos.add({'title': todoTitle, 'done': false});
    taskRepository.writeTasks(tasks);
    return true;
  }

  /// Deletes a todo from a specific task. Returns true if successful, false otherwise.
  bool deleteTodoFromTask(Task task, String todoTitle) {
    final todoIndex = task.todos.indexWhere((todo) => todo['title'] == todoTitle);
    if (todoIndex != -1) {
      task.todos.removeAt(todoIndex);
      taskRepository.writeTasks(tasks);
      return true;
    }
    return false;
  }

  /// Marks a specific todo as done within a task. Returns true if successful, false otherwise.
  bool markTodoAsDone(Task task, String todoTitle) {
    final todoIndex = task.todos.indexWhere((todo) => todo['title'] == todoTitle);
    if (todoIndex != -1) {
      task.todos[todoIndex]['done'] = true;
      taskRepository.writeTasks(tasks);
      return true;
    }
    return false;
  }

  /// Retrieves all tasks.
  List<Task> getAllTasks() {
    return tasks.toList();
  }

  /// Retrieves completed tasks.
  List<Task> getCompletedTasks() {
    return tasks.where((task) => task.todos.every((todo) => todo['done'])).toList();
  }

  /// Retrieves remaining tasks.
  List<Task> getRemainingTasks() {
    return tasks.where((task) => task.todos.any((todo) => !todo['done'])).toList();
  }
}
