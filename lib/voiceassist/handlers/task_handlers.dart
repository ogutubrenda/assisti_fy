// lib/voiceassist/handlers/task_handlers.dart

import 'package:assisti_fy/taskapp/data/models/task.dart';
import 'package:assisti_fy/taskapp/data/services/storage/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:assisti_fy/taskapp/controllers/home_controller.dart';
import 'package:assisti_fy/taskapp/modules/home/controller.dart';
import 'package:assisti_fy/voiceassist/models/intent_response.dart';

class TaskHandlers {
  final HomeController homeController;

  TaskHandlers({required this.homeController});

  /// Handler for 'add_task' intent
  void handleAddTask(IntentResponse intentResponse) {
    final taskNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'task_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (taskNameEntity.value != null && taskNameEntity.value is String) {
      final taskName = taskNameEntity.value as String;

      // lib/voiceassist/handlers/task_handlers.dart

final task = Task(
  title: taskName,
  icon: 0, // Assign a default icon value or retrieve dynamically
  color: 'blue', // Assign a default color or retrieve dynamically
  todos: [],
);

      final success = homeController.addTask(task);

      if (success) {
        // Notify user of success
        homeController.showMessage("Task '$taskName' added successfully.");
      } else {
        // Notify user if task already exists
        homeController.showMessage("Task '$taskName' already exists.");
      }
    } else {
      // Notify user if task name is missing
      homeController.showMessage("I couldn't find the task name. Please try again.");
    }
  }

  /// Handler for 'delete_task' intent
  void handleDeleteTask(IntentResponse intentResponse) {
    final taskNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'task_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (taskNameEntity.value != null && taskNameEntity.value is String) {
      final taskName = taskNameEntity.value as String;

      final task = homeController.findTaskByTitle(taskName);

      if (task != null) {
        homeController.deleteTask(task);
        homeController.showMessage("Task '$taskName' has been deleted.");
      } else {
        homeController.showMessage("Task '$taskName' not found.");
      }
    } else {
      homeController.showMessage("I couldn't find the task name. Please try again.");
    }
  }

  /// Handler for 'update_task' intent
  void handleUpdateTask(IntentResponse intentResponse) {
    final taskNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'task_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    final newTaskNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'new_task_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (taskNameEntity.value != null &&
        taskNameEntity.value is String &&
        newTaskNameEntity.value != null &&
        newTaskNameEntity.value is String) {
      final taskName = taskNameEntity.value as String;
      final newTaskName = newTaskNameEntity.value as String;

      final task = homeController.findTaskByTitle(taskName);

      if (task != null) {
        homeController.updateTask(task, newTaskName);
        homeController.showMessage("Task '$taskName' has been updated to '$newTaskName'.");
      } else {
        homeController.showMessage("Task '$taskName' not found.");
      }
    } else {
      homeController.showMessage("I couldn't find the task names. Please try again.");
    }
  }

  /// Handler for 'add_todo' intent
  void handleAddTodo(IntentResponse intentResponse) {
    final taskNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'task_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    final todoTitleEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'todo_title',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (taskNameEntity.value != null &&
        taskNameEntity.value is String &&
        todoTitleEntity.value != null &&
        todoTitleEntity.value is String) {
      final taskName = taskNameEntity.value as String;
      final todoTitle = todoTitleEntity.value as String;

      final task = homeController.findTaskByTitle(taskName);

      if (task != null) {
        final success = homeController.addTodoToTask(task, todoTitle);
        if (success) {
          homeController.showMessage("Todo '$todoTitle' added to task '$taskName'.");
        } else {
          homeController.showMessage("Todo '$todoTitle' already exists in task '$taskName'.");
        }
      } else {
        homeController.showMessage("Task '$taskName' not found.");
      }
    } else {
      homeController.showMessage("I couldn't find the task or todo title. Please try again.");
    }
  }

  /// Handler for 'delete_todo' intent
  void handleDeleteTodo(IntentResponse intentResponse) {
    final taskNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'task_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    final todoTitleEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'todo_title',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (taskNameEntity.value != null &&
        taskNameEntity.value is String &&
        todoTitleEntity.value != null &&
        todoTitleEntity.value is String) {
      final taskName = taskNameEntity.value as String;
      final todoTitle = todoTitleEntity.value as String;

      final task = homeController.findTaskByTitle(taskName);

      if (task != null) {
        final success = homeController.deleteTodoFromTask(task, todoTitle);
        if (success) {
          homeController.showMessage("Todo '$todoTitle' deleted from task '$taskName'.");
        } else {
          homeController.showMessage("Todo '$todoTitle' not found in task '$taskName'.");
        }
      } else {
        homeController.showMessage("Task '$taskName' not found.");
      }
    } else {
      homeController.showMessage("I couldn't find the task or todo title. Please try again.");
    }
  }

  /// Handler for 'mark_todo_done' intent
  void handleMarkTodoDone(IntentResponse intentResponse) {
    final taskNameEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'task_name',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    final todoTitleEntity = intentResponse.entities.firstWhere(
      (entity) => entity.name == 'todo_title',
      orElse: () => Entity(name: '', type: '', value: null),
    );

    if (taskNameEntity.value != null &&
        taskNameEntity.value is String &&
        todoTitleEntity.value != null &&
        todoTitleEntity.value is String) {
      final taskName = taskNameEntity.value as String;
      final todoTitle = todoTitleEntity.value as String;

      final task = homeController.findTaskByTitle(taskName);

      if (task != null) {
        final success = homeController.markTodoAsDone(task, todoTitle);
        if (success) {
          homeController.showMessage("Todo '$todoTitle' marked as done in task '$taskName'.");
        } else {
          homeController.showMessage("Todo '$todoTitle' not found in task '$taskName'.");
        }
      } else {
        homeController.showMessage("Task '$taskName' not found.");
      }
    } else {
      homeController.showMessage("I couldn't find the task or todo title. Please try again.");
    }
  }

  /// Handler for 'read_tasks' intent
  void handleReadTasks(IntentResponse intentResponse) {
    final tasks = homeController.getAllTasks();

    if (tasks.isNotEmpty) {
      String taskList = "Here are your tasks:\n";
      for (var task in tasks) {
        taskList += "- ${task.title}\n";
      }
      homeController.showMessage(taskList);
    } else {
      homeController.showMessage("You have no tasks.");
    }
  }

  /// Handler for 'read_completed_tasks' intent
  void handleReadCompletedTasks(IntentResponse intentResponse) {
    final completedTasks = homeController.getCompletedTasks();

    if (completedTasks.isNotEmpty) {
      String taskList = "Here are your completed tasks:\n";
      for (var task in completedTasks) {
        taskList += "- ${task.title}\n";
      }
      homeController.showMessage(taskList);
    } else {
      homeController.showMessage("You have no completed tasks.");
    }
  }

  /// Handler for 'read_remaining_tasks' intent
  void handleReadRemainingTasks(IntentResponse intentResponse) {
    final remainingTasks = homeController.getRemainingTasks();

    if (remainingTasks.isNotEmpty) {
      String taskList = "Here are your remaining tasks:\n";
      for (var task in remainingTasks) {
        taskList += "- ${task.title}\n";
      }
      homeController.showMessage(taskList);
    } else {
      homeController.showMessage("You have no remaining tasks.");
    }
  }

  
}
