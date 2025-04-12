import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer/Future.delayed
import '../Forms/login.dart'; // Ensure this path is correct for your project

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); // Added const constructor

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin(); // Start the navigation timer
  }

  void _navigateToLogin() {
    // Wait for 3 seconds, then navigate
    Future.delayed(const Duration(seconds: 3), () {
      // Check if the widget is still mounted before navigating
      if (mounted) {
        // Use pushReplacement so the user can't navigate back to the splash screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // A simple Scaffold showing centered text
    return const Scaffold(
      body: Center(
        child: Text(
          'DocSync', // Or 'Splash Screen' or your App Name
          style: TextStyle(
            fontSize: 34.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A5781), // Optional: Use your brand color
          ),
        ),
      ),
      backgroundColor: Colors.white, // Optional: Set a background color
    );
  }

  // Although Future.delayed doesn't strictly need cancellation like a Timer,
  // it's good practice to have a dispose method in a StatefulWidget's State.
  @override
  void dispose() {
    // No active timers to cancel in this specific implementation
    super.dispose();
  }
}
