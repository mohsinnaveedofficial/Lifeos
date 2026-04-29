import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencyMode extends StatelessWidget {
  const EmergencyMode({super.key});

  final Color _emergencyRed = const Color(0xffE11D48);
  final Color _bgPink = const Color(0xffFFF1F2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? theme.scaffoldBackgroundColor : _bgPink,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: _emergencyRed, size: 48),
              const SizedBox(height: 16),
              Text(
                "Emergency Mode",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _emergencyRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Quick access to help when you need it.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? colorScheme.onSurface.withOpacity(0.7)
                      : _emergencyRed.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 60),

              Center(
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: _emergencyRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _emergencyRed.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "SOS",
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),

              _buildActionButton(
                context: context,
                icon: Icons.call,
                label: "Call Emergency Services (911)",
                textColor: _emergencyRed,
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                context: context,
                icon: Icons.share_location,
                label: "Share Live Location",
                textColor: isDark
                    ? colorScheme.onSurface
                    : const Color(0xff1E293B),
              ),
              const SizedBox(height: 32),

              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surface
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark
                          ? colorScheme.outline
                          : _emergencyRed.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Emergency Contacts",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _emergencyRed,
                        ),
                      ),
                    ),
                    Divider(
                        height: 1,
                        color: isDark
                            ? colorScheme.outline
                            : null),
                    _buildContactTile(context, "Mom",
                        "+1 (555) 123-4567"),
                    Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: isDark
                            ? colorScheme.outline
                            : null),
                    _buildContactTile(context, "Partner",
                        "+1 (555) 987-6543"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color textColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
            isDark ? Colors.black54 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(
      BuildContext context, String name, String phone) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDark
                ? colorScheme.surface
                : const Color(0xffFFE4E6),
            child: Icon(Icons.phone_outlined,
                color: _emergencyRed, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  phone,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color:
                    colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "Call",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: _emergencyRed,
            ),
          ),
        ],
      ),
    );
  }
}