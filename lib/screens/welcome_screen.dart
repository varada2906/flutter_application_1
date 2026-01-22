import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,

        // 🔽 BOTTOM BAR (WILL NOT HIDE)
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.home, color: Colors.blue),
                Icon(Icons.search),
                Icon(Icons.confirmation_number_outlined),
                Icon(Icons.person_outline),
              ],
            ),
          ),
        ),

        // 🔼 BODY
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome Back! 👋',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ready for your next adventure?',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.notifications, color: Colors.blue),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // Bus / Train toggle
              Row(
                children: [
                  _toggleButton(Icons.directions_bus, 'Bus', false),
                  const SizedBox(width: 12),
                  _toggleButton(Icons.train, 'Train', true),
                ],
              ),

              const SizedBox(height: 20),

              // Search Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search Trains',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    _locationTile(Icons.circle, 'Pune', Colors.blue),
                    const Icon(Icons.swap_vert, color: Colors.grey),
                    _locationTile(Icons.location_on, 'Mumbai', Colors.red),

                    const Divider(height: 30),

                    Row(
                      children: const [
                        Icon(Icons.calendar_today, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('20 Jan, 2026'),
                        Spacer(),
                        Icon(Icons.keyboard_arrow_down),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.train),
                        label: const Text('Search Trains'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Popular Routes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Popular Routes from Pune',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(color: Colors.blue),
                  )
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _routeCard('Pune - Mumbai', '₹450', '4.8'),
                  const SizedBox(width: 12),
                  _routeCard('Pune - Nashik', '₹350', '4.6'),
                ],
              ),

              const SizedBox(height: 80), // space above bottom bar
            ],
          ),
        ),
      ),
    );
  }

  // ===== Widgets =====

  static Widget _toggleButton(IconData icon, String text, bool active) {
    return Expanded(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : Colors.grey),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _locationTile(
      IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  static Widget _routeCard(String route, String price, String rating) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⭐ $rating'),
            const SizedBox(height: 6),
            Text(route, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(price,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
