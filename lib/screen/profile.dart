import 'package:flutter/material.dart';
import 'package:lifeos/screen/emergency_Mode.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Stack(
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/avatar.jpg"),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.08),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xff2C448C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                "John Doe",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              const Text(
                "john.doe@example.com",
                style: TextStyle(color: Colors.black45, fontSize: 13),
              ),

              const SizedBox(height: 28),

              sectionTitle("ACCOUNT"),

              const SizedBox(height: 12),

              settingsCard([
                settingTile(
                  icon: Icons.person_outline,
                  color: Colors.blue,
                  title: "Edit Profile",
                ),
                settingTile(
                  icon: Icons.shield_outlined,
                  color: Colors.green,
                  title: "Change Password",
                ),
                settingTile(
                  icon: Icons.notifications_none,
                  color: Colors.orange,
                  title: "Notifications",
                  last: true,
                ),
              ]),

              const SizedBox(height: 22),

              sectionTitle("PREFERENCES"),

              const SizedBox(height: 12),

              settingsCard([
                settingTile(
                  icon: Icons.dark_mode_outlined,
                  color: Colors.purple,
                  title: "Dark Mode",
                ),
                settingTile(
                  icon: Icons.phone_outlined,
                  color: Colors.red,
                  title: "Emergency Contacts",
                  last: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmergencyMode()),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout, color: Colors.red, size: 18),

                    SizedBox(width: 6),

                    Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              const Text(
                "Version 1.0.0 · LifeOS Inc.",
                style: TextStyle(fontSize: 11, color: Colors.black38),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          color: Colors.black45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget settingTile({
    required IconData icon,
    required Color color,
    required String title,
    VoidCallback? onTap,
    bool last = false,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.black26,
          ),
        ),
        if (!last)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
      ],
    );
  }
}
