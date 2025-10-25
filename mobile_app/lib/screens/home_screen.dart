import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final controller = VideoPlayerController.asset('assets/phone_man.mp4');
      await controller.initialize();

      controller
        ..setLooping(true)
        ..setVolume(0)
        ..play();

      if (mounted) {
        setState(() {
          _videoController = controller;
          _isVideoReady = true;
        });
      }
    } catch (e) {
      debugPrint("❌ Video initialization failed: $e");
      if (mounted) {
        setState(() {
          _videoFailed = true;
          _isVideoReady = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// Background pattern
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

          /// Light blue intersecting circles (behind the video)
          Positioned(
            left: -screenWidth * 0.15,
            top: -screenHeight * 0.1,
            child: Container(
              width: screenWidth * 0.9,
              height: screenWidth * 0.9,
              decoration: const BoxDecoration(
                color: Color(0xFFBBD3ED),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -screenWidth * 0.25,
            top: screenHeight * 0.05,
            child: Container(
              width: screenWidth * 1.1,
              height: screenWidth * 1.1,
              decoration: const BoxDecoration(
                color: Color(0xFFBBD3ED),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// Video animation (centered on circles)
          Positioned(
            top: screenHeight * 0.13,
            child: _videoFailed
                ? const Text(
                    "⚠️ Video unsupported on this device.",
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  )
                : _isVideoReady
                    ? SizedBox(
                        width: screenWidth * 0.75,
                        height: screenWidth * 0.75,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: VideoPlayer(_videoController!),
                        ),
                      )
                    : const CircularProgressIndicator(),
          ),

          /// Text: “LET’S GET STARTED...!”
          Positioned(
            left: 30,
            bottom: screenHeight * 0.22,
            child: const Text(
              "LET'S\nGET\nSTARTED...!",
              style: TextStyle(
                color: Colors.black,
                fontSize: 48,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: Offset(0, 4),
                    blurRadius: 4,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),

          /// “Continue” button
          Positioned(
            bottom: 60,
            right: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                _videoController?.pause();
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: const Color(0xFF5A8DEE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadowColor: Colors.black45,
                elevation: 8,
              ),
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Calibri',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
