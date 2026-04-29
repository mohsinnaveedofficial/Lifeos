import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/models/goal_entry.dart';
import 'package:lifeos/models/habit_entry.dart';
import 'package:lifeos/services/goal_storage_service.dart';
import 'package:lifeos/services/habit_storage_service.dart';

class Goals extends StatefulWidget {
  const Goals({super.key});

  @override
  State<Goals> createState() => _GoalsState();
}

class _GoalsState extends State<Goals> {
  final GoalStorageService _goalStorageService = GoalStorageService();
  final HabitStorageService _habitStorageService = HabitStorageService();

  List<GoalEntry> _goals = <GoalEntry>[];
  List<HabitEntry> _habits = <HabitEntry>[];

  bool _isGoalsLoading = true;
  bool _isHabitsLoading = true;
  String? _goalsError;
  String? _habitsError;
  final RxInt _stateTick = 0.obs;

  void _refresh() {
    _stateTick.value++;
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadGoals(), _loadHabits()]);
  }

  Future<void> _loadGoals() async {
    try {
      final items = await _goalStorageService.loadGoals();
      if (!mounted) return;
      _goals = items;
      _isGoalsLoading = false;
      _goalsError = null;
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _isGoalsLoading = false;
      _goalsError = '$e';
      _refresh();
    }
  }

  Future<void> _loadHabits() async {
    try {
      final items = await _habitStorageService.loadHabits();
      if (!mounted) return;
      _habits = items;
      _isHabitsLoading = false;
      _habitsError = null;
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _isHabitsLoading = false;
      _habitsError = '$e';
      _refresh();
    }
  }

  void _showMessage(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _toggleHabit(HabitEntry habit) async {
    final previous = habit;
    final index = _habits.indexWhere((item) => item.id == habit.id);
    if (index < 0) return;

    final optimistic = habit.copyWith(isCompletedToday: !habit.isCompletedToday);
    _habits[index] = optimistic;
    _refresh();

    try {
      final updated = await _habitStorageService.updateHabitCompletion(
        habit: previous,
        completed: !previous.isCompletedToday,
      );
      if (!mounted) return;
      _habits[index] = updated;
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _habits[index] = previous;
      _refresh();
      _showMessage('$e', isError: true);
    }
  }

  Future<void> _confirmDeleteGoal(GoalEntry goal) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: Text('Delete "${goal.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _goalStorageService.deleteGoal(goal.id);
      await _loadGoals();
      _showMessage('Goal deleted.');
    } catch (e) {
      _showMessage('$e', isError: true);
    }
  }

  Future<void> _confirmDeleteHabit(HabitEntry habit) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: Text('Delete "${habit.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _habitStorageService.deleteHabit(habit.id);
      await _loadHabits();
      _showMessage('Habit deleted.');
    } catch (e) {
      _showMessage('$e', isError: true);
    }
  }

  Future<void> _showAddGoalSheet() async {
    final titleController = TextEditingController();
    final currentController = TextEditingController(text: '0');
    final targetController = TextEditingController(text: '100');

    String category = 'Personal';
    String selectedIcon = 'goal';
    String selectedColor = 'blue';

    const categories = <String>['Personal', 'Health', 'Finance', 'Learning'];

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 44,
                        decoration: BoxDecoration(
                          color: colors.outline.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create New Goal',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Set a target and track your progress daily.',
                      style: TextStyle(color: colors.onSurface.withOpacity(0.65)),
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Goal title'),
                    _prettyField(
                      controller: titleController,
                      hint: 'e.g. Save 5000',
                      colorScheme: colors,
                    ),
                    const SizedBox(height: 12),
                    _fieldLabel('Category'),
                    Wrap(
                      spacing: 8,
                      children: categories.map((item) {
                        final selected = category == item;
                        return ChoiceChip(
                          label: Text(item),
                          selected: selected,
                          onSelected: (_) => setModalState(() => category = item),
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Current'),
                              _prettyField(
                                controller: currentController,
                                hint: '0',
                                keyboardType: TextInputType.number,
                                colorScheme: colors,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Target'),
                              _prettyField(
                                controller: targetController,
                                hint: '100',
                                keyboardType: TextInputType.number,
                                colorScheme: colors,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _fieldLabel('Icon'),
                    Wrap(
                      spacing: 8,
                      children: const ['goal', 'savings', 'run'].map((key) {
                        return _PickerChipData(label: key);
                      }).map((chip) {
                        final selected = selectedIcon == chip.label;
                        return ChoiceChip(
                          label: Text(chip.label),
                          selected: selected,
                          onSelected: (_) => setModalState(() => selectedIcon = chip.label),
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: 12),
                    _fieldLabel('Color'),
                    Wrap(
                      spacing: 10,
                      children: const ['blue', 'green', 'orange'].map((key) {
                        final color = _colorFromKeyStatic(key).shade600;
                        final selected = selectedColor == key;
                        return InkWell(
                          onTap: () => setModalState(() => selectedColor = key),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(color: colors.onSurface, width: 2)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final title = titleController.text.trim();
                              final current =
                                  double.tryParse(currentController.text.trim());
                              final target =
                                  double.tryParse(targetController.text.trim());

                              if (title.isEmpty ||
                                  current == null ||
                                  target == null ||
                                  target <= 0) {
                                _showMessage(
                                  'Please enter valid goal values.',
                                  isError: true,
                                );
                                return;
                              }

                              try {
                                await _goalStorageService.addGoal(
                                  title: title,
                                  subtitle: category,
                                  currentValue: current,
                                  targetValue: target,
                                  iconKey: selectedIcon,
                                  colorKey: selectedColor,
                                );
                                if (!mounted) return;
                                Navigator.of(context).pop(true);
                              } catch (e) {
                                _showMessage('$e', isError: true);
                              }
                            },
                            child: const Text('Create Goal'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (created == true) {
      await _loadGoals();
    }
  }

  Future<void> _showAddHabitSheet() async {
    final titleController = TextEditingController();
    String selectedIcon = 'habit';
    String selectedColor = 'blue';

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 44,
                      decoration: BoxDecoration(
                        color: colors.outline.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create Daily Habit',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _fieldLabel('Habit title'),
                  _prettyField(
                    controller: titleController,
                    hint: 'e.g. Read for 20 minutes',
                    colorScheme: colors,
                  ),
                  const SizedBox(height: 12),
                  _fieldLabel('Icon'),
                  Wrap(
                    spacing: 8,
                    children: const ['habit', 'water', 'book', 'workout', 'meditate']
                        .map((key) {
                      final selected = selectedIcon == key;
                      return ChoiceChip(
                        label: Text(key),
                        selected: selected,
                        onSelected: (_) => setModalState(() => selectedIcon = key),
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  _fieldLabel('Color'),
                  Wrap(
                    spacing: 10,
                    children: const ['blue', 'green', 'orange', 'purple'].map((key) {
                      final color = _colorFromKeyStatic(key).shade600;
                      final selected = selectedColor == key;
                      return InkWell(
                        onTap: () => setModalState(() => selectedColor = key),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(color: colors.onSurface, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final title = titleController.text.trim();
                            if (title.isEmpty) {
                              _showMessage('Please enter habit title.', isError: true);
                              return;
                            }

                            try {
                              await _habitStorageService.addHabit(
                                title: title,
                                iconKey: selectedIcon,
                                colorKey: selectedColor,
                              );
                              if (!mounted) return;
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              _showMessage('$e', isError: true);
                            }
                          },
                          child: const Text('Create Habit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (created == true) {
      await _loadHabits();
    }
  }

  static MaterialColor _colorFromKeyStatic(String key) {
    switch (key) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.deepPurple;
      default:
        return Colors.blue;
    }
  }

  IconData _iconFromKey(String key) {
    switch (key) {
      case 'savings':
        return Icons.savings;
      case 'run':
        return Icons.directions_run;
      case 'water':
        return Icons.water_drop;
      case 'book':
        return Icons.menu_book;
      case 'workout':
        return Icons.fitness_center;
      case 'meditate':
        return Icons.self_improvement;
      default:
        return Icons.track_changes;
    }
  }

  MaterialColor _colorFromKey(String key) {
    return _colorFromKeyStatic(key);
  }

  String _streakLabel(int streak) {
    if (streak <= 0) return 'Start today';
    if (streak == 1) return '1 day streak';
    return '$streak day streak';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
      () {
        _stateTick.value;
        return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Goals & Habits',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    Icons.track_changes_rounded,
                    size: 28,
                    color: theme.colorScheme.onSurface,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _sectionHeader('Daily Habits', onAdd: _showAddHabitSheet),
              const SizedBox(height: 10),
              if (_isHabitsLoading)
                const Center(child: CircularProgressIndicator())
              else if (_habitsError != null)
                Column(
                  children: [
                    Text(
                      _habitsError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _loadHabits, child: const Text('Retry')),
                  ],
                )
              else if (_habits.isEmpty)
                _emptyCard('No habits yet. Tap + to add your first habit.')
              else
                ..._habits.map((habit) {
                  final color = _colorFromKey(habit.colorKey);
                  return GestureDetector(
                    onLongPress: () => _confirmDeleteHabit(habit),
                    child: _habitCard(
                      icon: _iconFromKey(habit.iconKey),
                      color: color,
                      title: habit.title,
                      streak: _streakLabel(habit.streak),
                      completed: habit.isCompletedToday,
                      onToggle: () => _toggleHabit(habit),
                    ),
                  );
                }),
              const SizedBox(height: 20),
              _sectionHeader('Active Goals', onAdd: _showAddGoalSheet),
              const SizedBox(height: 10),
              if (_isGoalsLoading)
                const Center(child: CircularProgressIndicator())
              else if (_goalsError != null)
                Column(
                  children: [
                    Text(
                      _goalsError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: _loadGoals, child: const Text('Retry')),
                  ],
                )
              else if (_goals.isEmpty)
                _emptyCard('No goals yet. Tap + to add your first goal.')
              else
                ..._goals.map((goal) {
                  final progress = goal.targetValue <= 0
                      ? 0.0
                      : (goal.currentValue / goal.targetValue).clamp(0.0, 1.0);
                  final percent = '${(progress * 100).round()}%';
                  final rightText =
                      '${goal.currentValue.toStringAsFixed(0)}/${goal.targetValue.toStringAsFixed(0)}';

                  return GestureDetector(
                    onLongPress: () => _confirmDeleteGoal(goal),
                    child: _goalCard(
                      icon: _iconFromKey(goal.iconKey),
                      color: _colorFromKey(goal.colorKey),
                      title: goal.title,
                      subtitle: goal.subtitle,
                      progress: progress,
                      rightText: rightText,
                      percent: percent,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _prettyField({
    required TextEditingController controller,
    required String hint,
    required ColorScheme colorScheme,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: colorScheme.primary.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _emptyCard(String message) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? onAdd}) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.add, size: 20, color: theme.colorScheme.onTertiary),
          ),
        ),
      ],
    );
  }

  Widget _habitCard({
    required IconData icon,
    required MaterialColor color,
    required String title,
    required String streak,
    required bool completed,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              shape: BoxShape.circle,
              border: completed ? Border.all(color: color, width: 3) : null,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      streak,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completed ? Colors.green : theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalCard({
    required IconData icon,
    required MaterialColor color,
    required String title,
    required String subtitle,
    required double progress,
    required String rightText,
    required String percent,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    percent,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    rightText,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.outline.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation(color.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerChipData {
  const _PickerChipData({required this.label});

  final String label;
}

