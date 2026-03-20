import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/driver/live_location_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


class RouteInfoScreen extends StatefulWidget {
  const RouteInfoScreen({super.key});

  @override
  State<RouteInfoScreen> createState() => _RouteInfoScreenState();
}

class _RouteInfoScreenState extends State<RouteInfoScreen> {
  final String busNo = "123";
  final String routeName = "Pune Station → Hinjewadi";
  
  static const LatLng _startLocation = LatLng(18.5204, 73.8567);
  static const LatLng _endLocation = LatLng(18.5800, 73.8900);
  static const LatLng _routeCenter = LatLng(18.5502, 73.8733);

  String walkingTime = "12 mins";

  @override
  void initState() {
    super.initState();
    loadWalkingTime();
  }

  Future<void> loadWalkingTime() async {
    // API logic goes here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Stack(
        children: [
          // 1. BACKGROUND MAP
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _routeCenter, 
                zoom: 12
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('start'), 
                  position: _startLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
                Marker(
                  markerId: const MarkerId('end'), 
                  position: _endLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: [_startLocation, _endLocation],
                  color: Colors.blueAccent,
                  width: 5,
                )
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),

          // 2. CUSTOM BACK BUTTON (Fixed Elevation Error)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),

          // 3. BOTTOM INFO SHEET
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12, 
                    blurRadius: 20, 
                    offset: Offset(0, -5)
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // HEADER ROW (Fixed Overflow)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded( 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Route Information",
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Express Line • Bus $busNo",
                                style: GoogleFonts.poppins(
                                  color: Colors.blueAccent, 
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildBadge(walkingTime),
                      ],
                    ),

                    const SizedBox(height: 30),
                    _buildRouteTimeline(),
                    const SizedBox(height: 30),

                    // INFO GRID
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallStat(
                            Icons.timer_outlined, 
                            "Est. Duration", 
                            "45 min"
                          )
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSmallStat(
                            Icons.map_outlined, 
                            "Distance", 
                            "12.4 km"
                          )
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // START TRIP BUTTON
                    // START TRIP BUTTON
SizedBox(
  width: double.infinity,
  height: 60,
  child: ElevatedButton(
    onPressed: () {
      // This is the navigation trigger you requested
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LiveLocationScreen()),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00C853),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.navigation_rounded),
        const SizedBox(width: 10),
        Text(
          "START TRIP",
          style: GoogleFonts.poppins(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  ),
),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UI Helpers
  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_walk, size: 16, color: Colors.orange),
          const SizedBox(width: 6),
          Text(
            text, 
            style: GoogleFonts.poppins(
              color: Colors.orange.shade800, 
              fontWeight: FontWeight.bold,
              fontSize: 13,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTimeline() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildStopItem("Pune Station", "Starting Point", Colors.green, true),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 2, 
                height: 30, 
                color: Colors.blueAccent.withOpacity(0.3)
              ),
            ),
          ),
          _buildStopItem("Hinjewadi IT Park", "Destination", Colors.red, false),
        ],
      ),
    );
  }

  Widget _buildStopItem(String title, String subtitle, Color color, bool isStart) {
    return Row(
      children: [
        Icon(
          isStart ? Icons.radio_button_checked : Icons.location_on, 
          color: color, 
          size: 24
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15,
                  color: const Color(0xFF1E293B)
                )
              ),
              Text(
                subtitle, 
                style: GoogleFonts.poppins(
                  color: Colors.blueGrey, 
                  fontSize: 12
                )
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSmallStat(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(height: 8),
          Text(
            label, 
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)
          ),
          Text(
            value, 
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, 
              fontSize: 15,
              color: const Color(0xFF1E293B)
            )
          ),
        ],
      ),
    );
  }
}