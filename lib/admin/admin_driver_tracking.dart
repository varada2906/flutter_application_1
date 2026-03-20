// admin_driver_tracking.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Web साठी flutter_map
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart' as latlong;

// Mobile साठी google_maps
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminDriverTrackingPage extends StatefulWidget {
  const AdminDriverTrackingPage({super.key});

  @override
  State<AdminDriverTrackingPage> createState() => _AdminDriverTrackingPageState();
}

class _AdminDriverTrackingPageState extends State<AdminDriverTrackingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Map controllers
  GoogleMapController? _mobileMapController;
  final flutter_map.MapController _webMapController = flutter_map.MapController();
  
  List<Map<String, dynamic>> _activeDrivers = [];
  Map<String, dynamic>? _selectedDriver;
  bool _isLoading = true;
  String _selectedRoute = 'all';
  String _searchQuery = '';

  // Pune center coordinates
  static const double _puneCenterLat = 18.5204;
  static const double _puneCenterLng = 73.8567;

  // Web markers
  List<flutter_map.Marker> _webMarkers = [];
  
  // Mobile markers
  Set<Marker> _mobileMarkers = {};

  // Current zoom level for web
  double _currentWebZoom = 11.0;

  // Routes data
  final List<Map<String, dynamic>> _routes = [
    {
      'id': 'RT001',
      'name': 'Pune Station → Hinjewadi',
      'color': Colors.blue,
      'webColor': '#4285F4',
      'points': const [
        latlong.LatLng(18.5204, 73.8567),
        latlong.LatLng(18.5300, 73.8620),
        latlong.LatLng(18.5400, 73.8700),
        latlong.LatLng(18.5500, 73.8800),
        latlong.LatLng(18.5650, 73.8850),
        latlong.LatLng(18.5750, 73.8880),
        latlong.LatLng(18.5780, 73.8890),
        latlong.LatLng(18.5800, 73.8900),
      ],
      'mobilePoints': const [
        LatLng(18.5204, 73.8567),
        LatLng(18.5300, 73.8620),
        LatLng(18.5400, 73.8700),
        LatLng(18.5500, 73.8800),
        LatLng(18.5650, 73.8850),
        LatLng(18.5750, 73.8880),
        LatLng(18.5780, 73.8890),
        LatLng(18.5800, 73.8900),
      ],
      'stops': [
        'Pune Station',
        'Shivaji Nagar',
        'Deccan Gymkhana',
        'JM Road',
        'Aundh',
        'Hinjewadi Phase 1',
        'Hinjewadi Phase 2',
        'Hinjewadi Phase 3'
      ],
    },
    {
      'id': 'RT002',
      'name': 'Swargate → Wakad',
      'color': Colors.orange,
      'webColor': '#FB8C00',
      'points': const [
        latlong.LatLng(18.5000, 73.8600),
        latlong.LatLng(18.5050, 73.8650),
        latlong.LatLng(18.5100, 73.8700),
        latlong.LatLng(18.5200, 73.8750),
        latlong.LatLng(18.5350, 73.8850),
        latlong.LatLng(18.5500, 73.8950),
        latlong.LatLng(18.5700, 73.9050),
        latlong.LatLng(18.5900, 73.9100),
      ],
      'mobilePoints': const [
        LatLng(18.5000, 73.8600),
        LatLng(18.5050, 73.8650),
        LatLng(18.5100, 73.8700),
        LatLng(18.5200, 73.8750),
        LatLng(18.5350, 73.8850),
        LatLng(18.5500, 73.8950),
        LatLng(18.5700, 73.9050),
        LatLng(18.5900, 73.9100),
      ],
      'stops': [
        'Swargate',
        'Market Yard',
        'Bibwewadi',
        'Katraj',
        'Bharati Vidyapeeth',
        'NIBM Road',
        'Kondhwa',
        'Wakad'
      ],
    },
    {
      'id': 'RT003',
      'name': 'Kothrud → Magarpatta',
      'color': Colors.green,
      'webColor': '#0F9D58',
      'points': const [
        latlong.LatLng(18.5100, 73.8200),
        latlong.LatLng(18.5150, 73.8250),
        latlong.LatLng(18.5250, 73.8400),
        latlong.LatLng(18.5300, 73.8500),
        latlong.LatLng(18.5250, 73.8550),
        latlong.LatLng(18.5300, 73.8700),
        latlong.LatLng(18.5250, 73.9000),
        latlong.LatLng(18.5200, 73.9300),
      ],
      'mobilePoints': const [
        LatLng(18.5100, 73.8200),
        LatLng(18.5150, 73.8250),
        LatLng(18.5250, 73.8400),
        LatLng(18.5300, 73.8500),
        LatLng(18.5250, 73.8550),
        LatLng(18.5300, 73.8700),
        LatLng(18.5250, 73.9000),
        LatLng(18.5200, 73.9300),
      ],
      'stops': [
        'Kothrud',
        'Paud Road',
        'Erandwane',
        'Prabhat Road',
        'Deccan',
        'JM Road',
        'Mundhwa',
        'Magarpatta'
      ],
    },
    {
      'id': 'RT004',
      'name': 'Hadapsar → Pimpri',
      'color': Colors.purple,
      'webColor': '#9C27B0',
      'points': const [
        latlong.LatLng(18.5080, 73.9250),
        latlong.LatLng(18.5100, 73.9150),
        latlong.LatLng(18.5200, 73.8900),
        latlong.LatLng(18.5200, 73.8750),
        latlong.LatLng(18.5350, 73.8700),
        latlong.LatLng(18.5000, 73.8600),
        latlong.LatLng(18.5300, 73.8500),
        latlong.LatLng(18.6200, 73.8100),
      ],
      'mobilePoints': const [
        LatLng(18.5080, 73.9250),
        LatLng(18.5100, 73.9150),
        LatLng(18.5200, 73.8900),
        LatLng(18.5200, 73.8750),
        LatLng(18.5350, 73.8700),
        LatLng(18.5000, 73.8600),
        LatLng(18.5300, 73.8500),
        LatLng(18.6200, 73.8100),
      ],
      'stops': [
        'Hadapsar',
        'Saswad Road',
        'Kondhwa',
        'Katraj',
        'Bharati Vidyapeeth',
        'Swargate',
        'Shivaji Nagar',
        'Pimpri'
      ],
    },
    {
      'id': 'RT005',
      'name': 'Viman Nagar → Baner',
      'color': Colors.red,
      'webColor': '#DB4437',
      'points': const [
        latlong.LatLng(18.5670, 73.9100),
        latlong.LatLng(18.5600, 73.9000),
        latlong.LatLng(18.5500, 73.9000),
        latlong.LatLng(18.5450, 73.8900),
        latlong.LatLng(18.5350, 73.8800),
        latlong.LatLng(18.5300, 73.8500),
        latlong.LatLng(18.5500, 73.8200),
        latlong.LatLng(18.5600, 73.7800),
      ],
      'mobilePoints': const [
        LatLng(18.5670, 73.9100),
        LatLng(18.5600, 73.9000),
        LatLng(18.5500, 73.9000),
        LatLng(18.5450, 73.8900),
        LatLng(18.5350, 73.8800),
        LatLng(18.5300, 73.8500),
        LatLng(18.5500, 73.8200),
        LatLng(18.5600, 73.7800),
      ],
      'stops': [
        'Viman Nagar',
        'Kalyani Nagar',
        'Wanowrie',
        'Koregaon Park',
        'Bund Garden',
        'Shivaji Nagar',
        'Aundh',
        'Baner'
      ],
    },
    {
      'id': 'RT006',
      'name': 'Nigdi → Swargate',
      'color': Colors.teal,
      'webColor': '#00ACC1',
      'points': const [
        latlong.LatLng(18.6500, 73.7700),
        latlong.LatLng(18.6400, 73.7800),
        latlong.LatLng(18.6200, 73.8100),
        latlong.LatLng(18.5900, 73.8200),
        latlong.LatLng(18.5800, 73.8300),
        latlong.LatLng(18.5600, 73.8400),
        latlong.LatLng(18.5300, 73.8500),
        latlong.LatLng(18.5000, 73.8600),
      ],
      'mobilePoints': const [
        LatLng(18.6500, 73.7700),
        LatLng(18.6400, 73.7800),
        LatLng(18.6200, 73.8100),
        LatLng(18.5900, 73.8200),
        LatLng(18.5800, 73.8300),
        LatLng(18.5600, 73.8400),
        LatLng(18.5300, 73.8500),
        LatLng(18.5000, 73.8600),
      ],
      'stops': [
        'Nigdi',
        'Akurdi',
        'Pimpri',
        'Dapodi',
        'Bopodi',
        'Khadki',
        'Shivaji Nagar',
        'Swargate'
      ],
    },
    {
      'id': 'RT007',
      'name': 'Katraj → Vishrantwadi',
      'color': Colors.indigo,
      'webColor': '#3F51B5',
      'points': const [
        latlong.LatLng(18.5200, 73.8750),
        latlong.LatLng(18.5350, 73.8700),
        latlong.LatLng(18.5000, 73.8600),
        latlong.LatLng(18.5300, 73.8500),
        latlong.LatLng(18.5500, 73.8700),
        latlong.LatLng(18.5700, 73.8800),
        latlong.LatLng(18.5800, 73.8900),
        latlong.LatLng(18.5900, 73.9000),
      ],
      'mobilePoints': const [
        LatLng(18.5200, 73.8750),
        LatLng(18.5350, 73.8700),
        LatLng(18.5000, 73.8600),
        LatLng(18.5300, 73.8500),
        LatLng(18.5500, 73.8700),
        LatLng(18.5700, 73.8800),
        LatLng(18.5800, 73.8900),
        LatLng(18.5900, 73.9000),
      ],
      'stops': [
        'Katraj',
        'Bharati Vidyapeeth',
        'Swargate',
        'Shivaji Nagar',
        'Sangamwadi',
        'Airport Road',
        'Dhanori',
        'Vishrantwadi'
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchActiveDrivers();
    _setupRealtimeListener();
  }

  void _setupRealtimeListener() {
    _firestore.collection('driver_locations').snapshots().listen((snapshot) {
      _fetchActiveDrivers();
    });
  }

  Future<void> _fetchActiveDrivers() async {
    try {
      final driversSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'driver')
          .get();

      List<Map<String, dynamic>> drivers = [];

      for (var driverDoc in driversSnapshot.docs) {
        final driverData = driverDoc.data();
        
        final locationDoc = await _firestore
            .collection('driver_locations')
            .doc(driverDoc.id)
            .get();

        if (locationDoc.exists) {
          final locationData = locationDoc.data() as Map<String, dynamic>;
          
          drivers.add({
            'id': driverDoc.id,
            'name': driverData['name'] ?? 'Unknown Driver',
            'busNumber': driverData['busNumber'] ?? 'Not Assigned',
            'status': locationData['status'] ?? 'offline',
            'latitude': locationData['latitude'] ?? 18.5204,
            'longitude': locationData['longitude'] ?? 73.8567,
            'routeId': locationData['routeId'] ?? 'RT001',
            'currentStop': locationData['currentStop'] ?? 0,
            'passengers': locationData['passengers'] ?? 0,
            'lastUpdate': (locationData['timestamp'] as Timestamp?)?.toDate(),
          });
        } else {
          drivers.add({
            'id': driverDoc.id,
            'name': driverData['name'] ?? 'Unknown Driver',
            'busNumber': driverData['busNumber'] ?? 'Not Assigned',
            'status': 'offline',
            'latitude': null,
            'longitude': null,
            'routeId': null,
            'currentStop': 0,
            'passengers': 0,
            'lastUpdate': null,
          });
        }
      }

      setState(() {
        _activeDrivers = drivers;
        _updateMarkers();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching drivers: $e");
      setState(() => _isLoading = false);
    }
  }

  // ================= UPDATED MARKERS FUNCTION =================
  void _updateMarkers() {
    if (kIsWeb) {
      // Web markers - Correct syntax for flutter_map
      _webMarkers = [];
      for (var driver in _activeDrivers) {
        if (driver['status'] != 'offline' && driver['latitude'] != null) {
          Color markerColor = _getStatusColor(driver['status']);
          
          _webMarkers.add(
            flutter_map.Marker(
              point: latlong.LatLng(driver['latitude'], driver['longitude']),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDriver = driver;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      driver['name'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    } else {
      // Mobile markers - Google Maps
      Set<Marker> markers = {};
      for (var driver in _activeDrivers) {
        if (driver['status'] != 'offline' && driver['latitude'] != null) {
          markers.add(
            Marker(
              markerId: MarkerId(driver['id']),
              position: LatLng(driver['latitude'], driver['longitude']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _colorToHue(_getStatusColor(driver['status'])),
              ),
              infoWindow: InfoWindow(
                title: driver['name'],
                snippet: 'Bus: ${driver['busNumber']}',
              ),
              onTap: () {
                setState(() {
                  _selectedDriver = driver;
                });
              },
            ),
          );
        }
      }
      _mobileMarkers = markers;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'on_route': return Colors.green;
      case 'at_stop': return Colors.orange;
      case 'break': return Colors.blue;
      default: return Colors.grey;
    }
  }

  double _colorToHue(Color color) {
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    return BitmapDescriptor.hueRed;
  }

  List<Map<String, dynamic>> get _filteredDrivers {
    var filtered = _activeDrivers;

    if (_selectedRoute != 'all') {
      filtered = filtered.where((d) => d['routeId'] == _selectedRoute).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((d) {
        final name = d['name'].toString().toLowerCase();
        final bus = d['busNumber'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || bus.contains(query);
      }).toList();
    }

    return filtered;
  }

  void _centerOnDriver(Map<String, dynamic> driver) {
    if (driver['latitude'] == null) return;

    if (kIsWeb) {
      _webMapController.move(
        latlong.LatLng(driver['latitude'], driver['longitude']),
        15.0,
      );
    } else {
      _mobileMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(driver['latitude'], driver['longitude']),
            zoom: 15,
          ),
        ),
      );
    }
  }

  // ================= ZOOM FUNCTIONS =================
  void _zoomIn() {
    if (kIsWeb) {
      setState(() {
        _currentWebZoom += 1.0;
      });
      _webMapController.move(
        _webMapController.center,
        _currentWebZoom,
      );
    } else {
      _mobileMapController?.animateCamera(
        CameraUpdate.zoomIn(),
      );
    }
  }

  void _zoomOut() {
    if (kIsWeb) {
      setState(() {
        _currentWebZoom -= 1.0;
        if (_currentWebZoom < 1) _currentWebZoom = 1;
      });
      _webMapController.move(
        _webMapController.center,
        _currentWebZoom,
      );
    } else {
      _mobileMapController?.animateCamera(
        CameraUpdate.zoomOut(),
      );
    }
  }

  void _centerMap() {
    if (kIsWeb) {
      setState(() {
        _currentWebZoom = 11.0;
      });
      _webMapController.move(
        latlong.LatLng(_puneCenterLat, _puneCenterLng),
        _currentWebZoom,
      );
    } else {
      _mobileMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(_puneCenterLat, _puneCenterLng),
            zoom: 11,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Map Section
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: kIsWeb ? _buildWebMap() : _buildMobileMap(),
                    ),
                  ),
                ),

                // Driver List Section
                Expanded(
                  flex: 1,
                  child: _buildDriverList(),
                ),
              ],
            ),
    );
  }

  Widget _buildWebMap() {
    return Stack(
      children: [
        flutter_map.FlutterMap(
          mapController: _webMapController,
          options: flutter_map.MapOptions(
            center: latlong.LatLng(_puneCenterLat, _puneCenterLng),
            zoom: _currentWebZoom,
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
                setState(() {
                  _currentWebZoom = position.zoom ?? 11.0;
                });
              }
            },
          ),
          children: [
            flutter_map.TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            flutter_map.PolylineLayer(
              polylines: _getWebPolylines(),
            ),
            flutter_map.MarkerLayer(
              markers: _webMarkers,
            ),
          ],
        ),
        _buildMapControls(),
        _buildRouteFilter(),
      ],
    );
  }

  Widget _buildMobileMap() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            _mobileMapController = controller;
          },
          initialCameraPosition: const CameraPosition(
            target: LatLng(_puneCenterLat, _puneCenterLng),
            zoom: 11,
          ),
          markers: _mobileMarkers,
          polylines: _getMobilePolylines(),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
        _buildMapControls(),
        _buildRouteFilter(),
      ],
    );
  }

  // ================= WEB POLYLINES =================
  List<flutter_map.Polyline> _getWebPolylines() {
    List<flutter_map.Polyline> polylines = [];

    if (_selectedRoute == 'all') {
      for (var route in _routes) {
        polylines.add(
          flutter_map.Polyline(
            points: route['points'],
            color: (route['color'] as Color).withOpacity(0.3),
            strokeWidth: 2,
          ),
        );
      }
    } else {
      final route = _routes.firstWhere(
        (r) => r['id'] == _selectedRoute,
        orElse: () => _routes.first,
      );
      polylines.add(
        flutter_map.Polyline(
          points: route['points'],
          color: route['color'],
          strokeWidth: 4,
        ),
      );
    }

    return polylines;
  }

  // ================= MOBILE POLYLINES =================
  Set<Polyline> _getMobilePolylines() {
    Set<Polyline> polylines = {};

    if (_selectedRoute == 'all') {
      for (var route in _routes) {
        polylines.add(
          Polyline(
            polylineId: PolylineId(route['id']),
            points: List<LatLng>.from(route['mobilePoints']),
            color: (route['color'] as Color).withOpacity(0.3),
            width: 2,
          ),
        );
      }
    } else {
      final route = _routes.firstWhere(
        (r) => r['id'] == _selectedRoute,
        orElse: () => _routes.first,
      );
      polylines.add(
        Polyline(
          polylineId: PolylineId(route['id']),
          points: List<LatLng>.from(route['mobilePoints']),
          color: route['color'],
          width: 4,
        ),
      );
    }

    return polylines;
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
          ],
        ),
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: _zoomIn,
              tooltip: 'Zoom In',
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: _zoomOut,
              tooltip: 'Zoom Out',
            ),
            const Divider(height: 1),
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _centerMap,
              tooltip: 'Center Map',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteFilter() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2))
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedRoute,
            items: [
              const DropdownMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.route, size: 16),
                    SizedBox(width: 8),
                    Text('All Routes'),
                  ],
                ),
              ),
              ..._routes.map((route) {
                return DropdownMenuItem(
                  value: route['id'],
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: route['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(route['name']),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRoute = value!;
                _updateMarkers();
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDriverList() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
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
          Text(
            "Active Drivers",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${_filteredDrivers.where((d) => d['status'] != 'offline').length} online · ${_filteredDrivers.length} total",
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // Search
          TextField(
            decoration: InputDecoration(
              hintText: 'Search driver or bus...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Status Legend
          Row(
            children: [
              _legendItem("On Route", Colors.green),
              const SizedBox(width: 12),
              _legendItem("At Stop", Colors.orange),
              const SizedBox(width: 12),
              _legendItem("Break", Colors.blue),
              const SizedBox(width: 12),
              _legendItem("Offline", Colors.grey),
            ],
          ),

          const SizedBox(height: 16),

          // Driver List
          Expanded(
            child: _filteredDrivers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text(
                          'No drivers found',
                          style: GoogleFonts.poppins(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = _filteredDrivers[index];
                      final route = _routes.firstWhere(
                        (r) => r['id'] == driver['routeId'],
                        orElse: () => _routes.first,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: _selectedDriver?['id'] == driver['id']
                            ? Colors.green.shade50
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _selectedDriver?['id'] == driver['id']
                                ? Colors.green.shade200
                                : Colors.transparent,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              _selectedDriver = driver;
                            });
                            _centerOnDriver(driver);
                          },
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(driver['status']),
                            child: Text(
                              driver['name'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            driver['name'],
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bus: ${driver['busNumber']}'),
                              if (driver['status'] != 'offline')
                                Text('Route: ${route['name']}'),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(driver['status']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  driver['status'].toString().toUpperCase().replaceAll('_', ' '),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(driver['status']),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}