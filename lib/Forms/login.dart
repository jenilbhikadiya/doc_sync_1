import 'package:flutter/material.dart';
import '../Screens/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log In')), // Use const
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                ), // Use const
              ),
              const SizedBox(height: 20.0), // Use const
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  // Use const
                  labelText: 'Password',
                  suffixIcon: Icon(Icons.visibility),
                ),
              ),
              const SizedBox(height: 40.0), // Use const
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // --- Navigation Logic ---
                    // In a real app, you would:
                    // 1. Validate the input fields.
                    // 2. Call your authentication service (e.g., check credentials with a server).
                    // 3. If authentication is successful, then navigate.

                    // Navigate to HomeScreen and replace the LoginScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ), // Use const HomeScreen
                    );
                    // --- End Navigation Logic ---
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A5781),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                    ), // Use const
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    // Use const
                    'Log In',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
