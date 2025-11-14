import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_application_1/models/route_suggstion_args.dart';

class RouteSuggestionsScreen extends StatefulWidget {
  const RouteSuggestionsScreen({super.key});

  @override
  State<RouteSuggestionsScreen> createState() => _RouteSuggestionsScreenState();
}

class _RouteSuggestionsScreenState extends State<RouteSuggestionsScreen> {
  late String fromLocation;
  late String toLocation;
  bool accessibilityMode = false;

  GoogleMapController? _mapController;

  // --- START OF NEW/UPDATED LOGIC ---

  // Simulated geocoding data using real-world coordinates
  static const Map<String, LatLng> _locationCoords = {
    "Pune": LatLng(18.5204, 73.8567),
    "Mumbai": LatLng(19.0760, 72.8777),
    "Shirdi": LatLng(19.7645, 74.4735),
    "Kolhapur": LatLng(16.7050, 74.2433),
    "Hyderabad": LatLng(17.3850, 78.4867),
    "Nagpur": LatLng(21.1458, 79.0882),
    "Delhi": LatLng(28.7041, 77.1025),
    "Chennai": LatLng(13.0827, 80.2707),
    // Use fallback for locations not explicitly mapped
    "Default": LatLng(18.5204, 73.8567),
  };

  // Dynamic coordinates based on route args
  LatLng _fromLatLng = _locationCoords["Pune"]!;
  LatLng _toLatLng = _locationCoords["Mumbai"]!;

  // Dynamic route/ticket data
  Map<String, String> liveRoute = {};

  // Helper to find coordinates, falling back to a default if not found
  LatLng _getLatLng(String locationName) {
    // Simple check to find major city names regardless of case/extra spaces
    final key = _locationCoords.keys.firstWhere(
      (k) => locationName.toLowerCase().contains(k.toLowerCase()),
      orElse: () => "Default",
    );
    return _locationCoords[key] ?? _locationCoords["Default"]!;
  }

  // Helper to simulate dynamic route/ticket data
  Map<String, String> _getSimulatedRoute(String from, String to) {
    if (from.contains("Pune") && to.contains("Shirdi")) {
      return {
        'icon': 'directions_bus',
        'mode': 'Bus Ticket',
        'suggestion': 'Shivshahi Bus Service (AC)',
        'busNo': 'PN-47',
        'time': '5h 30m',
        'price': '₹550',
      };
    } else if (from.contains("Pune") && to.contains("Nagpur")) {
      return {
        'icon': 'train',
        'mode': 'Train Ticket',
        'suggestion': 'Maharastra Express (Sleeper)',
        'busNo': '12137',
        'time': '12h 45m',
        'price': '₹650',
      };
    }
    // Default route suggestion
    return {
      'icon': 'directions_bus',
      'mode': 'Bus Suggestion',
      'suggestion': 'Overnight Sleeper Service',
      'busNo': 'Default-X',
      'time': '3h 30m',
      'price': '₹400',
    };
  }

  // --- END OF NEW/UPDATED LOGIC ---

  @override
  void initState() {
    super.initState();
    _checkPermission(); // ✅ check permission before map load
  }

  // ✅ Permission checking logic
  Future<void> _checkPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as RouteSuggestionArgs?;

    if (args != null) {
      fromLocation = args.from;
      toLocation = args.to;
      // Calculate dynamic coordinates and route details
      _fromLatLng = _getLatLng(fromLocation);
      _toLatLng = _getLatLng(toLocation);
      liveRoute = _getSimulatedRoute(fromLocation, toLocation);
    } else {
      // Use Pune to Mumbai as a fallback route for demonstration
      fromLocation = 'Pune';
      toLocation = 'Mumbai';
      _fromLatLng = _getLatLng(fromLocation);
      _toLatLng = _getLatLng(toLocation);
      liveRoute = _getSimulatedRoute(fromLocation, toLocation);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    // --- START OF DYNAMIC BUILD LOGIC ---
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('from'),
        position: _fromLatLng,
        infoWindow: InfoWindow(title: 'From: $fromLocation'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('to'),
        position: _toLatLng,
        infoWindow: InfoWindow(title: 'To: $toLocation'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    final Polyline routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [_fromLatLng, _toLatLng],
      color: Colors.blue,
      width: 4,
    );

    // Calculate map center for current route
    final LatLng mapCenter = LatLng(
      (_fromLatLng.latitude + _toLatLng.latitude) / 2,
      (_fromLatLng.longitude + _toLatLng.longitude) / 2,
    );
    // --- END OF DYNAMIC BUILD LOGIC ---

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Suggestions'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.accessibility),
            onPressed: () {
              setState(() {
                accessibilityMode = !accessibilityMode;
              });
            },
            color: accessibilityMode ? Colors.blue : Colors.grey,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From $fromLocation', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text('To $toLocation', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text('Expected duration: ${liveRoute['time'] ?? 'N/A'}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),

            // ✅ Google Map section
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: mapCenter, // Use dynamic center
                    zoom: 8, // Zoom level adjusted for city-to-city routes
                  ),
                  markers: markers,
                  polylines: {routePolyline},
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                  compassEnabled: true,
                ),
              ),
            ),

            const Divider(),
            // --- UPDATED TICKET/ROUTE SUGGESTION SECTION ---
            ListTile(
              leading: Icon(
                liveRoute['icon'] == 'directions_bus' ? Icons.directions_bus : Icons.train,
                color: liveRoute['icon'] == 'directions_bus' ? Colors.green : Colors.blue,
              ),
              title: Text('${liveRoute['mode']}: ${liveRoute['suggestion']}'),
              subtitle: Text(
                'ID/Number: ${liveRoute['busNo'] ?? 'N/A'} | Price: ${liveRoute['price'] ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text('Duration: ${liveRoute['time'] ?? 'N/A'}'),
            ),
            // --- END UPDATED SECTION ---
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // This would typically navigate to a bidding/booking page
                Navigator.pushNamed(context, '/profile');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Req Bid / Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}