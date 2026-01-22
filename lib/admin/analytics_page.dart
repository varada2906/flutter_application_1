import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedTimeRange = 0; // 0: Daily, 1: Weekly, 2: Monthly
  int _selectedMetric = 0; // 0: Ridership, 1: Revenue, 2: Pass Sales

  final List<String> timeRanges = ["Daily", "Weekly", "Monthly"];
  final List<String> metrics = ["Ridership", "Revenue", "Pass Sales"];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Analytics Dashboard",
                style: GoogleFonts.poppins(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            Row(
              children: [
                // Time range selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedTimeRange,
                      items: timeRanges.asMap().entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedTimeRange = value!);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Metric selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedMetric,
                      items: metrics.asMap().entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedMetric = value!);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats Cards
        SizedBox(
          height: 150, // Fixed height for stats cards
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const SizedBox(width: 5),
              _buildStatCard("Total Ridership", "45,820", "+12%", Colors.green),
              const SizedBox(width: 15),
              _buildStatCard("Total Revenue", "₹12.5L", "+8%", Colors.blue),
              const SizedBox(width: 15),
              _buildStatCard("Pass Sales", "8,450", "+15%", Colors.orange),
              const SizedBox(width: 15),
              _buildStatCard("Avg. Daily Users", "3,250", "+5%", Colors.purple),
              const SizedBox(width: 5),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Charts Section - Use Expanded with a minimum height
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line Chart - FIXED
              Expanded(
                flex: 3,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${metrics[_selectedMetric]} Trend",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Expanded( // ADDED Expanded here
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                      if (value.toInt() < days.length) {
                                        return Text(days[value.toInt()]);
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  spots: _getChartData(),
                                  color: _getChartColor(),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: _getChartColor().withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Right side: Bar chart and top routes - FIXED
              Expanded(
                flex: 2,
                child: SingleChildScrollView( // ADDED SingleChildScrollView
                  child: Column(
                    children: [
                      // Bar Chart - Fixed height
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mode Comparison",
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 180, // Reduced from 200
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    barGroups: [
                                      BarChartGroupData(
                                        x: 0,
                                        barRods: [
                                          BarChartRodData(
                                            toY: 65,
                                            color: Colors.green,
                                            width: 20,
                                          ),
                                        ],
                                      ),
                                      BarChartGroupData(
                                        x: 1,
                                        barRods: [
                                          BarChartRodData(
                                            toY: 30,
                                            color: Colors.orange,
                                            width: 20,
                                          ),
                                        ],
                                      ),
                                      BarChartGroupData(
                                        x: 2,
                                        barRods: [
                                          BarChartRodData(
                                            toY: 15,
                                            color: Colors.blue,
                                            width: 20,
                                          ),
                                        ],
                                      ),
                                    ],
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final modes = ['Bus', 'Train', 'Metro'];
                                            if (value.toInt() < modes.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(modes[value.toInt()]),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15), // Reduced from 20

                      // Top Routes - Fixed height
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Top 5 Busy Routes",
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 180, // Fixed height
                                child: ListView(
                                  physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                                  children: _getTopRoutes().map((route) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(route['name']!,
                                              style: GoogleFonts.poppins()),
                                        ),
                                        Text("${route['count']} users",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  )).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String change, Color color) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 16, color: Colors.grey.shade600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(change,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ),
            ],
          ),
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

  List<FlSpot> _getChartData() {
    switch (_selectedMetric) {
      case 0: // Ridership
        return const [
          FlSpot(0, 3.2),
          FlSpot(1, 4.1),
          FlSpot(2, 3.8),
          FlSpot(3, 5.2),
          FlSpot(4, 6.8),
          FlSpot(5, 8.1),
          FlSpot(6, 7.5),
        ];
      case 1: // Revenue
        return const [
          FlSpot(0, 2.5),
          FlSpot(1, 3.0),
          FlSpot(2, 2.8),
          FlSpot(3, 4.2),
          FlSpot(4, 5.5),
          FlSpot(5, 6.8),
          FlSpot(6, 6.2),
        ];
      case 2: // Pass Sales
        return const [
          FlSpot(0, 1.8),
          FlSpot(1, 2.2),
          FlSpot(2, 2.0),
          FlSpot(3, 3.5),
          FlSpot(4, 4.8),
          FlSpot(5, 5.2),
          FlSpot(6, 4.5),
        ];
      default:
        return const [];
    }
  }

  Color _getChartColor() {
    switch (_selectedMetric) {
      case 0: // Ridership
        return Colors.green;
      case 1: // Revenue
        return Colors.blue;
      case 2: // Pass Sales
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  List<Map<String, dynamic>> _getTopRoutes() {
    return [
      {'name': 'Pune → Mumbai', 'count': '8,240'},
      {'name': 'Pune → Nashik', 'count': '6,150'},
      {'name': 'Pune → Goa', 'count': '4,820'},
      {'name': 'Pune → Bangalore', 'count': '3,950'},
      {'name': 'Pune → Hyderabad', 'count': '2,870'},
    ];
  }
}