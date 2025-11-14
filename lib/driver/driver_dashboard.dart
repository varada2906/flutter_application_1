import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int passengers = 12;
  String currentRoute = "Pune Station → Hinjewadi";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text("Driver Dashboard", style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _infoCard("Assigned Route", currentRoute, Icons.route),
            const SizedBox(height: 20),
            _infoCard("Passenger Count", "$passengers", Icons.people),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () => setState(() => passengers++),
              icon: const Icon(Icons.add),
              label: const Text("Add Passenger"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.all(12)),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.location_on),
              label: const Text("Share Live Location"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  padding: const EdgeInsets.all(12)),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.report),
              label: const Text("Report Issue"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.all(12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700, size: 28),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.grey.shade700)),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800)),
            ],
          ),
        ],
      ),
    );
  }
}
