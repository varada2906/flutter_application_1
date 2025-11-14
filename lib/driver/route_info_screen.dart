import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'live_location_screen.dart';

class RouteInfoScreen extends StatelessWidget {
  const RouteInfoScreen({super.key});

  final String busNo = "123";
  final String routeName = "Pune Station → Hinjewadi";

  // Static route coordinates for preview
  static const LatLng _startLocation = LatLng(18.5204, 73.8567);
  static const LatLng _endLocation = LatLng(18.5800, 73.8900);
  
  // Calculate center for map camera
  static const LatLng _routeCenter = LatLng(18.5502, 73.8733); 

  @override
  Widget build(BuildContext context) {
    
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('start'),
        position: _startLocation,
        infoWindow: const InfoWindow(title: 'Start: Pune Station'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('end'),
        position: _endLocation,
        infoWindow: const InfoWindow(title: 'End: Hinjewadi'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    final Polyline routePolyline = Polyline(
      polylineId: const PolylineId('fullRoute'),
      points: [_startLocation, _endLocation],
      color: Colors.blue.shade700,
      width: 4,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Route Info"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Route Info Card with Map ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Route Overview",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    _infoRow("Bus No.", busNo),
                    _infoRow("Route", routeName),
                    const SizedBox(height: 15),
                    
                    // Route Map Preview
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GoogleMap(
                          onMapCreated: (controller) {},
                          initialCameraPosition: const CameraPosition(
                            target: _routeCenter,
                            zoom: 11, // Zoomed out to see the whole route
                          ),
                          markers: markers,
                          polylines: {routePolyline},
                          zoomControlsEnabled: false,
                          scrollGesturesEnabled: false, // Prevent driver from accidentally moving the map
                          zoomGesturesEnabled: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Start Trip Button (Main Action) ---
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const LiveLocationScreen(),
                ));
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("START TRIP"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15)),
            ),
            const SizedBox(height: 20),

            // --- Additional Info ---
            _infoCard("Bus Number", busNo, Icons.directions_bus, context),
            const SizedBox(height: 20),
            _infoCard("Assigned Route", routeName, Icons.route, context),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
  
  // Extracted Info Card Widget
  Widget _infoCard(String title, String value, IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(2, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800)),
            ],
          ),
        ],
      ),
    );
  }
}