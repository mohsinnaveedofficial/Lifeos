import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class MentalWellness extends StatefulWidget {
  const MentalWellness({super.key});

  @override
  State<MentalWellness> createState() => _MentalWellnessState();
}

class _MentalWellnessState extends State<MentalWellness> {
  String _selectedMood = 'Happy';
  final TextEditingController _journalController = TextEditingController();

  final Color _primaryBlue = const Color(0xff183268);
  final Color _bgColor = const Color(0xffF3F4F8);

  void _saveEntry() {
    if (_journalController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Journal saved for mood: $_selectedMood'),
          backgroundColor: _primaryBlue,
        ),
      );
      _journalController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mental Wellness",
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "How are you feeling today?",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xff7C8BA0),
                ),
              ),
              const SizedBox(height: 20),

            SizedBox(height: 100,child:   ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _moodOption("Stressed", "😫", const Color(0xffFF8A8A)),
                _moodOption("Neutral", "😐", const Color(0xff8E98A8)),
                _moodOption("Happy", "😊", const Color(0xff4ade80)),
                _moodOption("Excited", "⚡", const Color(0xffFACC15)),
                _moodOption("Loved", "❤️", const Color(0xffF472B6)),
              ],
            ),),
              const SizedBox(height: 20),

              _buildCard(
                title: "Mood Trends",
                child: SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ["Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(days[value.toInt()],
                                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
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
                          spots: const [
                            FlSpot(0, 3),
                            FlSpot(1, 4),
                            FlSpot(2, 2),
                            FlSpot(3, 5),
                            FlSpot(4, 4),
                            FlSpot(5, 4.5),
                          ],
                          isCurved: true,
                          color: _primaryBlue,
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
                      decoration: InputDecoration(
                        hintText: "Write down your thoughts...",
                        filled: true,
                        fillColor: const Color(0xffFAFAFA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xffE5E7EB)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text("Save Entry", style: GoogleFonts.inter(color: Colors.white)),
                      ),
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

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: _primaryBlue)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _moodOption(String label, String emoji, Color color) {
    bool isSelected = _selectedMood == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = label),
      child: Container(
padding: EdgeInsets.only(left: 7, right:7,top: 5,bottom: 5),
        margin: EdgeInsets.only(right: 5),
        decoration: BoxDecoration(
          color:  isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? _primaryBlue : Colors.transparent, width: 2),
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
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      )
    );
  }
}



