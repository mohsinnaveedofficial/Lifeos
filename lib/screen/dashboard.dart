import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lifeos/screen/finance.dart';
import 'package:lifeos/screen/goal.dart';
import 'package:lifeos/screen/health.dart';
import 'package:lifeos/screen/journal.dart';
import 'package:lifeos/screen/mentall_Wellness.dart';
import 'package:lifeos/screen/task.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String userName = "There";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf3f4f6),
      body: Container(
        padding: EdgeInsets.fromLTRB(5, 35, 5, 0),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good Morning, $userName 👋",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Here's your daily overview",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      userName.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              Center(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),

                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: CircularProgressIndicator(
                          value: 0.85,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade200,
                          color: Color(0xFF1e3a8a),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "85",
                            style: GoogleFonts.rubik(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1e3a8a),
                            ),
                          ),
                          Text(
                            "SCORE",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  _buildScoreCard(
                    color: Colors.green,
                    title: "Finance",
                    value: 92,
                    bgColor: Colors.green.shade50,
                    icon: FontAwesomeIcons.wallet,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Finance()),
                      );
                    },
                  ),
                  _buildScoreCard(
                    color: Colors.blue,
                    title: "Productivity",
                    value: 78,
                    bgColor: Colors.blue.shade50,
                    icon: FontAwesomeIcons.circleCheck,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Task()),
                      );
                    },
                  ),
                  _buildScoreCard(
                    color: Colors.red,
                    title: "Health",
                    value: 65,
                    bgColor: Colors.red.shade50,
                    icon: FontAwesomeIcons.heartPulse,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Health()),
                      );
                    },
                  ),
                  _buildScoreCard(
                    color: Colors.purple,
                    title: "Mental",
                    value: 88,
                    bgColor: Colors.purple.shade50,
                    icon: Icons.psychology,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MentalWellness()),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: AlignmentGeometry.centerLeft,
                    end: AlignmentGeometry.centerRight,
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
                          CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.timer, color: Colors.white),
                          ),
                          SizedBox(width: 12),
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
                              Text(
                                "Boost your productivity now",
                                style: TextStyle(
                                  color: Colors.indigo.shade100,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Start",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Goals()),
                      );
                    },
                    child: Card(
                      color: Color(0xFFfffaeb),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFFffedd4),
                              child: Icon(
                                Icons.album_outlined,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Goals & Habits",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Track your progress",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Journal()),
                      );
                    },
                    child: Card(
                      color: Color(0xFFfbf4fc),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFFfce7f3),
                              child: FaIcon(
                                FontAwesomeIcons.bookOpen,
                                color: Colors.pink,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Journal",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Daily reflections",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Today Overview",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildOverviewRow(
                      color: Colors.orange,
                      icon: Icons.check_circle,
                      icon_bg: Colors.orange.shade50,
                      title: "Tasks Due",
                      subtitle: "3 pending tasks",
                      value: "5 Total",
                    ),
                    Divider(height: 0, color: Colors.grey.shade300),
                    _buildOverviewRow(
                      color: Colors.green,
                      icon: Icons.credit_card,
                      icon_bg: Colors.green.shade100,
                      title: "Spending",
                      subtitle: "Daily limit: \$50",
                      value: "\$24.50",
                    ),
                    Divider(height: 0, color: Colors.grey.shade300),
                    _buildOverviewRow(
                      color: Colors.blue,
                      icon: Icons.water_drop,
                      icon_bg: Colors.blue.shade100,
                      title: "Water Intake",
                      subtitle: "Goal: 2500ml",
                      value: "1250ml",
                    ),
                    Divider(height: 0, color: Colors.grey.shade300),
                    _buildOverviewRow(
                      color: Colors.purple,
                      icon: Icons.mood,
                      icon_bg: Colors.purple.shade50,
                      title: "Mood Status",
                      subtitle: "Last check-in: 2h ago",
                      value: "Productive",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard({
    required Color color,
    required String title,
    required int value,
    required Color bgColor,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: bgColor,
                child: FaIcon(icon, color: color),
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.raleway(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$value%",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: value / 100,
                backgroundColor: bgColor,
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

  Widget _buildOverviewRow({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    Color? icon_bg,
  }) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(icon, color: color, size: 18),
        backgroundColor: icon_bg,
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      trailing: Text(
        value,
        style: GoogleFonts.rubik(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}
