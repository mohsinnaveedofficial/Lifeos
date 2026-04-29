import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/controllers/task_controller.dart';

class Task extends StatefulWidget {
  const Task({super.key});

  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> with TickerProviderStateMixin {
  late TabController tabController;
  final TaskController _taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      final tabs = <String>['today', 'upcoming', 'completed'];
      _taskController.setActiveTab(tabs[tabController.index]);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> toggleTask(String id) async {
    try {
      await _taskController.toggleTask(id);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Update failed',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> createTask({
    required String title,
    required DateTime deadline,
    required String category,
    required String priority,
  }) async {
    await _taskController.createTask(
      title: title,
      deadline: deadline,
      category: category,
      priority: priority,
    );
  }

  Future<void> _confirmDeleteTask(Map<String, dynamic> task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete task?'),
          content: const Text('This task will be removed permanently.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final taskId = task['id'] as String;
    final removed = task;
    final index = _taskController.tasks.indexWhere((t) => t['id'] == taskId);
    if (index == -1) return;

    _taskController.tasks.removeAt(index);
    _taskController.tasks.refresh();

    try {
      await _taskController.deleteTask(taskId);
      if (!mounted) return;
      Get.snackbar(
        'Deleted',
        'Task removed successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (!mounted) return;
      _taskController.tasks.insert(index, removed);
      _taskController.tasks.refresh();
      Get.snackbar(
        'Delete failed',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDeadline(BuildContext context, DateTime deadline) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final localizations = MaterialLocalizations.of(context);
    final timeText = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(deadline),
      alwaysUse24HourFormat: false,
    );

    if (_isSameDay(deadline, now)) {
      return 'Today $timeText';
    }
    if (_isSameDay(deadline, tomorrow)) {
      return 'Tomorrow $timeText';
    }

    final dateText = localizations.formatShortDate(deadline);
    return '$dateText $timeText';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Tasks"),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(
        () {
          final filteredTasks = _taskController.filteredTasks();
          final productivityProgress = _taskController.productivityProgress();

          return Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Daily Productivity",
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    "${(productivityProgress * 100).toStringAsFixed(0)}%",
                    style: GoogleFonts.rubik(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              color: colorScheme.primary,
              minHeight: 6,
              value: productivityProgress,
              borderRadius: BorderRadius.circular(20),
              backgroundColor: colorScheme.outline.withOpacity(0.2),
            ),
            const SizedBox(height: 20),
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: colorScheme.outline.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                splashFactory: NoSplash.splashFactory,
                controller: tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: colorScheme.onSurface,
                unselectedLabelColor: colorScheme.onSurface.withOpacity(0.5),
                indicator: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                indicatorPadding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: "Today"),
                  Tab(text: "Upcoming"),
                  Tab(text: "Completed"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_taskController.isLoadingTasks.value)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_taskController.loadError.value != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text(
                      _taskController.loadError.value!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _taskController.loadTasks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              else if (filteredTasks.isEmpty)
              Center(
                child: Text(
                  "No tasks found",
                  style:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                ),
              )
            else
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final taskId = task["id"] as String;
                    final deadline = task["deadline"] as DateTime;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: theme.cardTheme.color,
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: task["completed"]
                              ? colorScheme.outline
                              : colorScheme.primary,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        horizontalTitleGap: 0,
                        leading: Checkbox(
                          value: task["completed"],
                          onChanged: (_) => toggleTask(taskId),
                          shape: const CircleBorder(),
                          activeColor: colorScheme.secondary,
                        ),
                        title: Text(
                          task["title"],
                          style: TextStyle(
                            decoration: task["completed"]
                                ? TextDecoration.lineThrough
                                : null,
                            color: task["completed"]
                                ? colorScheme.onSurface.withOpacity(0.5)
                                : colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _formatDeadline(context, deadline),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.flag,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              task["category"],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: getPriorityColor(
                              task["priority"],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task["priority"],
                            style: TextStyle(
                              color: getPriorityColor(task["priority"]),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onLongPress: () => _confirmDeleteTask(task),
                      ),
                    );
                  },
                ),
              ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => TaskDialog(onCreateTask: createTask),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class TaskDialog extends StatefulWidget {
  const TaskDialog({super.key, required this.onCreateTask});

  final Future<void> Function({
    required String title,
    required DateTime deadline,
    required String category,
    required String priority,
  }) onCreateTask;

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController =
      TextEditingController(text: 'General');

  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> _selectedTime = TimeOfDay.now().obs;
  final RxString _selectedPriority = 'Medium'.obs;
  final RxBool _isSubmitting = false.obs;

  DateTime get _selectedDeadline {
    return DateTime(
      _selectedDate.value.year,
      _selectedDate.value.month,
      _selectedDate.value.day,
      _selectedTime.value.hour,
      _selectedTime.value.minute,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      _selectedDate.value = picked;
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime.value,
    );

    if (picked != null) {
      _selectedTime.value = picked;
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final category = _categoryController.text.trim().isEmpty
        ? 'General'
        : _categoryController.text.trim();

    if (title.isEmpty) {
      Get.snackbar(
        'Missing title',
        'Please enter task title.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      _isSubmitting.value = true;

      await widget.onCreateTask(
        title: title,
        deadline: _selectedDeadline,
        category: category,
        priority: _selectedPriority.value,
      );

      if (!mounted) return;
      Get.back();
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Create failed',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);

    return Obx(
      () => Dialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 20),
                Text(
                  "Add New Task",
                  style: GoogleFonts.rubik(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Task Title",
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "e.g. Read 10 pages",
                hintStyle:
                    TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                filled: true,
                fillColor: colorScheme.surface,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(13),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(13),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: colorScheme.primary.withOpacity(0.4),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date",
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        readOnly: true,
                        onTap: _pickDate,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText:
                              localizations.formatShortDate(_selectedDate.value),
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.primary.withOpacity(0.4),
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Time",
                        style: GoogleFonts.rubik(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        readOnly: true,
                        onTap: _pickTime,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: localizations.formatTimeOfDay(
                            _selectedTime.value,
                            alwaysUse24HourFormat: false,
                          ),
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Icon(
                            Icons.access_time,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.primary.withOpacity(0.4),
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Category",
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _categoryController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "e.g. Study",
                hintStyle:
                    TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                filled: true,
                fillColor: colorScheme.surface,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(13),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(13),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: colorScheme.primary.withOpacity(0.4),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Priority",
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedPriority.value,
              style: TextStyle(color: colorScheme.onSurface),
              dropdownColor: colorScheme.surface,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surface,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(13),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(13),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: colorScheme.primary.withOpacity(0.4),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              items: const [
                DropdownMenuItem(value: "High", child: Text("High")),
                DropdownMenuItem(value: "Medium", child: Text("Medium")),
                DropdownMenuItem(value: "Low", child: Text("Low")),
              ],
              onChanged: (value) {
                if (value == null) return;
                _selectedPriority.value = value;
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting.value ? null : _submit,
                child: _isSubmitting.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Create Task",
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
