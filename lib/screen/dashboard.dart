import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/controllers/auth_controller.dart';
import 'package:lifeos/controllers/profile_controller.dart';
import 'package:lifeos/models/mental_wellness_entry.dart';
import 'package:lifeos/routes/app_routes.dart';
import 'package:lifeos/services/finance_storage_service.dart';
import 'package:lifeos/services/health_storage_service.dart';
import 'package:lifeos/services/mental_wellness_storage_service.dart';
import 'package:lifeos/services/profile_service.dart';
import 'package:lifeos/services/task_storage_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  final ProfileController _profileController = Get.find<ProfileController>();
  final AuthController _authController = Get.find<AuthController>();

  final RxString userName = "There".obs;
  final RxString userPhotoUrl = "".obs;
  final RxBool _isLoading = true.obs;
  final Rx<String?> _loadError = Rx<String?>(null);

  final RxInt _financeScore = 0.obs;
  final RxInt _productivityScore = 0.obs;
  final RxInt _healthScore = 0.obs;
  final RxInt _mentalScore = 0.obs;

  final RxString _tasksSubtitle = 'No pending tasks'.obs;
  final RxString _tasksValue = '0 Total'.obs;
  final RxString _spendingSubtitle = 'Income today: \$0.00'.obs;
  final RxString _spendingValue = '\$0.00'.obs;
  final RxString _waterSubtitle = 'Goal: 2500ml'.obs;
  final RxString _waterValue = '0ml'.obs;
  final RxString _moodSubtitle = 'No check-ins yet'.obs;
  final RxString _moodValue = 'No mood'.obs;

  final ProfileService _profileService = ProfileService();
  final TaskStorageService _taskStorageService = TaskStorageService();
  final FinanceStorageService _financeStorageService = FinanceStorageService();
  final HealthStorageService _healthStorageService = HealthStorageService();
  final MentalWellnessStorageService _mentalStorageService =
      MentalWellnessStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboard();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDashboard();
    }
  }

  @override
  void activate() {
    super.activate();
    _loadDashboard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    _isLoading.value = true;
    _loadError.value = null;

    try {
      final today = DateTime.now();
      final todayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final results = await Future.wait<dynamic>([
        _profileService.loadProfile(),
        _taskStorageService.loadTasks(),
        _financeStorageService.loadEntries(),
        _healthStorageService.loadDailyEntry(todayKey),
        _mentalStorageService.loadHistory(limit: 1),
      ]);

      if (!mounted) return;

      final profile = results[0];
      final tasks = (results[1] as List).cast<Map<String, dynamic>>();
      final financeEntries = results[2] as List;
      final todayHealth = results[3];
      final latestMental = (results[4] as List).cast<MentalWellnessEntry>();

      final safeName = profile.name.toString().trim();
      final resolvedName = safeName.isEmpty ? 'There' : safeName;

      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t['completed'] == true).length;
      final pendingTasks = totalTasks - completedTasks;
      final productivityScore = totalTasks == 0
          ? 0
          : ((completedTasks / totalTasks) * 100).round().clamp(0, 100);

      double totalIncome = 0;
      double totalExpense = 0;
      double todayIncome = 0;
      double todayExpense = 0;
      for (final entry in financeEntries) {
        final isIncome = entry.isIncome == true;
        final amount = (entry.amount as num).toDouble();
        if (isIncome) {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }

        if (_isSameDay(entry.date as DateTime, today)) {
          if (isIncome) {
            todayIncome += amount;
          } else {
            todayExpense += amount;
          }
        }
      }

      final financeScore = totalIncome <= 0
          ? (totalExpense == 0 ? 0 : 10)
          : (((totalIncome - totalExpense) / totalIncome) * 100)
              .round()
              .clamp(0, 100);

      final healthScore = (todayHealth.healthScore as int).clamp(0, 100);
      final waterMl = (todayHealth.waterMl as int).clamp(0, 99999);

      final latestMood = latestMental.isNotEmpty ? latestMental.first : null;
      final moodScore = latestMood == null
          ? 0
          : (((_moodToScore(latestMood.mood) / 5) * 100).round())
              .clamp(0, 100);

      userName.value = resolvedName;
      userPhotoUrl.value = profile.photoUrl ?? "";
      _financeScore.value = financeScore;
      _productivityScore.value = productivityScore;
      _healthScore.value = healthScore;
      _mentalScore.value = moodScore;

      _tasksSubtitle.value = '$pendingTasks pending tasks';
      _tasksValue.value = '$totalTasks Total';
      _spendingSubtitle.value = 'Income today: ${_formatCurrency(todayIncome)}';
      _spendingValue.value = _formatCurrency(todayExpense);
      _waterSubtitle.value = 'Goal: 2500ml';
      _waterValue.value = '${waterMl}ml';
      _moodSubtitle.value = latestMood == null
          ? 'No check-ins yet'
          : 'Last check-in: ${_lastCheckInLabel(latestMood.dateKey)}';
      _moodValue.value = latestMood?.mood ?? 'No mood';

      _isLoading.value = false;
    } catch (e) {
      if (!mounted) return;
      _loadError.value = '$e';
      _isLoading.value = false;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatCurrency(double amount) => '\$${amount.toStringAsFixed(2)}';

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

  String _lastCheckInLabel(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return dateKey;

    final checkInDate = DateTime(year, month, day);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedCheckIn =
        DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    final diffDays = normalizedToday.difference(normalizedCheckIn).inDays;

    if (diffDays <= 0) return 'Today';
    if (diffDays == 1) return 'Yesterday';
    return '$diffDays days ago';
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  void _showProfileMenu(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                backgroundImage: userPhotoUrl.value.isNotEmpty
                    ? CachedNetworkImageProvider(userPhotoUrl.value)
                    : null,
                child: userPhotoUrl.value.isEmpty
                    ? Text(
                        _initials(userName.value),
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              title: Text(
                userName.value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _authController.currentUser?.email ?? "",
                style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("View Profile"),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(AppRoutes.editProfile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(AppRoutes.notifications);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text("Logout", style: TextStyle(color: colorScheme.error)),
              onTap: () async {
                Navigator.pop(context);
                await _authController.logout();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
            const SizedBox(height: 20),
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
        body: SafeArea(
          child: _isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : _loadError.value != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _loadError.value!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.error),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadDashboard,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDashboard,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${_getGreeting()}, ${userName.value} 👋",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Here's your daily overview",
                                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => _showProfileMenu(context),
                                  child: CircleAvatar(
                                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                    backgroundImage: userPhotoUrl.value.isNotEmpty
                                        ? CachedNetworkImageProvider(userPhotoUrl.value)
                                        : null,
                                    child: userPhotoUrl.value.isEmpty
                                        ? Text(
                                            _initials(userName.value),
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Center(
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.surface,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                    )
                                  ]
                                ),

                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      height: 140,
                                      width: 140,
                                      child: CircularProgressIndicator(
                                        value: (_healthScore.value / 100).clamp(0, 1),
                                        strokeWidth: 8,
                                        backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                                        color: colorScheme.secondary,
                                        strokeCap: StrokeCap.round,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${_healthScore.value}',
                                          style: GoogleFonts.rubik(
                                            fontSize: 42,
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        Text(
                                          "HEALTH SCORE",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ),
                            ),
                            const SizedBox(height: 24),

                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                              children: [
                                _buildScoreCard(
                                  context,
                                  color: Colors.green,
                                  title: "Finance",
                                  value: _financeScore.value,
                                  bgColor: Colors.green.withValues(alpha: 0.1),
                                  icon: FontAwesomeIcons.wallet,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.finance);
                                  },
                                ),
                                _buildScoreCard(
                                  context,
                                  color: colorScheme.primary,
                                  title: "Productivity",
                                  value: _productivityScore.value,
                                  bgColor: colorScheme.primary.withValues(alpha: 0.1),
                                  icon: FontAwesomeIcons.circleCheck,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.task);
                                  },
                                ),
                                _buildScoreCard(
                                  context,
                                  color: colorScheme.error,
                                  title: "Health",
                                  value: _healthScore.value,
                                  bgColor: colorScheme.error.withValues(alpha: 0.1),
                                  icon: FontAwesomeIcons.heartPulse,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.health);
                                  },
                                ),
                                _buildScoreCard(
                                  context,
                                  color: Colors.purple,
                                  title: "Mental",
                                  value: _mentalScore.value,
                                  bgColor: Colors.purple.withValues(alpha: 0.1),
                                  icon: Icons.psychology,
                                  onTap: () {
                                    Get.toNamed(AppRoutes.mentalWellness);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Color(0xFF635eff), Color(0xFF9813fa)],
                                ),
                              ),

                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Colors.white24,
                                          child: Icon(Icons.timer, color: Colors.white),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Start Focus Session",
                                              style: GoogleFonts.rubik(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Text(
                                              "Boost your productivity now",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                   GestureDetector(
                                     onTap: () {
                                       Get.toNamed(AppRoutes.focus);
                                     },
                                     child:  Container(
                                       padding: const EdgeInsets.symmetric(
                                         horizontal: 12,
                                         vertical: 6,
                                       ),
                                       decoration: BoxDecoration(
                                         color: Colors.white,
                                         borderRadius: BorderRadius.circular(20),
                                       ),
                                       child: const Text(
                                         "Start", 
                                         style: TextStyle(
                                           fontWeight: FontWeight.bold,
                                           color: Color(0xFF635eff),
                                           fontSize: 12,
                                         ),
                                       ),
                                     ),
                                   ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                              children: [
                                _buildActionCard(
                                  context,
                                  icon: Icons.album_outlined,
                                  iconColor: Colors.orange,
                                  bgColor: Colors.orange.withValues(alpha: 0.1),
                                  title: "Goals & Habits",
                                  subtitle: "Track your progress",
                                  onTap: () {
                                    Get.toNamed(AppRoutes.goals);
                                  },
                                ),
                                _buildActionCard(
                                  context,
                                  icon: FontAwesomeIcons.bookOpen,
                                  iconColor: Colors.pink,
                                  bgColor: Colors.pink.withValues(alpha: 0.1),
                                  title: "Journal",
                                  subtitle: "Daily reflections",
                                  onTap: () {
                                    Get.toNamed(AppRoutes.journal);
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Today Overview",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              elevation: 0,
                              color: colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1))
                              ),
                              child: Column(
                                children: [
                                  _buildOverviewRow(
                                    context,
                                    color: Colors.orange,
                                    icon: Icons.check_circle,
                                    iconBg: Colors.orange.withValues(alpha: 0.1),
                                    title: "Tasks Due",
                                    subtitle: _tasksSubtitle.value,
                                    value: _tasksValue.value,
                                  ),
                                  Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
                                  _buildOverviewRow(
                                    context,
                                    color: Colors.green,
                                    icon: Icons.credit_card,
                                    iconBg: Colors.green.withValues(alpha: 0.1),
                                    title: "Spending",
                                    subtitle: _spendingSubtitle.value,
                                    value: _spendingValue.value,
                                  ),
                                  Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
                                  _buildOverviewRow(
                                    context,
                                    color: Colors.blue,
                                    icon: Icons.water_drop,
                                    iconBg: Colors.blue.withValues(alpha: 0.1),
                                    title: "Water Intake",
                                    subtitle: _waterSubtitle.value,
                                    value: _waterValue.value,
                                  ),
                                  Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
                                  _buildOverviewRow(
                                    context,
                                    color: Colors.purple,
                                    icon: Icons.mood,
                                    iconBg: Colors.purple.withValues(alpha: 0.1),
                                    title: "Mood Status",
                                    subtitle: _moodSubtitle.value,
                                    value: _moodValue.value,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context, {
    required Color color,
    required String title,
    required int value,
    required Color bgColor,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1))
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: bgColor,
                child: FaIcon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.raleway(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$value%",
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: value / 100,
                backgroundColor: colorScheme.outline.withValues(alpha: 0.1),
                color: color,
                minHeight: 6,
                borderRadius: BorderRadius.circular(20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1))
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: bgColor,
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewRow(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    Color? iconBg,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconBg,
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        )
      ),
      subtitle: Text(
        subtitle, 
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        )
      ),
      trailing: Text(
        value,
        style: GoogleFonts.rubik(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
