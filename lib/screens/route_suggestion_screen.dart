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

  static const Map<String, LatLng> _locationCoords = {
    "Pune": LatLng(18.5204, 73.8567),
    "Mumbai": LatLng(19.0760, 72.8777),
    "Shirdi": LatLng(19.7645, 74.4735),
    "Kolhapur": LatLng(16.7050, 74.2433),
    "Hyderabad": LatLng(17.3850, 78.4867),
    "Nagpur": LatLng(21.1458, 79.0882),
    "Delhi": LatLng(28.7041, 77.1025),
    "Chennai": LatLng(13.0827, 80.2707),
    "Default": LatLng(18.5204, 73.8567),
  };

  LatLng _fromLatLng = _locationCoords["Pune"]!;
  LatLng _toLatLng = _locationCoords["Mumbai"]!;
  Map<String, String> liveRoute = {};

  LatLng _getLatLng(String locationName) {
    final key = _locationCoords.keys.firstWhere(
      (k) => locationName.toLowerCase().contains(k.toLowerCase()),
      orElse: () => "Default",
    );
    return _locationCoords[key] ?? _locationCoords["Default"]!;
  }

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
    return {
      'icon': 'directions_bus',
      'mode': 'Bus Suggestion',
      'suggestion': 'Overnight Sleeper Service',
      'busNo': 'Default-X',
      'time': '3h 30m',
      'price': '₹400',
    };
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as RouteSuggestionArgs?;

    if (args != null) {
      fromLocation = args.from;
      toLocation = args.to;
    } else {
      fromLocation = 'Pune';
      toLocation = 'Mumbai';
    }
    _fromLatLng = _getLatLng(fromLocation);
    _toLatLng = _getLatLng(toLocation);
    liveRoute = _getSimulatedRoute(fromLocation, toLocation);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Auto-fit the map to show both markers
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        _fromLatLng.latitude < _toLatLng.latitude ? _fromLatLng.latitude : _toLatLng.latitude,
        _fromLatLng.longitude < _toLatLng.longitude ? _fromLatLng.longitude : _toLatLng.longitude,
      ),
      northeast: LatLng(
        _fromLatLng.latitude > _toLatLng.latitude ? _fromLatLng.latitude : _toLatLng.latitude,
        _fromLatLng.longitude > _toLatLng.longitude ? _fromLatLng.longitude : _toLatLng.longitude,
      ),
    );
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
  }

  @override
  Widget build(BuildContext context) {
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
      color: Colors.blue.withOpacity(0.7),
      width: 5,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Suggestions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.accessibility),
            onPressed: () => setState(() => accessibilityMode = !accessibilityMode),
            color: accessibilityMode ? Colors.blue : Colors.grey,
          ),
        ],
      ),
      // ✅ Wrap with SingleChildScrollView to prevent bottom overflow
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: $fromLocation', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('To: $toLocation', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Estimated Travel: ${liveRoute['time']}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),

              // ✅ Fixed Height for the Map
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4, // 40% of screen height
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(target: _fromLatLng, zoom: 10),
                    markers: markers,
                    polylines: {routePolyline},
                    myLocationEnabled: true,
                    zoomControlsEnabled: false, // Cleaner UI
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text("Best Suggestion", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(
                    liveRoute['icon'] == 'directions_bus' ? Icons.directions_bus : Icons.train,
                    color: Colors.blue.shade700,
                  ),
                ),
                title: Text('${liveRoute['mode']}: ${liveRoute['suggestion']}'),
                subtitle: Text('ID: ${liveRoute['busNo']} • Price: ${liveRoute['price']}'),
                trailing: const Icon(Icons.chevron_right),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Req Bid / Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              // Extra space at bottom to ensure scrolling feels comfortable
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}