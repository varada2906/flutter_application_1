import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  int _selectedPeriod = 0;
  int _selectedServiceType = 0;

  final List<String> periods = ["This Week", "This Month", "This Year"];
  final List<String> serviceTypes = [
    "All Services",
    "Bus Only",
    "Train Only",
    "Metro Only"
  ];

  // ================= MERGED DATA FROM CODE 2 =================
  final Map<String, Map<String, String>> serviceDetails = {
    "Bus Services": {
      "On-Time Performance": "92.5%",
      "Reliability": "96.3%",
      "Average Delay": "8.2 min",
      "Capacity Usage": "84%",
    },
    "Train Services": {
      "On-Time Performance": "95.8%",
      "Reliability": "98.1%",
      "Average Delay": "5.4 min",
      "Capacity Usage": "91%",
    },
    "Metro Services": {
      "On-Time Performance": "97.2%",
      "Reliability": "99.0%",
      "Average Delay": "3.1 min",
      "Capacity Usage": "78%",
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Performance Dashboard",
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    _buildDropdown(periods, _selectedPeriod,
                        (v) => setState(() => _selectedPeriod = v)),
                    const SizedBox(width: 10),
                    _buildDropdown(serviceTypes, _selectedServiceType,
                        (v) => setState(() => _selectedServiceType = v)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ================= KPI CARDS =================
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildKpiCard("On-Time Performance", "94.2%", "+2.1%",
                      Colors.green, Icons.timer),
                  const SizedBox(width: 15),
                  _buildKpiCard("Service Reliability", "97.8%", "+1.3%",
                      Colors.blue, Icons.check_circle),
                  const SizedBox(width: 15),
                  _buildKpiCard("Customer Satisfaction", "4.6/5", "+0.3",
                      Colors.orange, Icons.star),
                  const SizedBox(width: 15),
                  _buildKpiCard(
                      "Delay Rate", "3.8%", "-0.7%", Colors.red, Icons.warning),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= MAIN CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // -------- LINE CHART --------
                        Expanded(
                          flex: 3,
                          child: _buildPunctualityChart(),
                        ),
                        const SizedBox(width: 20),
                        // -------- RIGHT SIDE --------
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildServiceStatus(),
                              const SizedBox(height: 20),
                              _buildPeakHours(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // -------- DYNAMIC SERVICE CARDS --------
                    _buildServicePerformance(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DETAIL MODAL LOGIC =================
  void _showServiceDetails(String serviceName, Color color) {
    final details = serviceDetails[serviceName];
    if (details == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceName,
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              const Divider(),
              const SizedBox(height: 10),
              ...details.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key,
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.grey.shade700)),
                        Text(entry.value,
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ================= HELPER WIDGETS =================

  Widget _buildKpiCard(
      String title, String value, String change, Color color, IconData icon) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(change,
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
          const Spacer(),
          Text(title,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      List<String> items, int value, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          items: items.asMap().entries.map((e) {
            return DropdownMenuItem(value: e.key, child: Text(e.value));
          }).toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }

  Widget _buildPunctualityChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Punctuality Trend (%)",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          return v.toInt() < m.length ? Text(m[v.toInt()]) : const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.blue.withOpacity(0.1)),
                      spots: const [
                        FlSpot(0, 91), FlSpot(1, 93), FlSpot(2, 92),
                        FlSpot(3, 94.2), FlSpot(4, 95), FlSpot(5, 94),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatus() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Live Status", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._getServiceStatusList().map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(s['icon'], color: s['color']),
                  title: Text(s['name'], style: const TextStyle(fontSize: 13)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: s['statusColor'].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(s['status'],
                        style: TextStyle(color: s['statusColor'], fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPeakHours() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Peak Load", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    _bar(0, 8), _bar(1, 15), _bar(2, 10), _bar(3, 18),
                  ],
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) => BarChartGroupData(
        x: x,
        barRods: [BarChartRodData(toY: y, color: Colors.blueAccent, width: 12)],
      );

  Widget _buildServicePerformance() {
    return Row(
      children: [
        _serviceCard("Bus Services", Colors.green, Icons.directions_bus),
        const SizedBox(width: 15),
        _serviceCard("Train Services", Colors.orange, Icons.train),
        const SizedBox(width: 15),
        _serviceCard("Metro Services", Colors.blue, Icons.directions_subway),
      ],
    );
  }

  Widget _serviceCard(String title, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _showServiceDetails(title, color),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("View Details", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getServiceStatusList() => [
        {'icon': Icons.directions_bus, 'name': 'Bus', 'status': 'Normal', 'color': Colors.green, 'statusColor': Colors.green},
        {'icon': Icons.train, 'name': 'Train', 'status': 'Good', 'color': Colors.orange, 'statusColor': Colors.green},
        {'icon': Icons.directions_subway, 'name': 'Metro', 'status': 'Excellent', 'color': Colors.blue, 'statusColor': Colors.green},
      ];
}