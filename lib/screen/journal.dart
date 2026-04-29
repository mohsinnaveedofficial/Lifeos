import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/models/journal_entry.dart';
import 'package:lifeos/services/journal_storage_service.dart';

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  final JournalStorageService _storageService = JournalStorageService();

  static const List<_MoodOption> _moodOptions = <_MoodOption>[
    _MoodOption(emoji: '😊', label: 'Great'),
    _MoodOption(emoji: '🙂', label: 'Good'),
    _MoodOption(emoji: '😐', label: 'Okay'),
    _MoodOption(emoji: '😔', label: 'Sad'),
    _MoodOption(emoji: '😠', label: 'Angry'),
  ];

  Future<void> _showNewEntryDialog(BuildContext context) async {
    final gratefulController = TextEditingController();
    final reflectionController = TextEditingController();
    final gratefulItems = <String>[];

    String selectedMoodEmoji = _moodOptions.first.emoji;
    String selectedMoodLabel = _moodOptions.first.label;
    bool isSaving = false;

    final didSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void addGratitudeItem() {
              if (gratefulItems.length >= 3) {
                Get.snackbar(
                  'Limit reached',
                  'You can only add up to 3 gratitude items.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              final value = gratefulController.text.trim();
              if (value.isEmpty) return;

              setDialogState(() {
                gratefulItems.add(value);
                gratefulController.clear();
              });
            }

            Future<void> saveEntry() async {
              final reflection = reflectionController.text.trim();
              if (reflection.isEmpty) {
                Get.snackbar(
                  'Missing reflection',
                  'Please write a short daily reflection.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              if (isSaving) return;
              setDialogState(() => isSaving = true);

              try {
                await _storageService.createEntry(
                  moodEmoji: selectedMoodEmoji,
                  moodLabel: selectedMoodLabel,
                  gratefulList: gratefulItems,
                  reflection: reflection,
                );

                if (!mounted || !dialogContext.mounted) return;
                Navigator.of(dialogContext).pop(true);
              } catch (e) {
                if (!mounted || !dialogContext.mounted) return;
                setDialogState(() => isSaving = false);
                Get.snackbar(
                  'Save failed',
                  '$e',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Journal Entry',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'How are you feeling?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _moodOptions
                            .map(
                              (mood) => _buildMoodIcon(
                                context,
                                emoji: mood.emoji,
                                label: mood.label,
                                selected: selectedMoodLabel == mood.label,
                                onTap: () {
                                  setDialogState(() {
                                    selectedMoodEmoji = mood.emoji;
                                    selectedMoodLabel = mood.label;
                                  });
                                },
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'What are you grateful for? (Add up to 3)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: gratefulController,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onSubmitted: (_) => addGratitudeItem(),
                              decoration: InputDecoration(
                                hintText: 'Type something...',
                                hintStyle: GoogleFonts.inter(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 48,
                            width: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xff2947A9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: addGratitudeItem,
                            ),
                          ),
                        ],
                      ),
                      if (gratefulItems.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: gratefulItems
                              .map(
                                (item) => Chip(
                                  label: Text(item),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setDialogState(() {
                                      gratefulItems.remove(item);
                                    });
                                  },
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Daily Reflection',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: reflectionController,
                        maxLines: 4,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'How was your day? What did you learn? What would you like to improve?',
                          hintStyle: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.of(dialogContext).pop(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving ? null : saveEntry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff8A9BC8),
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Save Entry',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (mounted && didSave == true) {
      Get.snackbar(
        'Saved',
        'Journal entry saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    gratefulController.dispose();
    reflectionController.dispose();
  }

  Widget _buildMoodIcon(
    BuildContext context, {
    required String emoji,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xff2947A9)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(JournalEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete entry?'),
          content: const Text('This entry will be removed permanently.'),
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
      await _storageService.deleteEntry(entry.id);
      if (!mounted) return;
      Get.snackbar(
        'Deleted',
        'Journal entry removed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Delete failed',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Color _moodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'great':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'okay':
        return Colors.orange;
      case 'sad':
        return Colors.deepPurple;
      case 'angry':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }

  Widget _buildRecentEntries(BuildContext context) {
    try {
      return StreamBuilder<List<JournalEntry>>(
        stream: _storageService.watchEntries(limit: 40),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Text(
              '${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            );
          }

          final entries = snapshot.data ?? const <JournalEntry>[];
          if (entries.isEmpty) {
            return Text(
              'No journal entries yet. Tap New Entry to start.',
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            );
          }

          return Column(
            children: entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: entryCard(context, entry: entry),
                  ),
                )
                .toList(growable: false),
          );
        },
      );
    } catch (e) {
      return Text(
        '$e',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Journal',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showNewEntryDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2947A9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'New Entry',
                      style: GoogleFonts.rubik(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xffF1E8FF).withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark ? 0.1 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Reflection Prompt",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'What made you smile today? Write about a moment that brought you joy, no matter how small.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Entries',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRecentEntries(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget entryCard(
    BuildContext context, {
    required JournalEntry entry,
  }) {
    return GestureDetector(
      onLongPress: () => _confirmDelete(entry),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xffFFE9B5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.moodEmoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(context, entry.createdAt),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      entry.moodLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _moodColor(entry.moodLabel),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.favorite_border, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  'GRATEFUL FOR',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (entry.gratefulList.isEmpty)
              Text(
                'No gratitude items added.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entry.gratefulList
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '• $item',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.menu_book_outlined, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  'REFLECTION',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              entry.reflection,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Long press to delete this entry',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodOption {
  const _MoodOption({required this.emoji, required this.label});

  final String emoji;
  final String label;
}
