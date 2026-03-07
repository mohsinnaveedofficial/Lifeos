import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Journal extends StatefulWidget {
  const Journal({super.key});

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  void _showNewEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "New Journal Entry",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "How are you feeling?",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMoodIcon("😊", "Great"),
                      _buildMoodIcon("🙂", "Good"),
                      _buildMoodIcon("😐", "Okay"),
                      _buildMoodIcon("😔", "Sad"),
                      _buildMoodIcon("😠", "Angry"),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "What are you grateful for? (Add up to 3)",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Type something...",
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xff9CA3AF),
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: const Color(0xffE5E7EB).withOpacity(0.6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xff2947A9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Daily Reflection",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                      "How was your day? What did you learn? What would you like to improve?",
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xff9CA3AF),
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: const Color(0xffE5E7EB).withOpacity(0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffE5E7EB),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.inter(
                              color: const Color(0xff0F172A),
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff8A9BC8),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Save Entry",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoodIcon(String emoji, String label) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffE5E7EB).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xff374151),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Journal",
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showNewEntryDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2947A9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      "New Entry",
                      style: GoogleFonts.rubik(color: Colors.white),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xffF1E8FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                        "Today's Reflection Prompt",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "What made you smile today? Write about a moment that brought you joy, no matter how small.",
                        style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 8),
            Text(
              "Recent Entries",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        entryCard(
          emoji: "😊",
          date: "Feb 24, 2024",
          mood: "Great",
          moodColor: Colors.green,
          gratefulList: [
            "Finished a major project",
            "Great workout session",
            "Quality time with friends"
          ],
          reflection:
          "Today was incredibly productive. I managed to complete my project ahead of schedule and felt energized throughout the day.",
        ),
        const SizedBox(height: 16),
        entryCard(
          emoji: "🙂",
          date: "Feb 23, 2024",
          mood: "Good",
          moodColor: Colors.blue,
          gratefulList: [
            "Sunny weather",
            "Learned something new",
            "Good sleep"
          ],
          reflection:
          "A calm and peaceful day. Focused on learning and self-improvement.",
        ),
        ],
      ),
    ),
    ),
    );
  }

  Widget entryCard({
    required String emoji,
    required String date,
    required String mood,
    required Color moodColor,
    required List<String> gratefulList,
    required String reflection,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xffFFE9B5),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    mood,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: moodColor,
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 16, color: Colors.red),
              const SizedBox(width: 6),
              Text(
                "GRATEFUL FOR",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: gratefulList
                .map(
                  (e) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  "• $e",
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.menu_book_outlined,
                  size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(
                "REFLECTION",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text(
            reflection,
            style: GoogleFonts.inter(fontSize: 13),
          )
        ],
      ),
    );
  }
}