import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/admin/PerformancePage.dart';
import 'package:flutter_application_1/admin/analytics_page.dart';
import 'package:flutter_application_1/admin/bus_transport.dart';
import 'package:flutter_application_1/admin/manage_routes.dart';
import 'package:flutter_application_1/admin/metro_details.dart';
import 'package:flutter_application_1/admin/settingsPage.dart';
import 'package:flutter_application_1/admin/ticket_manager.dart'; // Ensure this exists
import 'package:google_fonts/google_fonts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  // The order here must match the indices in _buildPage
  final List<String> menuItems = [
    "Dashboard",
    "Manage Routes",
    "Metro Details",
    "Bus Details",
    "Tickets",
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
          // ================= SIDEBAR =================
          Container(
            width: 250,
            color: Colors.green.shade700,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  "Smart Pune Commute",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Merged dynamic Sidebar Loop
                for (int i = 0; i < menuItems.length; i++)
                  ListTile(
                    selected: selectedIndex == i,
                    selectedTileColor: Colors.green.shade400,
                    leading: Icon(
                      _getIconForMenu(menuItems[i]),
                      color: Colors.white,
                      size: 20,
                    ),
                    title: Text(
                      menuItems[i],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: selectedIndex == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () => setState(() => selectedIndex = i),
                  ),
                  
                const Spacer(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text("Logout", style: TextStyle(color: Colors.white)),
                  onTap: () {
                    // Add logout logic here
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ================= MAIN CONTENT =================
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

  // Merged Icon Helper
  IconData _getIconForMenu(String title) {
    switch (title) {
      case "Dashboard": return Icons.dashboard;
      case "Manage Routes": return Icons.map;
      case "Metro Details": return Icons.train;
      case "Bus Details": return Icons.directions_bus;
      case "Analytics": return Icons.analytics;
      case "Performance": return Icons.speed;
      case "Settings": return Icons.settings;
      case "Tickets": return Icons.confirmation_number;
      default: return Icons.circle;
    }
  }

  // Merged Page Router
  Widget _buildPage(int index) {
    switch (index) {
      case 0: return _dashboardPage();
      case 1: return const ManageRoutesPage();
      case 2: return const MetroSearchScreen();
      case 3: return const BusDetailsPage();
      case 4: return const AdminTicketPage(); // Connected to Tickets
      case 5: return const AnalyticsPage();
      case 6: return const PerformancePage();
      case 7: return const AdminSettingsPage();
      default: return const Center(child: Text("Page not found"));
    }
  }

  // ================= DASHBOARD FRAGMENT =================
  Widget _dashboardPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Admin Dashboard",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

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
        Text(
          "Ridership & Mode Overview",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: Row(
            children: [
              // Line Chart
              Expanded(
                flex: 2,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: const [
                          FlSpot(0, 2), FlSpot(1, 3), FlSpot(2, 5),
                          FlSpot(3, 4), FlSpot(4, 7), FlSpot(5, 8),
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
              // Pie Chart
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      "Mode Usage Share",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 40,
                          sections: [
                            _buildPieSection(55, "Bus\n55%", Colors.green),
                            _buildPieSection(30, "Train\n30%", Colors.orange),
                            _buildPieSection(15, "Metro\n15%", Colors.blue),
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

  PieChartSectionData _buildPieSection(double value, String title, Color color) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: 70,
      titleStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
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
          Text(title, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}