import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_application_1/models/route_suggstion_args.dart';

// Enum for route types
enum RouteType { cheapest, fastest, mixed }

// Data model for route options
class RouteOption {
  final RouteType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String travelTime;
  final String price;
  final String details;
  final int stops;
  final String mode;
  final double rating;

  RouteOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.travelTime,
    required this.price,
    required this.details,
    required this.stops,
    required this.mode,
    this.rating = 4.5,
  });
}

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
    "Swargate": LatLng(18.5022, 73.8623),
    "Hinjawadi Phase 2": LatLng(18.5920, 73.7273),
    "Nashik": LatLng(19.9975, 73.7898),
    "Goa": LatLng(15.2993, 74.1240),
    "Bangalore": LatLng(12.9716, 77.5946),
    "Agra": LatLng(27.1767, 78.0081),
    "Kolkata": LatLng(22.5726, 88.3639),
  };

  LatLng _fromLatLng = _locationCoords["Pune"]!;
  LatLng _toLatLng = _locationCoords["Mumbai"]!;
  
  // Selected route type
  RouteType _selectedRoute = RouteType.cheapest;
  
  // Route options data
  final List<RouteOption> _routeOptions = [];

  LatLng _getLatLng(String locationName) {
    final key = _locationCoords.keys.firstWhere(
      (k) => locationName.toLowerCase().contains(k.toLowerCase()),
      orElse: () => "Default",
    );
    return _locationCoords[key] ?? _locationCoords["Default"]!;
  }

  // Generate route options based on locations
  void _generateRouteOptions(String from, String to) {
    _routeOptions.clear();
    
    // Convert to lowercase for easier matching
    final fromLower = from.toLowerCase();
    final toLower = to.toLowerCase();
    
    if (fromLower.contains("swargate") && toLower.contains("hinjawadi")) {
      // Example routes for Swargate to Hinjawadi (from your image)
      _routeOptions.addAll([
        RouteOption(
          type: RouteType.cheapest,
          title: "BUS",
          subtitle: "Cheapest route",
          icon: Icons.directions_bus,
          iconColor: Colors.green.shade700,
          travelTime: "1h 20m",
          price: "₹45",
          details: "Direct PMPML bus via Katraj tunnel",
          stops: 15,
          mode: "Direct Bus",
          rating: 4.2,
        ),
        RouteOption(
          type: RouteType.fastest,
          title: "METRO + BUS",
          subtitle: "Fastest route",
          icon: Icons.directions_transit,
          iconColor: Colors.blue.shade700,
          travelTime: "55m",
          price: "₹60",
          details: "Metro to Shivaji Nagar + Bus 120A",
          stops: 8,
          mode: "Mixed Transport",
          rating: 4.5,
        ),
        RouteOption(
          type: RouteType.mixed,
          title: "WALKING + BUS + METRO",
          subtitle: "Eco-friendly route",
          icon: Icons.directions_walk,
          iconColor: Colors.orange.shade700,
          travelTime: "1h 10m",
          price: "₹50",
          details: "Walk to station, Metro, Bus last mile",
          stops: 10,
          mode: "Multi-modal",
          rating: 4.3,
        ),
      ]);
    } else if (fromLower.contains("pune") && toLower.contains("mumbai")) {
      _routeOptions.addAll([
        RouteOption(
          type: RouteType.cheapest,
          title: "BUS",
          subtitle: "Cheapest route",
          icon: Icons.directions_bus,
          iconColor: Colors.green.shade700,
          travelTime: "3h 30m",
          price: "₹400",
          details: "State transport bus via expressway",
          stops: 2,
          mode: "Direct Bus",
          rating: 4.4,
        ),
        RouteOption(
          type: RouteType.fastest,
          title: "TRAIN",
          subtitle: "Fastest route",
          icon: Icons.train,
          iconColor: Colors.blue.shade700,
          travelTime: "2h 45m",
          price: "₹650",
          details: "Deccan Queen Express, AC Chair Car",
          stops: 5,
          mode: "Train",
          rating: 4.7,
        ),
        RouteOption(
          type: RouteType.mixed,
          title: "BUS + METRO",
          subtitle: "Balanced option",
          icon: Icons.transfer_within_a_station,
          iconColor: Colors.purple.shade700,
          travelTime: "3h 10m",
          price: "₹520",
          details: "Bus to station + Metro to destination",
          stops: 7,
          mode: "Mixed Transport",
          rating: 4.3,
        ),
      ]);
    } else if (fromLower.contains("pune") && toLower.contains("nashik")) {
      _routeOptions.addAll([
        RouteOption(
          type: RouteType.cheapest,
          title: "BUS",
          subtitle: "Cheapest route",
          icon: Icons.directions_bus,
          iconColor: Colors.green.shade700,
          travelTime: "4h 15m",
          price: "₹350",
          details: "MSRTC bus via NH60",
          stops: 8,
          mode: "Direct Bus",
          rating: 4.2,
        ),
        RouteOption(
          type: RouteType.fastest,
          title: "CAR POOL",
          subtitle: "Fastest route",
          icon: Icons.directions_car,
          iconColor: Colors.blue.shade700,
          travelTime: "3h 30m",
          price: "₹600",
          details: "Shared cab via Mumbai-Pune Expressway",
          stops: 2,
          mode: "Car Pool",
          rating: 4.6,
        ),
        RouteOption(
          type: RouteType.mixed,
          title: "TRAIN + BUS",
          subtitle: "Comfortable route",
          icon: Icons.train,
          iconColor: Colors.orange.shade700,
          travelTime: "4h",
          price: "₹480",
          details: "Train to Igatpuri + Local bus",
          stops: 6,
          mode: "Mixed Transport",
          rating: 4.4,
        ),
      ]);
    } else if (fromLower.contains("pune") && toLower.contains("bangalore")) {
      _routeOptions.addAll([
        RouteOption(
          type: RouteType.cheapest,
          title: "BUS",
          subtitle: "Cheapest route",
          icon: Icons.directions_bus,
          iconColor: Colors.green.shade700,
          travelTime: "12h",
          price: "₹1200",
          details: "Overnight sleeper bus via NH48",
          stops: 4,
          mode: "Direct Bus",
          rating: 4.3,
        ),
        RouteOption(
          type: RouteType.fastest,
          title: "FLIGHT",
          subtitle: "Fastest route",
          icon: Icons.flight,
          iconColor: Colors.blue.shade700,
          travelTime: "1h 15m",
          price: "₹3500",
          details: "Direct flight Pune to Bangalore",
          stops: 0,
          mode: "Flight",
          rating: 4.8,
        ),
        RouteOption(
          type: RouteType.mixed,
          title: "TRAIN + METRO",
          subtitle: "Scenic route",
          icon: Icons.train,
          iconColor: Colors.purple.shade700,
          travelTime: "14h",
          price: "₹1800",
          details: "Train + Bangalore metro to destination",
          stops: 8,
          mode: "Mixed Transport",
          rating: 4.2,
        ),
      ]);
    } else if (fromLower.contains("delhi") && toLower.contains("agra")) {
      _routeOptions.addAll([
        RouteOption(
          type: RouteType.cheapest,
          title: "BUS",
          subtitle: "Cheapest route",
          icon: Icons.directions_bus,
          iconColor: Colors.green.shade700,
          travelTime: "3h 30m",
          price: "₹350",
          details: "Express bus via Yamuna Expressway",
          stops: 2,
          mode: "Direct Bus",
          rating: 4.1,
        ),
        RouteOption(
          type: RouteType.fastest,
          title: "TRAIN",
          subtitle: "Fastest route",
          icon: Icons.train,
          iconColor: Colors.blue.shade700,
          travelTime: "2h 15m",
          price: "₹550",
          details: "Gatimaan Express, AC Chair Car",
          stops: 1,
          mode: "Train",
          rating: 4.7,
        ),
        RouteOption(
          type: RouteType.mixed,
          title: "CAR + METRO",
          subtitle: "Flexible route",
          icon: Icons.directions_car,
          iconColor: Colors.orange.shade700,
          travelTime: "3h",
          price: "₹450",
          details: "Car to station + Local transport",
          stops: 4,
          mode: "Mixed Transport",
          rating: 4.3,
        ),
      ]);
    } else {
      // Default routes for any location
      _routeOptions.addAll([
        RouteOption(
          type: RouteType.cheapest,
          title: "BUS",
          subtitle: "Cheapest route",
          icon: Icons.directions_bus,
          iconColor: Colors.green.shade700,
          travelTime: "2h 30m",
          price: "₹350",
          details: "Direct bus service with AC",
          stops: 5,
          mode: "Direct Bus",
          rating: 4.0,
        ),
        RouteOption(
          type: RouteType.fastest,
          title: "TRAIN",
          subtitle: "Fastest route",
          icon: Icons.train,
          iconColor: Colors.blue.shade700,
          travelTime: "1h 45m",
          price: "₹550",
          details: "Express train service",
          stops: 3,
          mode: "Train",
          rating: 4.5,
        ),
        RouteOption(
          type: RouteType.mixed,
          title: "BUS + METRO",
          subtitle: "Eco-friendly route",
          icon: Icons.directions,
          iconColor: Colors.orange.shade700,
          travelTime: "2h 15m",
          price: "₹420",
          details: "Combination of transport modes",
          stops: 8,
          mode: "Multi-modal",
          rating: 4.2,
        ),
      ]);
    }
    
    // Set default selection to cheapest
    _selectedRoute = RouteType.cheapest;
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
      fromLocation = 'Swargate';
      toLocation = 'Hinjawadi Phase 2';
    }
    _fromLatLng = _getLatLng(fromLocation);
    _toLatLng = _getLatLng(toLocation);
    _generateRouteOptions(fromLocation, toLocation);
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

  // Widget to build route option card
  Widget _buildRouteOptionCard(RouteOption option) {
    final isSelected = _selectedRoute == option.type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRoute = option.type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: option.iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(option.icon, color: option.iconColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            option.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "SELECTED",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Rating
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    option.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "• ${option.stops} stops",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "• ${option.mode}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            option.travelTime,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.currency_rupee, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            option.price,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Route details
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option.details,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get selected route details
  String get _selectedRouteDetails {
    final selectedOption = _routeOptions.firstWhere(
      (option) => option.type == _selectedRoute,
      orElse: () => _routeOptions.first,
    );
    
    return "${selectedOption.title} - ${selectedOption.details}";
  }

  String get _selectedRoutePrice {
    final selectedOption = _routeOptions.firstWhere(
      (option) => option.type == _selectedRoute,
      orElse: () => _routeOptions.first,
    );
    
    return selectedOption.price;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // From/To locations card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 14, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'From: $fromLocation',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'To: $toLocation',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            "Today, 10:00 am",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Map Section
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(target: _fromLatLng, zoom: 10),
                    markers: markers,
                    polylines: {routePolyline},
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Route Options Title
              const Text(
                "Available Routes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Select your preferred travel option",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              // Route Options Cards
              ..._routeOptions.map((option) => _buildRouteOptionCard(option)).toList(),

              const SizedBox(height: 24),

              // Selected Route Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selected: ${_routeOptions.firstWhere((opt) => opt.type == _selectedRoute).title}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _selectedRouteDetails,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Book/Request Button
              ElevatedButton(
                onPressed: () {
                  // Show booking dialog or navigate to booking screen
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Booking"),
                      content: Text(
                        "Book ${_routeOptions.firstWhere((opt) => opt.type == _selectedRoute).title} from $fromLocation to $toLocation for ${_selectedRoutePrice}?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/profile');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                          ),
                          child: const Text("Confirm Booking"),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.confirmation_num),
                    SizedBox(width: 10),
                    Text(
                      'Book Selected Route',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}