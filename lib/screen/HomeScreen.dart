import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/screen/dashboard.dart';
import 'package:lifeos/screen/finance.dart';
import 'package:lifeos/screen/health.dart';
import 'package:lifeos/screen/profile.dart';
import 'package:lifeos/screen/task.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final RxInt currentIndex = 0.obs;
  final pages = [
    const DashboardPage(),
    const Finance(),
    const Task(),
    const Health(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (currentIndex.value != 0) {
          currentIndex.value = 0;
          return;
        }

        SystemNavigator.pop();
      },
      child: Obx(
        () => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: IndexedStack(index: currentIndex.value, children: pages),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(16, 7, 16, 7),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Theme(
                data: theme.copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: currentIndex.value,
                  onTap: (index) {
                    currentIndex.value = index;
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.4),
                  selectedItemColor: colorScheme.primary,
                  showUnselectedLabels: true,
                  selectedLabelStyle: GoogleFonts.lato(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: GoogleFonts.lato(
                    fontSize: 12,
                  ),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined),
                      activeIcon: Icon(Icons.dashboard),
                      label: "Dashboard",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.wallet_rounded),
                      activeIcon: Icon(Icons.account_balance_wallet),
                      label: "Finance",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.library_add_check_outlined),
                      activeIcon: Icon(Icons.library_add_check),
                      label: "Tasks",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.monitor_heart_outlined),
                      activeIcon: Icon(Icons.monitor_heart),
                      label: "Health",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person),
                      label: "Profile",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
