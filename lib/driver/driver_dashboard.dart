// driver_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

// Route data model
class RouteData {
  final String id;
  final String name;
  final String startPoint;
  final String endPoint;
  final List<String> stops;
  final Map<String, String> stopTimings;
  final double distance;
  final int estimatedDuration;

  RouteData({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    required this.stops,
    required this.stopTimings,
    required this.distance,
    required this.estimatedDuration,
  });
}

class DriverDashboard extends StatefulWidget {
  final String driverId;
  const DriverDashboard({super.key, required this.driverId});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> with SingleTickerProviderStateMixin {
  int passengers = 12;
  String driverName = "Rajesh Kumar";
  String busNumber = "MH 12 AB 1234";
  
  // Available routes
  late List<RouteData> availableRoutes;
  late RouteData currentRoute;
  int currentStopIndex = 0;
  
  late AnimationController _pulseController;
  
  // Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _locationTimer;
  String driverStatus = 'on_route'; // on_route, at_stop, break, offline

  @override
  void initState() {
    super.initState();
    _initializeRoutes();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _loadDriverData();
    _startLocationUpdates();
  }

  void _initializeRoutes() {
    availableRoutes = [
      RouteData(
        id: 'RT001',
        name: 'Pune Station → Hinjewadi',
        startPoint: 'Pune Station',
        endPoint: 'Hinjewadi Phase 3',
        stops: [
          'Pune Station',
          'Shivaji Nagar',
          'Deccan Gymkhana',
          'JM Road',
          'Aundh',
          'Hinjewadi Phase 1',
          'Hinjewadi Phase 2',
          'Hinjewadi Phase 3'
        ],
        stopTimings: {
          'Pune Station': '10:30 AM',
          'Shivaji Nagar': '10:45 AM',
          'Deccan Gymkhana': '10:55 AM',
          'JM Road': '11:05 AM',
          'Aundh': '11:20 AM',
          'Hinjewadi Phase 1': '11:35 AM',
          'Hinjewadi Phase 2': '11:45 AM',
          'Hinjewadi Phase 3': '12:00 PM',
        },
        distance: 18.5,
        estimatedDuration: 90,
      ),
      RouteData(
        id: 'RT002',
        name: 'Swargate → Wakad',
        startPoint: 'Swargate',
        endPoint: 'Wakad',
        stops: [
          'Swargate',
          'Market Yard',
          'Bibwewadi',
          'Katraj',
          'Bharati Vidyapeeth',
          'NIBM Road',
          'Kondhwa',
          'Wakad'
        ],
        stopTimings: {
          'Swargate': '08:00 AM',
          'Market Yard': '08:10 AM',
          'Bibwewadi': '08:20 AM',
          'Katraj': '08:35 AM',
          'Bharati Vidyapeeth': '08:50 AM',
          'NIBM Road': '09:05 AM',
          'Kondhwa': '09:15 AM',
          'Wakad': '09:30 AM',
        },
        distance: 15.2,
        estimatedDuration: 90,
      ),
      RouteData(
        id: 'RT003',
        name: 'Kothrud → Magarpatta',
        startPoint: 'Kothrud',
        endPoint: 'Magarpatta',
        stops: [
          'Kothrud',
          'Paud Road',
          'Erandwane',
          'Prabhat Road',
          'Deccan',
          'JM Road',
          'Mundhwa',
          'Magarpatta'
        ],
        stopTimings: {
          'Kothrud': '09:00 AM',
          'Paud Road': '09:10 AM',
          'Erandwane': '09:20 AM',
          'Prabhat Road': '09:30 AM',
          'Deccan': '09:40 AM',
          'JM Road': '09:50 AM',
          'Mundhwa': '10:05 AM',
          'Magarpatta': '10:20 AM',
        },
        distance: 14.8,
        estimatedDuration: 80,
      ),
      RouteData(
        id: 'RT004',
        name: 'Hadapsar → Pimpri',
        startPoint: 'Hadapsar',
        endPoint: 'Pimpri',
        stops: [
          'Hadapsar',
          'Saswad Road',
          'Kondhwa',
          'Katraj',
          'Bharati Vidyapeeth',
          'Swargate',
          'Shivaji Nagar',
          'Pimpri'
        ],
        stopTimings: {
          'Hadapsar': '07:30 AM',
          'Saswad Road': '07:40 AM',
          'Kondhwa': '07:55 AM',
          'Katraj': '08:10 AM',
          'Bharati Vidyapeeth': '08:25 AM',
          'Swargate': '08:40 AM',
          'Shivaji Nagar': '08:55 AM',
          'Pimpri': '09:15 AM',
        },
        distance: 22.3,
        estimatedDuration: 105,
      ),
      RouteData(
        id: 'RT005',
        name: 'Viman Nagar → Baner',
        startPoint: 'Viman Nagar',
        endPoint: 'Baner',
        stops: [
          'Viman Nagar',
          'Kalyani Nagar',
          'Wanowrie',
          'Koregaon Park',
          'Bund Garden',
          'Shivaji Nagar',
          'Aundh',
          'Baner'
        ],
        stopTimings: {
          'Viman Nagar': '08:30 AM',
          'Kalyani Nagar': '08:40 AM',
          'Wanowrie': '08:50 AM',
          'Koregaon Park': '09:00 AM',
          'Bund Garden': '09:10 AM',
          'Shivaji Nagar': '09:25 AM',
          'Aundh': '09:40 AM',
          'Baner': '09:55 AM',
        },
        distance: 16.7,
        estimatedDuration: 85,
      ),
      RouteData(
        id: 'RT006',
        name: 'Nigdi → Swargate',
        startPoint: 'Nigdi',
        endPoint: 'Swargate',
        stops: [
          'Nigdi',
          'Akurdi',
          'Pimpri',
          'Dapodi',
          'Bopodi',
          'Khadki',
          'Shivaji Nagar',
          'Swargate'
        ],
        stopTimings: {
          'Nigdi': '07:00 AM',
          'Akurdi': '07:08 AM',
          'Pimpri': '07:15 AM',
          'Dapodi': '07:25 AM',
          'Bopodi': '07:32 AM',
          'Khadki': '07:40 AM',
          'Shivaji Nagar': '07:50 AM',
          'Swargate': '08:00 AM',
        },
        distance: 20.5,
        estimatedDuration: 60,
      ),
      RouteData(
        id: 'RT007',
        name: 'Katraj → Vishrantwadi',
        startPoint: 'Katraj',
        endPoint: 'Vishrantwadi',
        stops: [
          'Katraj',
          'Bharati Vidyapeeth',
          'Swargate',
          'Shivaji Nagar',
          'Sangamwadi',
          'Airport Road',
          'Dhanori',
          'Vishrantwadi'
        ],
        stopTimings: {
          'Katraj': '08:15 AM',
          'Bharati Vidyapeeth': '08:25 AM',
          'Swargate': '08:35 AM',
          'Shivaji Nagar': '08:45 AM',
          'Sangamwadi': '08:55 AM',
          'Airport Road': '09:05 AM',
          'Dhanori': '09:15 AM',
          'Vishrantwadi': '09:25 AM',
        },
        distance: 19.8,
        estimatedDuration: 70,
      ),
    ];
    
    currentRoute = availableRoutes.first;
  }

  Future<void> _loadDriverData() async {
    try {
      final driverDoc = await _firestore.collection('users').doc(widget.driverId).get();
      if (driverDoc.exists) {
        setState(() {
          driverName = driverDoc.data()?['name'] ?? 'Rajesh Kumar';
          busNumber = driverDoc.data()?['busNumber'] ?? 'MH 12 AB 1234';
        });
      }
    } catch (e) {
      print("Error loading driver data: $e");
    }
  }

  // ================= LOCATION TRACKING =================
  Future<void> _startLocationUpdates() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled");
      return;
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions denied");
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print("Location permissions permanently denied");
      return;
    }

    // Start location updates every 10 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _updateDriverLocation();
    });

    // Send initial location
    _updateDriverLocation();
  }

  Future<void> _updateDriverLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _firestore.collection('driver_locations').doc(widget.driverId).set({
        'driverId': widget.driverId,
        'driverName': driverName,
        'busNumber': busNumber,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'routeId': currentRoute.id,
        'currentStop': currentStopIndex,
        'status': driverStatus,
        'passengers': passengers,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Location updated: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  Future<void> _updateTripInFirebase() async {
    try {
      await _firestore.collection('trips').doc(widget.driverId).set({
        'driverId': widget.driverId,
        'driverName': driverName,
        'busNumber': busNumber,
        'routeId': currentRoute.id,
        'currentStop': currentStopIndex,
        'passengers': passengers,
        'status': 'active',
        'startTime': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('trip_history').add({
        'driverId': widget.driverId,
        'driverName': driverName,
        'event': 'Currently at ${currentRoute.stops[currentStopIndex]}',
        'routeName': currentRoute.name,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating trip: $e");
    }
  }

  void _setStatus(String status) {
    setState(() {
      driverStatus = status;
    });
    _updateDriverLocation();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _pulseController.dispose();
    
    _firestore.collection('driver_locations').doc(widget.driverId).update({
      'status': 'offline',
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    super.dispose();
  }

  String get currentRouteDisplay => "${currentRoute.startPoint} ➔ ${currentRoute.endPoint}";
  String get nextStop => currentStopIndex < currentRoute.stops.length - 1 
      ? currentRoute.stops[currentStopIndex + 1] 
      : "Destination";
  String get stopsLeft => (currentRoute.stops.length - currentStopIndex - 1).toString();
  
  String get timeRemaining {
    if (currentStopIndex >= currentRoute.stopTimings.length - 1) return "0 min";
    
    final currentTime = currentRoute.stopTimings.values.elementAt(currentStopIndex);
    final nextTime = currentRoute.stopTimings.values.elementAt(currentStopIndex + 1);
    
    final currentHour = int.parse(currentTime.split(':')[0]);
    final currentMin = int.parse(currentTime.split(':')[1].split(' ')[0]);
    final nextHour = int.parse(nextTime.split(':')[0]);
    final nextMin = int.parse(nextTime.split(':')[1].split(' ')[0]);
    
    int diffMinutes = ((nextHour * 60 + nextMin) - (currentHour * 60 + currentMin));
    if (diffMinutes < 0) diffMinutes += 12 * 60;
    
    return "$diffMinutes min";
  }

  List<Map<String, String>> get recentUpdates {
    final updates = <Map<String, String>>[];
    
    updates.add({
      "time": currentRoute.stopTimings[currentRoute.startPoint] ?? "10:30 AM",
      "event": "Trip started from ${currentRoute.startPoint}"
    });
    
    for (int i = 1; i <= currentStopIndex; i++) {
      if (i < currentRoute.stops.length) {
        updates.add({
          "time": currentRoute.stopTimings[currentRoute.stops[i]] ?? "Unknown",
          "event": "Arrived at ${currentRoute.stops[i]}"
        });
      }
    }
    
    updates.add({
      "time": "Now",
      "event": "Currently at ${currentRoute.stops[currentStopIndex]}"
    });
    
    return updates;
  }

  void _changeRoute(RouteData? newRoute) {
    if (newRoute != null) {
      setState(() {
        currentRoute = newRoute;
        currentStopIndex = 0;
      });
      _updateDriverLocation();
      _updateTripInFirebase();
    }
  }

  void _nextStop() {
    if (currentStopIndex < currentRoute.stops.length - 1) {
      setState(() {
        currentStopIndex++;
      });
      _updateDriverLocation();
      _updateTripInFirebase();
    }
  }

  void _previousStop() {
    if (currentStopIndex > 0) {
      setState(() {
        currentStopIndex--;
      });
      _updateDriverLocation();
      _updateTripInFirebase();
    }
  }

  void _addPassenger() {
    setState(() {
      passengers++;
    });
    _updateDriverLocation();
  }

  void _removePassenger() {
    if (passengers > 0) {
      setState(() {
        passengers--;
      });
      _updateDriverLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusSelector(),
                  const SizedBox(height: 16),
                  _buildRouteSelector(),
                  const SizedBox(height: 16),
                  _buildLiveStatusCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Journey Overview"),
                  const SizedBox(height: 12),
                  _buildStatsGrid(),
                  const SizedBox(height: 16),
                  _buildStopProgress(),
                  const SizedBox(height: 28),
                  _buildSectionTitle("Quick Actions"),
                  const SizedBox(height: 12),
                  _buildActionsGrid(),
                  const SizedBox(height: 28),
                  _buildSectionTitle("Recent Activity"),
                  const SizedBox(height: 12),
                  _buildUpdatesList(),
                  const SizedBox(height: 20),
                  _buildNavigationButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Driver Status",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusChip("On Route", Colors.green, driverStatus == 'on_route'),
              const SizedBox(width: 8),
              _buildStatusChip("At Stop", Colors.orange, driverStatus == 'at_stop'),
              const SizedBox(width: 8),
              _buildStatusChip("Break", Colors.blue, driverStatus == 'break'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _setStatus(label.toLowerCase().replaceAll(' ', '_')),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isSelected ? color : color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RouteData>(
          value: currentRoute,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          items: availableRoutes.map((route) {
            return DropdownMenuItem<RouteData>(
              value: route,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.route, size: 16, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          "${route.distance} km • ${route.estimatedDuration} min",
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: _changeRoute,
        ),
      ),
    );
  }

  Widget _buildStopProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Route Progress",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                "${currentStopIndex + 1}/${currentRoute.stops.length} stops",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.blueGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(currentRoute.stops.length, (index) {
                final isCompleted = index < currentStopIndex;
                final isCurrent = index == currentStopIndex;
                
                return Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted 
                                ? Colors.green 
                                : isCurrent 
                                    ? Colors.blue 
                                    : Colors.grey.shade200,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : Text(
                                    "${index + 1}",
                                    style: GoogleFonts.inter(
                                      color: isCurrent ? Colors.white : Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 60,
                          child: Text(
                            currentRoute.stops[index].split(' ').first,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                              color: isCurrent ? Colors.blue : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (index < currentRoute.stops.length - 1)
                      Container(
                        width: 20,
                        height: 2,
                        color: index < currentStopIndex ? Colors.green : Colors.grey.shade300,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1E293B),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -20,
              child: Icon(Icons.directions_bus, size: 200, color: Colors.white.withOpacity(0.1)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("On Duty", style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                              Text(driverName, style: GoogleFonts.inter(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        _buildGlassChip(Icons.numbers, busNumber),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: driverStatus == 'on_route' ? Colors.green.withOpacity(0.2) :
                               driverStatus == 'at_stop' ? Colors.orange.withOpacity(0.2) :
                               driverStatus == 'break' ? Colors.blue.withOpacity(0.2) :
                               Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: driverStatus == 'on_route' ? Colors.green :
                                     driverStatus == 'at_stop' ? Colors.orange :
                                     driverStatus == 'break' ? Colors.blue :
                                     Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            driverStatus.toUpperCase().replaceAll('_', ' '),
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController),
                    child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  ),
                  const SizedBox(width: 8),
                  Text("LIVE TRACKING", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.green.shade700, letterSpacing: 1.2)),
                ],
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(currentRouteDisplay, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildModernStatCard("Passengers", "$passengers", Icons.groups_rounded, const Color(0xFF6366F1)),
        _buildModernStatCard("Next Stop", nextStop, Icons.near_me_rounded, const Color(0xFFF59E0B)),
        _buildModernStatCard("Arrival", timeRemaining, Icons.schedule_rounded, const Color(0xFF06B6D4)),
        _buildModernStatCard("Stops Left", stopsLeft, Icons.directions_bus_rounded, const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _buildModernStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildCircularAction(Icons.person_add, "Add", Colors.green, _addPassenger),
        _buildCircularAction(Icons.person_remove, "Remove", Colors.orange, _removePassenger),
        _buildCircularAction(Icons.share_location, "Share", Colors.blue, () {}),
        _buildCircularAction(Icons.warning_amber_rounded, "Issue", Colors.red, _showIssueDialog),
      ],
    );
  }

  void _showIssueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.traffic, color: Colors.orange),
              title: const Text('Traffic Jam'),
              onTap: () => _reportIssue('traffic'),
            ),
            ListTile(
              leading: const Icon(Icons.construction, color: Colors.red),
              title: const Text('Road Work'),
              onTap: () => _reportIssue('road_work'),
            ),
            ListTile(
              leading: const Icon(Icons.emergency, color: Colors.red),
              title: const Text('Emergency'),
              onTap: () => _reportIssue('emergency'),
            ),
            ListTile(
              leading: const Icon(Icons.directions_bus, color: Colors.blue),
              title: const Text('Bus Issue'),
              onTap: () => _reportIssue('bus_issue'),
            ),
          ],
        ),
      ),
    );
  }

  void _reportIssue(String type) async {
    Navigator.pop(context);
    
    await _firestore.collection('issues').add({
      'driverId': widget.driverId,
      'driverName': driverName,
      'busNumber': busNumber,
      'routeId': currentRoute.id,
      'currentStop': currentStopIndex,
      'issueType': type,
      'status': 'reported',
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Issue reported successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildCircularAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
      ],
    );
  }

  Widget _buildUpdatesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentUpdates.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100, indent: 60),
        itemBuilder: (context, index) {
          final item = recentUpdates[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blueGrey.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.history, size: 20, color: Colors.blueGrey),
            ),
            title: Text(item["event"]!, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF1E293B))),
            subtitle: Text(item["time"]!, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          );
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: currentStopIndex > 0 ? _previousStop : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text("Previous Stop"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: currentStopIndex < currentRoute.stops.length - 1 ? _nextStop : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text("Next Stop"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF334155)));
  }

  Widget _buildGlassChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}