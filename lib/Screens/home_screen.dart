// home_screen.dart
import 'package:flutter/material.dart';
import '../components/drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: true, // Enables menu icon for drawer
      ),
      drawer: const AnimatedDrawer(), // Add the drawer here
      body: const Center(
        child: Text('Welcome Home!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
