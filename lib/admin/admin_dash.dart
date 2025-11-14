import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/admin/bus_transport.dart';
import 'package:flutter_application_1/admin/manage_routes.dart';
import 'package:flutter_application_1/admin/metro_details.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final List<String> menuItems = [
    "Dashboard",
    "Manage Routes",
    "Metro Details",
    "Bus Details", 
    "Analytics",
    "Performance",
    "Settings"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            color: Colors.green.shade700,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text("Smart Pune Commute",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 30),
                for (int i = 0; i < menuItems.length; i++)
                  ListTile(
                    selected: selectedIndex == i,
                    selectedTileColor: Colors.green.shade400,
                    leading: const Icon(Icons.circle, color: Colors.white, size: 10),
                    title: Text(menuItems[i],
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: selectedIndex == i
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    onTap: () => setState(() => selectedIndex = i),
                  ),
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildPage(selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _dashboardPage();
      case 1:
         return const ManageRoutesPage();
      case 2:
         return const MetroDetailsPage();
      case 3:
         return const BusDetailsPage(); 
      case 4:
        return _analyticsPage();
      case 5:
        return _performancePage();
      case 6:
        return _settingsPage();
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  Widget _dashboardPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Admin Dashboard",
            style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // Top info cards
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            _infoCard("Total Buses", "120"),
            _infoCard("Total Trains", "18"),
            _infoCard("Active Routes", "45"),
            _infoCard("Delayed Services", "3"),
          ],
        ),

        const SizedBox(height: 40),
        Text("Ridership & Mode Overview",
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),

        // Line Chart + Pie Chart
        Expanded(
          child: Row(
            children: [
              // Left: Line Chart
              Expanded(
                flex: 2,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: const [
                          FlSpot(0, 2),
                          FlSpot(1, 3),
                          FlSpot(2, 5),
                          FlSpot(3, 4),
                          FlSpot(4, 7),
                          FlSpot(5, 8),
                        ],
                        color: Colors.green,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.greenAccent.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 30),

              // Right: Pie Chart
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text("Mode Usage Share",
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: Colors.green,
                              value: 55,
                              title: 'Bus\n55%',
                              radius: 70,
                              titleStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            PieChartSectionData(
                              color: Colors.orange,
                              value: 30,
                              title: 'Train\n30%',
                              radius: 70,
                              titleStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            PieChartSectionData(
                              color: Colors.blue,
                              value: 15,
                              title: 'Metro\n15%',
                              radius: 70,
                              titleStyle: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  

  Widget _analyticsPage() {
    return _simplePage("Analytics", "View pass sales and ridership analytics.");
  }

  Widget _performancePage() {
    return _simplePage("Performance", "Monitor overall service performance.");
  }

  Widget _settingsPage() {
    return _simplePage("Settings", "Change system configurations here.");
  }

  Widget _simplePage(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(description, style: GoogleFonts.poppins(fontSize: 16)),
      ],
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 16, color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700)),
        ],
      ),
    );
  }
}
