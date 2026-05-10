import 'package:flutter/material.dart';

class LaunchScreenView extends StatelessWidget {
  const LaunchScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: const Icon(Icons.note, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            // App Title
            const Text(
              'MyNotes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            const Text(
              'Your Personal Notes App',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            // Loading Indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
