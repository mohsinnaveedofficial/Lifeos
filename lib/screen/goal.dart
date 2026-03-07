import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Goals extends StatefulWidget {
  const Goals({super.key});

  @override
  State<Goals> createState() => _GoalsState();
}

class _GoalsState extends State<Goals> {

  List<bool> habitsCompleted = [
    true,
    true,
    false,
    false,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf3f4f6),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(18, 20, 18, 10),
          child: ListView(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Goals & Habits",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.track_changes_rounded, size: 28)
                ],
              ),

              const SizedBox(height: 25),

              sectionHeader("Daily Habits"),

              const SizedBox(height: 10),

              habitCard(
                index: 0,
                icon: Icons.water_drop,
                color: Colors.blue,
                title: "Drink 8 glasses of water",
                streak: "12 day streak",
              ),

              habitCard(
                index: 1,
                icon: Icons.self_improvement,
                color: Colors.deepPurple,
                title: "Morning meditation",
                streak: "8 day streak",
              ),

              habitCard(
                index: 2,
                icon: Icons.menu_book,
                color: Colors.green,
                title: "Read for 30 minutes",
                streak: "15 day streak",
              ),

              habitCard(
                index: 3,
                icon: Icons.fitness_center,
                color: Colors.orange,
                title: "Exercise",
                streak: "5 day streak",
              ),

              const SizedBox(height: 20),

              sectionHeader("Active Goals"),

              const SizedBox(height: 10),

              goalCard(
                icon: Icons.trending_up,
                color: Colors.blue,
                title: "Read 12 Books",
                subtitle: "Learning",
                progress: 0.58,
                rightText: "7/12",
                percent: "58%",
              ),

              goalCard(
                icon: Icons.savings,
                color: Colors.green,
                title: "Save \$5000",
                subtitle: "Finance",
                progress: 0.64,
                rightText: "3200/5000",
                percent: "64%",
              ),

              goalCard(
                icon: Icons.directions_run,
                color: Colors.orange,
                title: "Run 100km",
                subtitle: "Health",
                progress: 0.42,
                rightText: "42/100",
                percent: "42%",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: const Color(0xffEEF1F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, size: 20),
        )
      ],
    );
  }

  Widget habitCard({
    required int index,
    required IconData icon,
    required Color color,
    required String title,
    required String streak,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
              border: habitsCompleted[index]
                  ? Border.all(
                color: color,
                width: 3,
              )
                  : null,
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
                    )
                  ],
                )
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                habitsCompleted[index] = !habitsCompleted[index];
              });
            },
            child: Icon(
              habitsCompleted[index]
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: habitsCompleted[index]
                  ? Colors.green
                  : Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget goalCard({
    required IconData icon,
    required MaterialColor color,
    required String title,
    required String subtitle,
    required double progress,
    required String rightText,
    required String percent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    )
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
                    ),
                  ),
                  Text(
                    rightText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xffE5E8F0),
              valueColor: AlwaysStoppedAnimation(color.shade700),
            ),
          )
        ],
      ),
    );
  }
}