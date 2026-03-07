import 'package:flutter/material.dart';
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
  int currentIndex = 0;
  final pages = [DashboardPage(), Finance(), Task(), Health(), Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: ClipRRect(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 10, 8),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },

              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,

              unselectedItemColor: Colors.grey,
              selectedItemColor: const Color(0xFF1e3a8a),

              showUnselectedLabels: true,

              selectedLabelStyle: GoogleFonts.lato(
                color: const Color(0xFF1e3a8a),
                fontWeight: FontWeight.w400,
              ),

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.wallet_rounded),
                  label: "Finance",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_add_check_outlined),
                  label: "Tasks",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monitor_heart_outlined),
                  label: "Health",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
