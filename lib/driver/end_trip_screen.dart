import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/screens/auth/login_page.dart';

class EndTripScreen extends StatelessWidget {
  const EndTripScreen({super.key});

  final String startTime = "10:15 AM";
  final String endTime = "11:05 AM";
  final String totalTime = "50 min";
  final String distance = "15 km";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Styled AppBar matching the Dashboard
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF1E293B),
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Trip Completed", 
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10B981)],
                  ),
                ),
                child: Center(
                  child: Icon(Icons.check_circle_outline, 
                    size: 80, color: Colors.white.withOpacity(0.2)
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 32),
                  
                  // Primary Action Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) =>  LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      "RETURN TO LOGIN",
                      style: GoogleFonts.inter(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        letterSpacing: 1.1
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Journey Statistics", 
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))
          ),
          const Divider(height: 32, thickness: 1),
          _summaryRow(Icons.access_time_rounded, "Start Time", startTime),
          _summaryRow(Icons.timer_off_rounded, "End Time", endTime),
          _summaryRow(Icons.hourglass_bottom_rounded, "Total Duration", totalTime),
          _summaryRow(Icons.route_rounded, "Total Distance", distance),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 16),
          Text(label, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF64748B))),
          const Spacer(),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }
}