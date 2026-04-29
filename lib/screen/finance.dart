import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/models/finance_entry.dart';
import 'package:lifeos/routes/app_routes.dart';
import 'package:lifeos/services/finance_storage_service.dart';

class Finance extends StatefulWidget {
  const Finance({super.key});

  @override
  State<Finance> createState() => _FinanceState();
}

class _FinanceState extends State<Finance> {
  static const List<String> _defaultCategories = <String>[
    'Food',
    'Transport',
    'Shopping',
    'Bills',
  ];

  static const Map<String, Color> _categoryColors = <String, Color>{
    'Food': Colors.red,
    'Transport': Colors.orange,
    'Shopping': Colors.blue,
    'Bills': Colors.green,
  };

  final FinanceStorageService _storage = FinanceStorageService();
  final Random _random = Random();

  List<FinanceEntry> _entries = <FinanceEntry>[];
  bool _isLoading = true;
  final RxInt _stateTick = 0.obs;

  void _refresh() {
    _stateTick.value++;
  }

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final loaded = await _storage.loadEntries();
      loaded.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;

      _entries = loaded;
      _isLoading = false;
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _isLoading = false;
      _refresh();
      Get.snackbar(
        'Finance',
        e is StateError ? e.message : 'Unable to load finance data.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  Future<String?> _addEntry(FinanceEntry entry) async {
    try {
      await _storage.addEntry(entry);

      if (!mounted) return 'Screen is not active.';

      _entries = <FinanceEntry>[entry, ..._entries]
        ..sort((a, b) => b.date.compareTo(a.date));
      _refresh();

      // Keep local UI fast, then sync with remote state in background.
      unawaited(_loadEntries());
      return null;
    } catch (e) {
      return e is StateError ? e.message : 'Unable to save expense.';
    }
  }

  Future<void> _confirmDeleteEntry(FinanceEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete transaction?'),
          content: const Text('This transaction will be removed permanently.'),
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

    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index == -1) return;
    final removed = _entries[index];

    _entries.removeAt(index);
    _refresh();

    try {
      await _storage.deleteEntry(entry.id);
      if (!mounted) return;
      Get.snackbar(
        'Deleted',
        'Transaction deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      if (!mounted) return;
      _entries.insert(index, removed);
      _entries.sort((a, b) => b.date.compareTo(a.date));
      _refresh();
      Get.snackbar(
        'Delete failed',
        e is StateError ? e.message : 'Unable to delete transaction.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  List<String> get _availableCategories {
    final fromEntries = _entries.map((e) => e.category).toSet();
    final categories = <String>{..._defaultCategories, ...fromEntries};
    final sorted = categories.toList()..sort();
    return sorted;
  }

  Map<String, double> get _expenseByCategory {
    final totals = <String, double>{};
    for (final entry in _entries.where((e) => !e.isIncome)) {
      totals.update(entry.category, (v) => v + entry.amount, ifAbsent: () => entry.amount);
    }
    return totals;
  }

  double get _totalIncome =>
      _entries.where((e) => e.isIncome).fold(0, (sum, e) => sum + e.amount);

  double get _totalExpense =>
      _entries.where((e) => !e.isIncome).fold(0, (sum, e) => sum + e.amount);

  double get _balance => _totalIncome - _totalExpense;

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String _formatEntryDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final candidate = DateTime(date.year, date.month, date.day);

    if (candidate == today) {
      final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final suffix = date.hour >= 12 ? 'PM' : 'AM';
      return 'Today, $hour:$minute $suffix';
    }

    if (candidate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }

    final months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  }

  Color _colorForCategory(String category) {
    return _categoryColors[category] ?? Colors.primaries[_random.nextInt(Colors.primaries.length)];
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_outlined;
      case 'Transport':
        return Icons.directions_car_outlined;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Bills':
        return Icons.receipt_long_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  Future<void> _openAddExpenseSheet() async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    String selectedCategory = _availableCategories.first;
    DateTime selectedDate = DateTime.now();
    String? error;
    bool isSaving = false;
    bool isIncome = false;

    await showModalBottomSheet<void>(
      backgroundColor: Theme.of(context).colorScheme.surface,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked == null) return;
              setSheetState(() => selectedDate = picked);
            }

            Future<void> save() async {
              final parsedAmount = double.tryParse(amountController.text.trim());
              final note = noteController.text.trim();

              if (parsedAmount == null || parsedAmount <= 0) {
                setSheetState(() => error = 'Please enter a valid amount.');
                return;
              }
              if (!isIncome && note.isEmpty) {
                setSheetState(() => error = 'Please enter a note/description.');
                return;
              }

              setSheetState(() {
                isSaving = true;
                error = null;
              });

              final entry = FinanceEntry(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: isIncome ? 'Income' : note,
                category: isIncome ? 'Income' : selectedCategory,
                amount: parsedAmount,
                date: selectedDate,
                isIncome: isIncome,
              );

              final saveError = await _addEntry(entry);
              if (!mounted) return;

              if (saveError != null) {
                setSheetState(() {
                  isSaving = false;
                  error = saveError;
                });
                return;
              }

              Get.back<void>();
              Get.snackbar(
                'Saved',
                isIncome ? 'Income added successfully.' : 'Expense added successfully.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade600,
                colorText: Colors.white,
                margin: const EdgeInsets.all(12),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outline,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        isIncome ? 'Add New Income' : 'Add New Expense',
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Expense'),
                                selected: !isIncome,
                                onSelected: (_) {
                                  setSheetState(() {
                                    isIncome = false;
                                    error = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Income'),
                                selected: isIncome,
                                onSelected: (_) {
                                  setSheetState(() {
                                    isIncome = true;
                                    error = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          prefixStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          hintText: '0.00',
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.outline),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1e3a8a)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!isIncome) ...[
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1e3a8a)),
                            ),
                          ),
                          items: _availableCategories
                              .map(
                                (category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setSheetState(() => selectedCategory = value);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        readOnly: true,
                        onTap: pickDate,
                        controller: TextEditingController(
                          text:
                              '${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}',
                        ),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'mm/dd/yyyy',
                          hintStyle: TextStyle(color: Theme.of(context).colorScheme.outline),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF1e3a8a)),
                          ),
                        ),
                      ),
                      if (!isIncome) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: noteController,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'What was this for?',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.outline),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1e3a8a)),
                            ),
                          ),
                        ),
                      ],
                      if (error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          error!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1e3a8a),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: isSaving ? null : save,
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  isIncome ? 'Save Income' : 'Save Expense',
                                   style: GoogleFonts.rubik(color: Colors.white),
                                 ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Get.back<void>(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).colorScheme.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ),
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
  }

  Widget _transactionTile(
    BuildContext context, {
    required FinanceEntry entry,
  }) {
    final tileColor = _colorForCategory(entry.category);
    final amountLabel = '${entry.isIncome ? '+' : '-'}${_formatCurrency(entry.amount)}';

    return Container(
      margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onLongPress: () => _confirmDeleteEntry(entry),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            entry.title,
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            '${entry.category} - ${_formatEntryDate(entry.date)}',
            style: GoogleFonts.rubik(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tileColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(_iconForCategory(entry.category), color: tileColor),
          ),
          trailing: Text(
            amountLabel,
            style: GoogleFonts.rubik(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: entry.isIncome ? Colors.green : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        _stateTick.value;
        final chartSections = _expenseByCategory.entries
            .map(
              (item) => PieChartSectionData(
                color: _colorForCategory(item.key),
                value: item.value,
                showTitle: false,
                radius: 20,
              ),
            )
            .toList();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            Get.offAllNamed(AppRoutes.home);
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              children: [
                Text(
                  'Finance',
                  style: GoogleFonts.rubik(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF1E3A8A), Colors.blue[700]!],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Balance',
                                style: GoogleFonts.rubik(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.blue[100]!,
                                ),
                              ),
                              Text(
                                _formatCurrency(_balance),
                                style: GoogleFonts.rubik(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.wallet_outlined,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.green.withValues(alpha: 0.3),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.north_east,
                                            size: 12,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Income',
                                        style: GoogleFonts.rubik(
                                          color: Colors.lightGreen,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _formatCurrency(_totalIncome),
                                    style: GoogleFonts.rubik(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.red.withValues(alpha: 0.2),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.south_east,
                                            size: 12,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Expense',
                                        style: GoogleFonts.rubik(
                                          color: Colors.red[300],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _formatCurrency(_totalExpense),
                                    style: GoogleFonts.rubik(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  'Spending Overview',
                  style: GoogleFonts.rubik(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: chartSections.isEmpty
                      ? Center(
                          child: Text(
                            'No expenses yet. Add your first one.',
                            style: GoogleFonts.rubik(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        )
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 70,
                            sections: chartSections,
                          ),
                        ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  children: _expenseByCategory.entries.map((e) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.08),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _colorForCategory(e.key),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${e.key} (${_formatCurrency(e.value)})',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.rubik(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                if (_entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      'No transactions yet. Tap + to add expense.',
                      style: GoogleFonts.rubik(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  )
                else
                  ..._entries.take(10).map((entry) => _transactionTile(context, entry: entry)),
                const SizedBox(height: 20),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _openAddExpenseSheet,
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFF1e3a8a),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
