import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lifeos/models/mental_wellness_entry.dart';
import 'package:lifeos/services/mental_wellness_storage_service.dart';

class MentalWellness extends StatefulWidget {
  const MentalWellness({super.key});

  @override
  State<MentalWellness> createState() => _MentalWellnessState();
}

class _MentalWellnessState extends State<MentalWellness> {
  final MentalWellnessStorageService _storageService =
      MentalWellnessStorageService();
  final RxString _selectedMood = 'Happy'.obs;
  final TextEditingController _journalController = TextEditingController();
  final RxBool _isLoading = true.obs;
  final RxBool _isSaving = false.obs;
  final RxList<MentalWellnessEntry> _history = <MentalWellnessEntry>[].obs;

  static const List<String> _moods = <String>[
    'Stressed',
    'Neutral',
    'Happy',
    'Excited',
    'Loved',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      _isLoading.value = true;
      final todayKey = _todayKey();
      final todayEntry = await _storageService.loadDailyEntry(todayKey);
      final history = await _storageService.loadHistory(limit: 21);

      if (!mounted) return;
      _selectedMood.value = todayEntry.mood;
      _journalController.text = todayEntry.journal;
      _history.assignAll(history);
      _isLoading.value = false;
    } catch (e) {
      if (!mounted) return;
      _isLoading.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int _moodToScore(String mood) {
    switch (mood) {
      case 'Stressed':
        return 1;
      case 'Neutral':
        return 2;
      case 'Happy':
        return 3;
      case 'Excited':
        return 4;
      case 'Loved':
        return 5;
      default:
        return 3;
    }
  }

  List<FlSpot> _weeklySpots() {
    final today = DateTime.now();
    final keyToScore = <String, int>{
      for (final entry in _history) entry.dateKey: _moodToScore(entry.mood),
    };

    return List<FlSpot>.generate(7, (index) {
      final day = today.subtract(Duration(days: 6 - index));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      final score = keyToScore[key]?.toDouble() ?? 0;
      return FlSpot(index.toDouble(), score);
    });
  }

  String _formatDateKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return key;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  void _saveEntry() {
    _saveEntryAsync();
  }

  Future<void> _saveEntryAsync() async {
    if (_journalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something in your journal.')),
      );
      return;
    }

    if (_isSaving.value) return;

    try {
      _isSaving.value = true;
      final entry = MentalWellnessEntry(
        dateKey: _todayKey(),
        mood: _selectedMood.value,
        journal: _journalController.text.trim(),
      );

      await _storageService.saveDailyEntry(entry);
      final history = await _storageService.loadHistory(limit: 21);

      if (!mounted) return;
      _history.assignAll(history);
      _journalController.clear();
      _isSaving.value = false;

      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Journal saved for mood: ${_selectedMood.value}'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _isSaving.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _confirmDeleteEntry(MentalWellnessEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete entry?'),
          content: const Text('This journal entry will be removed permanently.'),
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

    final previous = List<MentalWellnessEntry>.from(_history);
    final todayKey = _todayKey();

    _history.removeWhere((item) => item.dateKey == entry.dateKey);
    if (entry.dateKey == todayKey) {
      _selectedMood.value = 'Happy';
      _journalController.clear();
    }

    try {
      await _storageService.deleteDailyEntry(entry.dateKey);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entry deleted successfully.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _history.assignAll(previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(
      () => Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mental Wellness",
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "How are you feeling today?",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: colors.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _moodOption("Stressed", "😫", const Color(0xffFF8A8A)),
                    _moodOption("Neutral", "😐", const Color(0xff8E98A8)),
                    _moodOption("Happy", "😊", const Color(0xff4ade80)),
                    _moodOption("Excited", "⚡", const Color(0xffFACC15)),
                    _moodOption("Loved", "❤️", const Color(0xffF472B6)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildCard(
                title: "Mood Trends",
                child: SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              const days = ["Mon","Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

                              if (value % 1 != 0) {
                                return const SizedBox();
                              }

                              if (value.toInt() >= 0 &&
                                  value.toInt() < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    days[value.toInt()],
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: colors.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _weeklySpots(),
                          isCurved: true,
                          color: colors.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildCard(
                title: "Daily Journal",
                child: Column(
                  children: [
                    TextField(
                      controller: _journalController,
                      maxLines: 4,
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: "Write down your thoughts...",
                        hintStyle: TextStyle(
                          color: colors.onSurface.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colors.outline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving.value ? null : _saveEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Save Entry",
                                style: GoogleFonts.inter(
                                  color: colors.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildCard(
                title: "Recent Entries",
                child: _history.isEmpty
                    ? Text(
                        'No entries yet.',
                        style: GoogleFonts.inter(
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      )
                    : Column(
                        children: _history.take(5).map((entry) {
                          return GestureDetector(
                            onLongPress: () => _confirmDeleteEntry(entry),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.outline.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_formatDateKey(entry.dateKey)}  •  ${entry.mood}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: colors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    entry.journal,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(growable: false),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _moodOption(String label, String emoji, Color color) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _selectedMood.value == label;

    return GestureDetector(
      onTap: () => _selectedMood.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        margin: const EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).cardColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}