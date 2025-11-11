import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const HaelinApp());
}

class HaelinApp extends StatelessWidget {
  const HaelinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Haelin',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFBBD3ED),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const Placeholder(), // Replace with your LoginPage
      },
    );
  }
}

// ---------------- Splash Screen ----------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late VideoPlayerController _videoController;
  bool _videoReady = false;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward(); // fade-in animation

    // Initialize video with better error handling
    _initializeVideo();
    _startSplashSequence();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset('assets/phone_man.mp4');
      
      // Add error listener
      _videoController.addListener(() {
        if (_videoController.value.hasError) {
          print('Video error: ${_videoController.value.errorDescription}');
          if (mounted) {
            setState(() {
              _videoError = true;
            });
          }
        }
      });
      
      await _videoController.initialize();
      
      if (mounted) {
        setState(() {
          _videoReady = true;
        });
        _videoController.setLooping(true);
        _videoController.setVolume(0);
      }
    } catch (e) {
      print('Video initialization failed: $e');
      if (mounted) {
        setState(() {
          _videoError = true;
          _videoReady = true; // Continue to home page anyway
        });
      }
    }
  }

  Future<void> _startSplashSequence() async {
    // Wait at least 3 seconds AND for the video to initialize or fail
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _waitForVideoReady(),
    ]);

    if (mounted) {
      await _controller.reverse(); // fade & shrink out
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomePage(videoController: _videoController),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
          ),
        );
      }
    }
  }

  Future<void> _waitForVideoReady() async {
    while (!_videoReady) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    // Don't dispose video controller here - it's passed to HomePage
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFBBD3ED),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: screenWidth * 0.55,
                height: screenWidth * 0.55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Align(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset('assets/haelin_logo.png'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- Home Page ----------------
class HomePage extends StatefulWidget {
  final VideoPlayerController videoController;
  const HomePage({super.key, required this.videoController});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _videoError = false;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _playVideo();
  }

  Future<void> _playVideo() async {
    try {
      // Only play if video initialized successfully and has no errors
      if (widget.videoController.value.isInitialized && 
          !widget.videoController.value.hasError) {
        await widget.videoController.play();
        setState(() {
          _isVideoPlaying = true;
        });
      } else {
        setState(() {
          _videoError = true;
        });
      }
    } catch (e) {
      print('Video play error: $e');
      setState(() {
        _videoError = true;
      });
    }
  }

  @override
  void dispose() {
    widget.videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.videoController;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Centered video with transparent background support
          Center(
            child: _buildVideoContent(controller),
          ),

          // Continue button
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent(VideoPlayerController controller) {
    // If video has error, show fallback
    if (_videoError) {
      return _buildFallbackContent();
    }
    
    // If video is not ready yet, show loading
    if (!controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    // Video is ready - display with transparent background support
    return Container(
      // This container helps with transparent video rendering
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Remove any background color to maintain transparency
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Video player
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            
            // Loading indicator if video is not playing yet
            if (!_isVideoPlaying)
              Container(
                color: Colors.transparent,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackContent() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent, // Keep transparent for fallback too
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 50, color: Colors.white.withOpacity(0.7)),
          const SizedBox(height: 10),
          Text(
            'Video not supported\non this device',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}