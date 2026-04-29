import 'package:flutter/material.dart';
  import 'package:get/get.dart';
import 'package:lifeos/models/health_daily_entry.dart';
import 'package:lifeos/services/health_storage_service.dart';

class HealthAnalyticsPage extends StatefulWidget {
  const HealthAnalyticsPage({super.key});

  @override
  State<HealthAnalyticsPage> createState() => _HealthAnalyticsPageState();
}

class _HealthAnalyticsPageState extends State<HealthAnalyticsPage> {
  final HealthStorageService _healthStorageService = HealthStorageService();

  final RxBool _isLoading = true.obs;
  final RxnString _error = RxnString();
  final RxList<HealthDailyEntry> _history = <HealthDailyEntry>[].obs;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final rows = await _healthStorageService.loadHistory(limit: 60);
      if (!mounted) return;
      _history.assignAll(rows);
      _isLoading.value = false;
      _error.value = null;
    } catch (e) {
      if (!mounted) return;
      _isLoading.value = false;
      _error.value = '$e';
    }
  }

  String _formatDate(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return key;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  Widget _summaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(
      () => Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Health Analytics'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _error.value != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error.value!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.error),
                        ),
                        const SizedBox(height: 8),
                        TextButton(onPressed: _loadHistory, child: const Text('Retry')),
                      ],
                    ),
                  )
                : _history.isEmpty
                    ? const Center(child: Text('No previous health data found.'))
                    : ListView.separated(
                        itemCount: _history.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = _history[index];
                          final sleepHours = entry.sleepMinutes ~/ 60;
                          final sleepMins = entry.sleepMinutes % 60;

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(entry.dateKey),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _summaryCard(
                                      context: context,
                                      title: 'Score',
                                      value: '${entry.healthScore}',
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    _summaryCard(
                                      context: context,
                                      title: 'Steps',
                                      value: '${entry.steps}',
                                      color: Colors.orange,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _summaryCard(
                                      context: context,
                                      title: 'Water',
                                      value: '${entry.waterMl} ml',
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    _summaryCard(
                                      context: context,
                                      title: 'Sleep',
                                      value: '${sleepHours}h ${sleepMins.toString().padLeft(2, '0')}m',
                                      color: Colors.purple,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
    ),
    );
  }
}

