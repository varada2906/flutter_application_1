import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// Ensure this file exists in your project
import 'live_location_screen.dart';

class RouteInfoScreen extends StatefulWidget {
  const RouteInfoScreen({super.key});

  @override
  State<RouteInfoScreen> createState() => _RouteInfoScreenState();
}

class _RouteInfoScreenState extends State<RouteInfoScreen> {
  final String busNo = "123";
  final String routeName = "Pune Station → Hinjewadi";

  // Static route coordinates
  static const LatLng _startLocation = LatLng(18.5204, 73.8567);
  static const LatLng _endLocation = LatLng(18.5800, 73.8900);
  static const LatLng _routeCenter = LatLng(18.5502, 73.8733);

  String walkingTime = "Loading...";

  @override
  void initState() {
    super.initState();
    loadWalkingTime();
  }

  Future<void> loadWalkingTime() async {
    // Note: Ensure Directions API is enabled in Google Cloud Console
    const String apiKey = "AIzaSyBZx90TPyWRn8VymQq7a_YnHqaPOBGZ8o0"; 
    const url = "https://maps.googleapis.com/maps/api/directions/json"
        "?origin=18.5204,73.8567"
        "&destination=18.5800,73.8900"
        "&mode=walking"
        "&key=$apiKey";

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["routes"].isNotEmpty) {
          setState(() {
            walkingTime = data["routes"][0]["legs"][0]["duration"]["text"];
          });
        } else {
          setState(() => walkingTime = "No route found");
        }
      } else {
        setState(() => walkingTime = "Error ${res.statusCode}");
      }
    } catch (e) {
      setState(() => walkingTime = "Failed to load");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = {
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
    };

    final Polyline routePolyline = Polyline(
      polylineId: const PolylineId('fullRoute'),
      points: [_startLocation, _endLocation],
      color: Colors.blue,
      width: 4,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Route Info"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- MAIN OVERVIEW CARD ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Route Overview",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 24),
                    _infoRow("Bus No.", busNo),
                    _infoRow("Route", routeName),
                    // Added Walking Time here for better visibility
                    _infoRow("Est. Walking Time", walkingTime, isHighlight: true),
                    
                    const SizedBox(height: 16),
                    
                    // Map Preview
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 200,
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: _routeCenter,
                            zoom: 12,
                          ),
                          markers: markers,
                          polylines: {routePolyline},
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- ACTION BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LiveLocationScreen()),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text("START TRIP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- ADDITIONAL INFO CARDS ---
            _infoCard("Assigned Route", routeName, Icons.route),
            const SizedBox(height: 12),
            _infoCard("Walking Duration", walkingTime, Icons.directions_walk, 
                isLoading: walkingTime == "Loading..."),
            
            // Bottom padding to ensure scrollability
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper for Rows inside the Card
  Widget _infoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isHighlight ? Colors.blue[800] : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Individual Info Cards
  Widget _infoCard(String title, String value, IconData icon, {bool isLoading = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Icon(icon, color: Colors.blue[800]),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              isLoading 
                ? const SizedBox(height: 4, width: 15, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}