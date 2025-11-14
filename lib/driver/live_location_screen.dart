import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps
import 'package:permission_handler/permission_handler.dart'; // Import Permissions
import 'end_trip_screen.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  int passengers = 12;
  String nextStop = "Main St.";
  GoogleMapController? _mapController;
  
  // Example Route Data (use real coordinates in a production app)
  static const LatLng _startLocation = LatLng(18.5204, 73.8567); // Pune Center (Start)
  static const LatLng _currentLocation = LatLng(18.5400, 73.8700); // Current Position
  static const LatLng _endLocation = LatLng(18.5800, 73.8900);   // Hinjewadi (End)

  @override
  void initState() {
    super.initState();
    _checkPermission(); // Check location permissions on load
  }

  Future<void> _checkPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final Set<Marker> markers = {
      // Current Location Marker (Driver's Bus)
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentLocation,
        infoWindow: const InfoWindow(title: 'Your Bus'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      // End Location Marker
      Marker(
        markerId: const MarkerId('endLocation'),
        position: _endLocation,
        infoWindow: const InfoWindow(title: 'Destination'),
      ),
    };

    final Polyline routePolyline = Polyline(
      polylineId: const PolylineId('driverRoute'),
      points: [_startLocation, _currentLocation, _endLocation],
      color: Colors.green.shade700,
      width: 5,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Trip Dashboard"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Live Location & Route",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // --- Google Map Widget ---
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation,
                    zoom: 14, // Zoomed in for current tracking
                  ),
                  markers: markers,
                  polylines: {routePolyline},
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Next Stop Info ---
            _infoCard("Next Stop", nextStop, Icons.pin_drop, context),
            const SizedBox(height: 20),

            // --- Passenger Count Info ---
            _infoCard("Passenger Count", "$passengers", Icons.people, context),
            const SizedBox(height: 20),

            // --- Action Buttons ---
            ElevatedButton.icon(
              onPressed: () => setState(() => passengers++),
              icon: const Icon(Icons.add),
              label: Text("Add Passenger ($passengers)"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12)),
            ),
            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const EndTripScreen(),
                ));
              },
              child: const Text("END TRIP"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
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
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800)),
            ],
          ),
        ],
      ),
    );
  }
}