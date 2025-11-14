import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double iconSize = 56;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Smart Pune Commute'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_bus, color: Colors.blue, size: 72),
                const SizedBox(height: 16),
                const Text(
                  'Smart Pune Commute',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(color: Colors.blue, width: 1.5),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: iconSize,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Voice assistant tapped')),
                        );
                      },
                      icon: const Icon(Icons.volume_up, color: Colors.green),
                      tooltip: 'Voice Assistant',
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      iconSize: iconSize,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Accessibility tapped')),
                        );
                      },
                      icon: const Icon(
                        Icons.accessibility_new_outlined,
                        color: Colors.grey,
                      ),
                      tooltip: 'Accessibility',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}