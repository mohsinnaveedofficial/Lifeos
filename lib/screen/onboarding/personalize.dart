import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/controllers/profile_controller.dart';
import 'package:lifeos/routes/app_routes.dart';

class Personalize extends StatefulWidget {
  const Personalize({super.key});

  @override
  State<Personalize> createState() => _PersonalizeState();
}

class _PersonalizeState extends State<Personalize> {
  final ProfileController _profileController = Get.find<ProfileController>();
  final RxList<int> selected = <int>[].obs;
  final RxString _name = ''.obs;

  List categories = [
    {
      "label": "Health & Fitness",
      "icon": Icons.monitor_heart,
      "bg": Color(0xFFFFEBEE),
      "text": Color(0xFFE53935),
    },
    {
      "label": "Finance",
      "icon": Icons.attach_money,
      "bg": Color(0xFFE8F5E9),
      "text": Color(0xFF43A047),
    },
    {
      "label": "Career & Skills",
      "icon": Icons.work,
      "bg": Color(0xFFE3F2FD),
      "text": Color(0xFF1E88E5),
    },
    {
      "label": "Education",
      "icon": Icons.school,
      "bg": Color(0xFFF3E5F5),
      "text": Color(0xFF8E24AA),
    },
    {
      "label": "Productivity",
      "icon": Icons.track_changes,
      "bg": Color(0xFFFFF3E0),
      "text": Color(0xFFFB8C00),
    },
    {
      "label": "Mental Wellness",
      "icon": Icons.favorite,
      "bg": Color(0xFFFCE4EC),
      "text": Color(0xFFD81B60),
    },
  ];

  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.addListener(() {
      _name.value = nameController.text;
    });
    _loadDraft();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = await _profileController.readOnboardingDraft();
    final draftName = (draft['name'] as String? ?? '').trim();
    final draftFocus = (draft['focusAreas'] as List<dynamic>)
        .map((e) => e.toString())
        .toList(growable: false);

    if (draftName.isNotEmpty || draftFocus.isNotEmpty) {
      if (!mounted) return;
      if (draftName.isNotEmpty) {
        nameController.text = draftName;
      }
      if (draftFocus.isNotEmpty) {
        final next = <int>[];
        for (var i = 0; i < categories.length; i++) {
          if (draftFocus.contains(categories[i]['label'])) {
            next.add(i);
          }
        }
        selected.assignAll(next);
      }
      return;
    }

    try {
      await _profileController.loadProfile();
    } catch (_) {
      return;
    }

    final profile = _profileController.profile.value;
    if (!mounted || profile == null) return;

    final normalizedName = profile.name.trim();
    if (normalizedName.isNotEmpty && normalizedName.toLowerCase() != 'user') {
      nameController.text = profile.name;
    }

    if (profile.focusAreas.isNotEmpty) {
      final next = <int>[];
      for (var i = 0; i < categories.length; i++) {
        if (profile.focusAreas.contains(categories[i]['label'])) {
          next.add(i);
        }
      }
      selected.assignAll(next);
    }
  }

  Future<void> _onContinue() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Required', 'Please enter your name.');
      return;
    }
    if (selected.isEmpty) {
      Get.snackbar('Required', 'Select at least one focus area.');
      return;
    }

    final focusAreas = selected
        .map((index) => categories[index]['label'] as String)
        .toList(growable: false);

    await _profileController.saveOnboardingDraft(
      name: name,
      focusAreas: focusAreas,
    );

    if (!mounted) return;
    Get.toNamed(AppRoutes.complete);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Obx(
        () => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 50, 25, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Let's personalize your experience",
                style: GoogleFonts.rubik(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Help us tailor LifeOS to your needs",
                style: GoogleFonts.rubik(
                  fontSize: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    "What should we call you?",
                    style: GoogleFonts.rubik(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  hintStyle: GoogleFonts.rubik(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: isDark
                      ? colorScheme.surface
                      : const Color(0xFFE5E7EB),
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Icon(Icons.album_outlined,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "What would you like to focus on? (Select at least one)",
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 430,
                child: GridView.builder(
                  itemCount: categories.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 122,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    bool isSelected = selected.contains(index);

                    return GestureDetector(
                      onTap: () {
                        if (isSelected) {
                          selected.remove(index);
                        } else {
                          selected.add(index);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withOpacity(0.1)
                              : (isDark
                              ? colorScheme.surface
                              : Colors.white),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : (isDark
                                ? colorScheme.outline
                                : Colors.grey.shade300),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black54
                                  : Colors.black12,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isDark
                                    ? colorScheme.surface
                                    : categories[index]["bg"],
                              ),
                              child: Icon(
                                categories[index]["icon"],
                                size: 25,
                                color: categories[index]["text"],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              categories[index]["label"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Selected: ${selected.length} areas",
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surface
                      : const Color(0xFFdde1eb),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.primary),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.trending_up_rounded,
                        color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "We'll customize your dashboard and recommendations based on your selections. You can always change these later in Settings.",
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton.icon(
                  onPressed: _onContinue,
                  iconAlignment: IconAlignment.end,
                  icon: Icon(Icons.arrow_forward,
                      color: _name.value.isEmpty
                          ? colorScheme.onSurface
                          : colorScheme.onPrimary),
                  label: Text(
                    "Continue",
                    style: GoogleFonts.rubik(
                      color: _name.value.isEmpty
                          ? colorScheme.onSurface
                          : colorScheme.onPrimary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: _name.value.isEmpty
                        ? (isDark
                        ? colorScheme.outline
                        : const Color(0xFFe5e7eb))
                        : colorScheme.primary,
                    minimumSize: const Size(250, 60),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }
}