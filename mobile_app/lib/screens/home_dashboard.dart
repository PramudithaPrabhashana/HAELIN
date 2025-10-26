import 'dart:math';
import 'package:flutter/material.dart';
import 'diagnose_screen.dart';
import 'map_screen.dart';
import 'medical_record_screen.dart';
import 'chatbot_screen.dart';

class HomeDashboard extends StatefulWidget {
  final String username;

  const HomeDashboard({super.key, required this.username});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  late String _dailyTip;

  // 🧩 List of rotating health tips
  final List<String> _healthTips = [
    "Drink at least 8 glasses of water daily to stay hydrated.",
    "Aim for at least 20 minutes of exercise four times a week.",
    "Take short breaks while working to rest your eyes and stretch.",
    "Eat more fruits and vegetables for a stronger immune system.",
    "Sleep at least 7–8 hours every night for better focus and energy.",
    "Wash your hands regularly to prevent infections.",
    "Avoid skipping breakfast — it fuels your day!",
    "Limit your sugar and salt intake for heart health.",
    "Practice deep breathing to reduce stress and anxiety.",
    "Stay positive — mental health matters as much as physical health.",
  ];

  @override
  void initState() {
    super.initState();
    _generateDailyTip();
  }

  // 🔹 Pick a random tip when the dashboard opens
  void _generateDailyTip() {
    final random = Random();
    setState(() {
      _dailyTip = _healthTips[random.nextInt(_healthTips.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🖼 Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/dashboardbackground.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🌫 Overlay to make text readable
          Container(
            color: Colors.black.withOpacity(0.25),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      color: Colors.blue.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.home, color: Colors.blue),
                            ),
                            Row(
                              children: const [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.notifications,
                                      color: Colors.blue),
                                ),
                                SizedBox(width: 10),
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.menu, color: Colors.blue),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Hi ${widget.username} 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🩺 Health Tip Card with image overlay - FIXED VERSION
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // 📝 Text content with right padding to avoid image overlap
                        Padding(
                          padding: const EdgeInsets.only(right: 90), // Reserve space for image
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today's Health Tip 🩺",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _dailyTip,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                                  onPressed: _generateDailyTip,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 📸 Image positioned on the right
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              'assets/healthtip.png',
                              height: 110,
                              width: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔹 Feature Buttons Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFeatureButton(
                        context,
                        icon: Icons.healing,
                        label: "Check Symptoms",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DiagnoseScreen()),
                          );
                        },
                      ),
                      _buildFeatureButton(
                        context,
                        icon: Icons.map,
                        label: "Find a DOC",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapScreen()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildWideFeatureButton(
                    context,
                    icon: Icons.history,
                    label: "Medical History",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MedicalRecordScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.blueAccent, size: 30),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble,
                  color: Colors.blueAccent, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChatbotScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings,
                  color: Colors.blueAccent, size: 30),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Small square button builder
  Widget _buildFeatureButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF286CB5), Color(0xFF2BBDC7)],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 50),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Wide rectangular button builder
  Widget _buildWideFeatureButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF286CB5), Color(0xFF2BBDC7)],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 50),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}