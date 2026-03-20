import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'end_trip_screen.dart';

// Route model for map screen
class MapRouteData {
  final String id;
  final String name;
  final LatLng startPoint;
  final LatLng currentLocation;
  final LatLng endPoint;
  final List<LatLng> routePoints;
  final List<String> stopNames;
  final double distance;
  final int estimatedDuration;

  MapRouteData({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.currentLocation,
    required this.endPoint,
    required this.routePoints,
    required this.stopNames,
    required this.distance,
    required this.estimatedDuration,
  });
}

class LiveLocationScreen extends StatefulWidget {
  final String? selectedRouteId;
  const LiveLocationScreen({super.key, this.selectedRouteId});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  int passengers = 12;
  int currentStopIndex = 1;
  GoogleMapController? _mapController;
  bool _isMapLoading = true;
  
  late List<MapRouteData> availableRoutes;
  late MapRouteData currentRoute;
  
  @override
  void initState() {
    super.initState();
    _initializeRoutes();
    _checkPermission();
  }

  void _initializeRoutes() {
    availableRoutes = [
      MapRouteData(
        id: 'RT001',
        name: 'Pune Station → Hinjewadi',
        startPoint: const LatLng(18.5204, 73.8567), // Pune Station
        currentLocation: const LatLng(18.5400, 73.8700), // Shivaji Nagar area
        endPoint: const LatLng(18.5800, 73.8900), // Hinjewadi
        routePoints: [
          const LatLng(18.5204, 73.8567), // Pune Station
          const LatLng(18.5300, 73.8620), // Shivaji Nagar
          const LatLng(18.5400, 73.8700), // Deccan
          const LatLng(18.5500, 73.8800), // JM Road
          const LatLng(18.5650, 73.8850), // Aundh
          const LatLng(18.5750, 73.8880), // Hinjewadi Phase 1
          const LatLng(18.5780, 73.8890), // Hinjewadi Phase 2
          const LatLng(18.5800, 73.8900), // Hinjewadi Phase 3
        ],
        stopNames: [
          'Pune Station',
          'Shivaji Nagar',
          'Deccan Gymkhana',
          'JM Road',
          'Aundh',
          'Hinjewadi Phase 1',
          'Hinjewadi Phase 2',
          'Hinjewadi Phase 3'
        ],
        distance: 18.5,
        estimatedDuration: 90,
      ),
      MapRouteData(
        id: 'RT002',
        name: 'Swargate → Wakad',
        startPoint: const LatLng(18.5000, 73.8600), // Swargate
        currentLocation: const LatLng(18.5200, 73.8750), // Katraj area
        endPoint: const LatLng(18.5900, 73.9100), // Wakad
        routePoints: [
          const LatLng(18.5000, 73.8600), // Swargate
          const LatLng(18.5050, 73.8650), // Market Yard
          const LatLng(18.5100, 73.8700), // Bibwewadi
          const LatLng(18.5200, 73.8750), // Katraj
          const LatLng(18.5350, 73.8850), // Bharati Vidyapeeth
          const LatLng(18.5500, 73.8950), // NIBM Road
          const LatLng(18.5700, 73.9050), // Kondhwa
          const LatLng(18.5900, 73.9100), // Wakad
        ],
        stopNames: [
          'Swargate',
          'Market Yard',
          'Bibwewadi',
          'Katraj',
          'Bharati Vidyapeeth',
          'NIBM Road',
          'Kondhwa',
          'Wakad'
        ],
        distance: 15.2,
        estimatedDuration: 90,
      ),
      MapRouteData(
        id: 'RT003',
        name: 'Kothrud → Magarpatta',
        startPoint: const LatLng(18.5100, 73.8200), // Kothrud
        currentLocation: const LatLng(18.5250, 73.8400), // Erandwane
        endPoint: const LatLng(18.5200, 73.9300), // Magarpatta
        routePoints: [
          const LatLng(18.5100, 73.8200), // Kothrud
          const LatLng(18.5150, 73.8250), // Paud Road
          const LatLng(18.5250, 73.8400), // Erandwane
          const LatLng(18.5300, 73.8500), // Prabhat Road
          const LatLng(18.5250, 73.8550), // Deccan
          const LatLng(18.5300, 73.8700), // JM Road
          const LatLng(18.5250, 73.9000), // Mundhwa
          const LatLng(18.5200, 73.9300), // Magarpatta
        ],
        stopNames: [
          'Kothrud',
          'Paud Road',
          'Erandwane',
          'Prabhat Road',
          'Deccan',
          'JM Road',
          'Mundhwa',
          'Magarpatta'
        ],
        distance: 14.8,
        estimatedDuration: 80,
      ),
      MapRouteData(
        id: 'RT004',
        name: 'Hadapsar → Pimpri',
        startPoint: const LatLng(18.5080, 73.9250), // Hadapsar
        currentLocation: const LatLng(18.5200, 73.8900), // Kondhwa area
        endPoint: const LatLng(18.6200, 73.8100), // Pimpri
        routePoints: [
          const LatLng(18.5080, 73.9250), // Hadapsar
          const LatLng(18.5100, 73.9150), // Saswad Road
          const LatLng(18.5200, 73.8900), // Kondhwa
          const LatLng(18.5200, 73.8750), // Katraj
          const LatLng(18.5350, 73.8700), // Bharati Vidyapeeth
          const LatLng(18.5000, 73.8600), // Swargate
          const LatLng(18.5300, 73.8500), // Shivaji Nagar
          const LatLng(18.6200, 73.8100), // Pimpri
        ],
        stopNames: [
          'Hadapsar',
          'Saswad Road',
          'Kondhwa',
          'Katraj',
          'Bharati Vidyapeeth',
          'Swargate',
          'Shivaji Nagar',
          'Pimpri'
        ],
        distance: 22.3,
        estimatedDuration: 105,
      ),
      MapRouteData(
        id: 'RT005',
        name: 'Viman Nagar → Baner',
        startPoint: const LatLng(18.5670, 73.9100), // Viman Nagar
        currentLocation: const LatLng(18.5450, 73.8900), // Koregaon Park
        endPoint: const LatLng(18.5600, 73.7800), // Baner
        routePoints: [
          const LatLng(18.5670, 73.9100), // Viman Nagar
          const LatLng(18.5600, 73.9000), // Kalyani Nagar
          const LatLng(18.5500, 73.9000), // Wanowrie
          const LatLng(18.5450, 73.8900), // Koregaon Park
          const LatLng(18.5350, 73.8800), // Bund Garden
          const LatLng(18.5300, 73.8500), // Shivaji Nagar
          const LatLng(18.5500, 73.8200), // Aundh
          const LatLng(18.5600, 73.7800), // Baner
        ],
        stopNames: [
          'Viman Nagar',
          'Kalyani Nagar',
          'Wanowrie',
          'Koregaon Park',
          'Bund Garden',
          'Shivaji Nagar',
          'Aundh',
          'Baner'
        ],
        distance: 16.7,
        estimatedDuration: 85,
      ),
    ];
    
    // Set default route or find selected route
    if (widget.selectedRouteId != null) {
      final found = availableRoutes.firstWhere(
        (route) => route.id == widget.selectedRouteId,
        orElse: () => availableRoutes.first,
      );
      currentRoute = found;
    } else {
      currentRoute = availableRoutes.first;
    }
    
    // Find current stop index based on current location
    currentStopIndex = _findCurrentStopIndex();
  }

  int _findCurrentStopIndex() {
    // In a real app, you'd calculate based on actual GPS
    // For demo, we'll return index 1 (second stop)
    return 1;
  }

  Future<void> _checkPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapLoading = false;
    });
  }

  Future<void> _zoomIn() async {
    if (_mapController != null) {
      final currentZoom = await _mapController!.getZoomLevel();
      _mapController!.animateCamera(
        CameraUpdate.zoomTo(currentZoom + 1),
      );
    }
  }

  Future<void> _zoomOut() async {
    if (_mapController != null) {
      final currentZoom = await _mapController!.getZoomLevel();
      _mapController!.animateCamera(
        CameraUpdate.zoomTo(currentZoom - 1),
      );
    }
  }

  Future<void> _centerOnCurrentLocation() async {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentRoute.currentLocation,
            zoom: 16,
          ),
        ),
      );
    }
  }

  void _changeRoute(MapRouteData? newRoute) {
    if (newRoute != null) {
      setState(() {
        currentRoute = newRoute;
        currentStopIndex = _findCurrentStopIndex();
      });
      _centerOnCurrentLocation();
    }
  }

  String get nextStopName {
    return currentStopIndex < currentRoute.stopNames.length - 1
        ? currentRoute.stopNames[currentStopIndex + 1]
        : 'Destination';
  }

  @override
  Widget build(BuildContext context) {
    // Create markers
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: currentRoute.currentLocation,
        infoWindow: InfoWindow(
          title: 'Your Bus',
          snippet: currentRoute.stopNames[currentStopIndex],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(
        markerId: const MarkerId('startLocation'),
        position: currentRoute.startPoint,
        infoWindow: const InfoWindow(title: 'Start Point'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('endLocation'),
        position: currentRoute.endPoint,
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    // Add markers for all stops
    for (int i = 0; i < currentRoute.routePoints.length; i++) {
      if (i != 0 && i != currentRoute.routePoints.length - 1) {
        markers.add(
          Marker(
            markerId: MarkerId('stop_$i'),
            position: currentRoute.routePoints[i],
            infoWindow: InfoWindow(title: currentRoute.stopNames[i]),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              i == currentStopIndex ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    }

    // Create polyline for route
    final Polyline routePolyline = Polyline(
      polylineId: const PolylineId('driverRoute'),
      points: currentRoute.routePoints,
      color: Colors.blue.shade700,
      width: 4,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Live Trip Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: DropdownButton<MapRouteData>(
              value: currentRoute,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              underline: Container(),
              items: availableRoutes.map((route) {
                return DropdownMenuItem<MapRouteData>(
                  value: route,
                  child: Text(
                    route.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: _changeRoute,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Map Section
          Stack(
            children: [
              Container(
                height: 280,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: currentRoute.currentLocation,
                          zoom: 14,
                        ),
                        markers: markers,
                        polylines: {routePolyline},
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                      ),
                      if (_isMapLoading)
                        Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Map Overlay Controls
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.my_location),
                        onPressed: _centerOnCurrentLocation,
                        color: Colors.blue.shade700,
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey.shade300,
                      ),
                      IconButton(
                        icon: const Icon(Icons.zoom_in),
                        onPressed: _zoomIn,
                        color: Colors.blue.shade700,
                      ),
                      IconButton(
                        icon: const Icon(Icons.zoom_out),
                        onPressed: _zoomOut,
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Info Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.route, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentRoute.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${currentRoute.distance} km',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Trip Progress Indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTripPoint('Start', currentRoute.stopNames.first, Icons.trip_origin),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: Colors.blue.shade200,
                              ),
                            ),
                            _buildTripPoint('Current', currentRoute.stopNames[currentStopIndex], Icons.directions_bus),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: Colors.blue.shade200,
                              ),
                            ),
                            _buildTripPoint('End', currentRoute.stopNames.last, Icons.flag),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: (currentStopIndex + 1) / currentRoute.stopNames.length,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${currentStopIndex + 1}/${currentRoute.stopNames.length} stops completed',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            Text(
                              '${currentRoute.estimatedDuration} min total',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Live Status Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernInfoCard(
                          "Next Stop",
                          nextStopName,
                          Icons.pin_drop,
                          Colors.orange,
                          context,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModernInfoCard(
                          "Passengers",
                          "$passengers",
                          Icons.people,
                          Colors.green,
                          context,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quick Stats Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Trip Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Distance', '${currentRoute.distance} km', Icons.alt_route),
                            _buildStatItem('Duration', '${currentRoute.estimatedDuration} min', Icons.timer),
                            _buildStatItem('Stops', '${currentRoute.stopNames.length - currentStopIndex - 1} left', Icons.location_on),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stops List
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Route Stops",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: currentRoute.stopNames.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            bool isPassed = index < currentStopIndex;
                            bool isCurrent = index == currentStopIndex;
                            
                            return Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isPassed
                                        ? Colors.green
                                        : isCurrent
                                            ? Colors.blue
                                            : Colors.grey.shade300,
                                  ),
                                  child: Center(
                                    child: isPassed
                                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                                        : Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              color: isCurrent ? Colors.white : Colors.grey.shade600,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    currentRoute.stopNames[index],
                                    style: TextStyle(
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                      color: isPassed ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                ),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'CURRENT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => passengers++),
                          icon: const Icon(Icons.add),
                          label: Text("Add Passenger ($passengers)"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (passengers > 0) {
                              setState(() => passengers--);
                            }
                          },
                          icon: const Icon(Icons.remove),
                          label: const Text("Remove"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            side: BorderSide(color: Colors.red.shade200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Navigation buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: currentStopIndex > 0
                              ? () {
                                  setState(() {
                                    currentStopIndex--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Previous Stop"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: currentStopIndex < currentRoute.stopNames.length - 1
                              ? () {
                                  setState(() {
                                    currentStopIndex++;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text("Next Stop"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // End Trip Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showEndTripDialog(context);
                      },
                      child: const Text(
                        "END TRIP",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripPoint(String label, String location, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          location.length > 10 ? '${location.substring(0, 10)}...' : location,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildModernInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showEndTripDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('End Trip'),
          content: const Text('Are you sure you want to end this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const EndTripScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('End Trip'),
            ),
          ],
        );
      },
    );
  }
}