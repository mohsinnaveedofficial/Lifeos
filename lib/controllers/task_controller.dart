import 'package:get/get.dart';
import 'package:lifeos/services/notification_service.dart';
import 'package:lifeos/services/task_storage_service.dart';

class TaskController extends GetxController {
  TaskController(this._taskStorageService, this._notificationService);

  final TaskStorageService _taskStorageService;
  final NotificationService _notificationService;

  final RxList<Map<String, dynamic>> tasks = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingTasks = true.obs;
  final RxnString loadError = RxnString();
  final RxString activeTab = 'today'.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  void setActiveTab(String value) {
    activeTab.value = value;
  }

  Future<void> loadTasks() async {
    try {
      isLoadingTasks.value = true;
      final loaded = await _taskStorageService.loadTasks();
      tasks.assignAll(loaded);
      loadError.value = null;
      await _syncRemindersWithTasks();
    } catch (e) {
      loadError.value = e.toString();
    } finally {
      isLoadingTasks.value = false;
    }
  }

  Future<void> toggleTask(String id) async {
    final index = tasks.indexWhere((t) => t['id'] == id);
    if (index == -1) return;

    final previous = tasks[index]['completed'] == true;
    tasks[index]['completed'] = !previous;
    tasks.refresh();

    try {
      await _taskStorageService.updateTaskCompletion(
        taskId: id,
        completed: !previous,
      );

      if (tasks[index]['completed'] == true) {
        await _notificationService.cancelReminder(id);
      } else {
        await _notificationService.scheduleTaskReminder(
          taskName: tasks[index]['title'] as String,
          deadline: tasks[index]['deadline'] as DateTime,
          taskId: id,
        );
      }
    } catch (e) {
      tasks[index]['completed'] = previous;
      tasks.refresh();
      rethrow;
    }
  }

  Future<void> createTask({
    required String title,
    required DateTime deadline,
    required String category,
    required String priority,
  }) async {
    final newTask = await _taskStorageService.createTask(
      title: title,
      deadline: deadline,
      category: category,
      priority: priority,
    );

    tasks.add(newTask);
    tasks.sort((a, b) {
      final aDeadline = a['deadline'] as DateTime;
      final bDeadline = b['deadline'] as DateTime;
      return aDeadline.compareTo(bDeadline);
    });
    tasks.refresh();

    await _notificationService.scheduleTaskReminder(
      taskName: title,
      deadline: deadline,
      taskId: newTask['id'] as String,
    );
  }

  Future<void> deleteTask(String taskId) {
    return _deleteTaskAndCancelReminder(taskId);
  }

  Future<void> _deleteTaskAndCancelReminder(String taskId) async {
    await _notificationService.cancelReminder(taskId);
    await _taskStorageService.deleteTask(taskId);
  }

  Future<void> _syncRemindersWithTasks() async {
    for (final task in tasks) {
      try {
        final completed = task['completed'] == true;
        if (completed) {
          await _notificationService.cancelReminder(task['id'] as String);
          continue;
        }

        final deadline = task['deadline'] as DateTime;
        if (deadline.isBefore(DateTime.now())) {
          continue;
        }

        await _notificationService.scheduleTaskReminder(
          taskName: task['title'] as String,
          deadline: deadline,
          taskId: task['id'] as String,
        );
      } catch (_) {
        // Reminder sync failures should not block task loading.
      }
    }
  }

  List<Map<String, dynamic>> filteredTasks() {
    final now = DateTime.now();

    return tasks.where((t) {
      final completed = t['completed'] == true;
      final deadline = t['deadline'] as DateTime;

      if (activeTab.value == 'completed') return completed;
      if (activeTab.value == 'today') {
        return !completed && _isSameDay(deadline, now);
      }
      if (activeTab.value == 'upcoming') {
        return !completed && !_isSameDay(deadline, now);
      }
      return true;
    }).toList(growable: false);
  }

  double productivityProgress() {
    if (tasks.isEmpty) return 0;
    final completedCount = tasks.where((t) => t['completed'] == true).length;
    return completedCount / tasks.length;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

