import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/route_suggstion_args.dart';
import 'dart:async';



class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const double _navHeight = 75.0;
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  DateTime selectedDateTime = DateTime.now();

  int _page = 1;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  TransportMode _selectedMode = TransportMode.bus;
  int _notificationCount = 0;
  List<Map<String, String>> _notifications = [];

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Store buses and metros from Firestore
  List<Map<String, dynamic>> _firestoreBuses = [];
  List<Map<String, dynamic>> _firestoreMetros = [];
  StreamSubscription? _busSubscription;
  StreamSubscription? _metroSubscription;

  @override
  void initState() {
    super.initState();
    // Load data from Firestore
    _loadBusesFromFirestore();
    _loadMetrosFromFirestore();
  }

  void _loadMetrosFromFirestore() {
    _metroSubscription = _firestore.collection('metros').snapshots().listen((snapshot) {
      final List<Map<String, dynamic>> loaded = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        String from = '';
        String to = '';
        
        // Check if we have separate from/to fields (new structure)
        if (data['from'] != null && data['to'] != null && 
            data['from'].toString().isNotEmpty && data['to'].toString().isNotEmpty) {
          from = data['from'].toString();
          to = data['to'].toString();
        } 
        // Fallback to stations field (old structure)
        else if (data['stations'] != null && data['stations'].toString().isNotEmpty) {
          String stations = data['stations'].toString();
          // Split "A → B" or "A - B"
          List parts = stations.contains('→') 
              ? stations.split('→') 
              : stations.contains('-') 
                  ? stations.split('-') 
                  : [stations, ''];
          from = parts.length > 0 ? parts[0].trim() : '';
          to = parts.length > 1 ? parts[1].trim() : '';
        }

        loaded.add({
          'from': from,
          'to': to,
          'price': data['fare'] ?? '₹30',
          'line': data['line'] ?? '',
          'trains': data['trains']?.toString() ?? '0',
          'frequency': data['frequency'] ?? 'Every 10-15 mins',
          'duration': data['duration'] ?? '30-45 mins',
          'rating': 4.5,
          'stops': data['trains'] ?? 5,
        });
        
        print('📝 Loaded metro: $from → $to');
      }

      if (mounted) {
        setState(() {
          _firestoreMetros = loaded;
        });
      }
    });
  }

  void _loadBusesFromFirestore() {
    print('🔄 Listening to Firestore buses collection...');

    _busSubscription?.cancel();

    _busSubscription = _firestore.collection('buses').snapshots().listen((snapshot) {
      final List<Map<String, dynamic>> loadedBuses = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['from'] != null &&
            data['to'] != null &&
            data['from'].toString().isNotEmpty &&
            data['to'].toString().isNotEmpty) {

          loadedBuses.add({
            'id': doc.id,
            'route': '${data['from']} → ${data['to']}',
            'buses': data['buses']?.toString() ?? '0',
            'type': data['type'] ?? 'Electric',
            'price': data['price'] ?? '₹500',
            'from': data['from'].toString(),
            'to': data['to'].toString(),
            'rating': (data['rating'] ?? 4.5).toDouble(),
            'stops': data['stops'] ?? 1,
          });
        }
      }

      if (mounted) {
        setState(() {
          _firestoreBuses = loadedBuses;
        });
      }
    });
  }

  Future<void> _refreshData() async {
    print("🔄 Refreshing data...");
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {});
    }
  }

  // Book ticket and save to Firestore
  Future<void> _bookTicket(String from, String to, String price) async {
    try {
      await _firestore.collection('tickets').add({
        'from': from,
        'to': to,
        'date': selectedDateTime,
        'price': price,
        'bookingDate': DateTime.now(),
        'status': 'confirmed',
        'userId': 'user123',
      });

      _addNewTicketNotification(from, to);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket booked successfully! $from → $to'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error booking ticket: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to book ticket. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addNewTicketNotification(String from, String to) {
    if (!mounted) return;
    setState(() {
      _notificationCount++;
      _notifications.insert(0, {
        'title': 'New Ticket Booked!',
        'message': 'Your ticket from $from to $to has been successfully booked.',
        'type': 'ticket',
        'time': 'Just now',
      });
    });
  }

  void _addNewDestinationBusNotification(String from, String to) {
    if (!mounted) return;
    setState(() {
      _notificationCount++;
      _notifications.insert(0, {
        'title': 'New Route Available!',
        'message': 'Express service from $from to $to is now available!',
        'type': 'bus_route',
        'time': '5 min ago',
      });
    });
  }

  void _onNotificationTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(
          notifications: _notifications,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _notificationCount = 0;
        });
      }
    });
  }

  Future<void> pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (pickedTime == null) return;

    if (mounted) {
      setState(() {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  String getFormattedDateTime() {
    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][selectedDateTime.month - 1];
    return "${selectedDateTime.day} $month, ${selectedDateTime.year}";
  }

  void handleNavTap(int index) {
    setState(() => _page = index);

    if (index == 0) {
      Navigator.pushNamed(context, '/profile');
    } else if (index == 1) {
      // Stay here (Search Page)
    } else if (index == 2) {
      Navigator.pushNamed(context, '/accessibilityModeList');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/chatbot');
    }
  }

  (String, IconData) _getModeDetails() {
    switch (_selectedMode) {
      case TransportMode.bus:
        return ("Search Buses", Icons.directions_bus);
      case TransportMode.metro:
        return ("Search Metro", Icons.subway);
      case TransportMode.train:
        throw UnimplementedError();
    }
  }

  Widget _buildTransportButton(
      TransportMode mode, String label, IconData icon) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            _selectedMode = mode;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSearchCard() {
    final (buttonText, buttonIcon) = _getModeDetails();
    final bool isSearchEnabled = fromController.text.isNotEmpty && toController.text.isNotEmpty;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              buttonText,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // From/To Fields
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "From",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.circle, size: 10, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: fromController,
                                decoration: const InputDecoration.collapsed(
                                  hintText: "Enter departure city",
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                style: const TextStyle(fontSize: 16),
                                onChanged: (_) {
                                  if (mounted) setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Colors.grey),
                  onPressed: () {
                    String temp = fromController.text;
                    fromController.text = toController.text;
                    toController.text = temp;
                    if (mounted) setState(() {});
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "To",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: toController,
                                decoration: const InputDecoration.collapsed(
                                  hintText: "Enter destination city",
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                style: const TextStyle(fontSize: 16),
                                onChanged: (_) {
                                  if (mounted) setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Date Picker Row
            InkWell(
              onTap: pickDateTime,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getFormattedDateTime(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text("Date", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Search Button
            ElevatedButton.icon(
              onPressed: isSearchEnabled ? () {
                _addNewTicketNotification(fromController.text, toController.text);
                _addNewDestinationBusNotification(fromController.text, toController.text);

                Navigator.pushNamed(
                  context,
                  '/routeSuggestions',
                  arguments: RouteSuggestionArgs(
                    fromController.text, 
                    toController.text,
                    _selectedMode,
                  ),
                );
              } : null,
              icon: Icon(buttonIcon, size: 24),
              label: Text(
                buttonText,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSearchEnabled ? Colors.blue.shade700 : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularRoutes() {
    final List<Map<String, dynamic>> allRoutes = [];
    List<Map<String, dynamic>> selectedList = [];

    // Mode wise data selection
    if (_selectedMode == TransportMode.bus) {
      selectedList = _firestoreBuses;
    } else if (_selectedMode == TransportMode.metro) {
      selectedList = _firestoreMetros;
    }

    print('📊 Showing ${selectedList.length} routes for $_selectedMode');

    for (var item in selectedList) {
      if (item['from'] != null &&
          item['to'] != null &&
          item['from'].toString().isNotEmpty &&
          item['to'].toString().isNotEmpty) {

        allRoutes.add({
          'city1': item['from'].toString(),
          'city2': item['to'].toString(),
          'rating': item['rating'] ?? 4.5,
          'price': item['price'] ?? (_selectedMode == TransportMode.bus ? '₹500' : '₹30'),
          'stops': item['stops'] ?? 1,
          'isFirestore': true,
          'type': _selectedMode == TransportMode.bus ? 'bus' : 'metro',
          'buses': _selectedMode == TransportMode.bus ? item['buses'] ?? '0' : null,
          'trains': _selectedMode == TransportMode.metro ? item['trains'] ?? '0' : null,
          'frequency': _selectedMode == TransportMode.metro ? item['frequency'] : null,
        });

        print('✅ Added route: ${item['from']} → ${item['to']}');
      }
    }
    
    // Add default routes if Firestore is empty
    if (allRoutes.isEmpty) {
      print('⚠️ No Firestore routes found, showing default routes');
      if (_selectedMode == TransportMode.bus) {
        allRoutes.addAll([
          {'city1': "Pune", 'city2': "Mumbai", 'rating': 4.8, 'price': "₹450", 'stops': 1, 'isFirestore': false, 'type': 'bus'},
          {'city1': "Pune", 'city2': "Nashik", 'rating': 4.6, 'price': "₹350", 'stops': 0, 'isFirestore': false, 'type': 'bus'},
          {'city1': "Pune", 'city2': "Goa", 'rating': 4.7, 'price': "₹900", 'stops': 3, 'isFirestore': false, 'type': 'bus'},
        ]);
      } else {
        allRoutes.addAll([
          {'city1': "PCMC", 'city2': "Civil Court", 'rating': 4.8, 'price': "₹20-₹40", 'stops': 12, 'isFirestore': false, 'type': 'metro', 'frequency': 'Every 10-15 mins'},
          {'city1': "Vanaz", 'city2': "Ramwadi", 'rating': 4.6, 'price': "₹15-₹35", 'stops': 9, 'isFirestore': false, 'type': 'metro', 'frequency': 'Every 12-18 mins'},
          {'city1': "Hinjewadi", 'city2': "Shivajinagar", 'rating': 4.7, 'price': "₹25-₹45", 'stops': 8, 'isFirestore': false, 'type': 'metro', 'frequency': 'Every 15-20 mins'},
        ]);
      }
    }

    // Remove duplicates
    final uniqueRoutes = <Map<String, dynamic>>[];
    final seen = <String>{};
    
    for (var route in allRoutes) {
      final key = '${route['city1']}-${route['city2']}';
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueRoutes.add(route);
      }
    }
    
    print('📊 Total unique routes: ${uniqueRoutes.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedMode == TransportMode.bus ? "Popular Bus Routes" : "Popular Metro Routes",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _refreshData,
              child: const Text("Refresh",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (uniqueRoutes.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    _selectedMode == TransportMode.bus ? Icons.directions_bus : Icons.subway,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedMode == TransportMode.bus ? 'No bus routes available' : 'No metro routes available',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    _selectedMode == TransportMode.bus ? 'Add bus routes from admin panel' : 'Add metro routes from admin panel',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: uniqueRoutes.take(8).map((route) {
                return GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        fromController.text = route['city1'];
                        toController.text = route['city2'];
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected: ${route['city1']} → ${route['city2']}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: route['isFirestore'] == true 
                          ? (_selectedMode == TransportMode.bus ? Colors.blue.shade50 : Colors.purple.shade50)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.orange, size: 14),
                                      const SizedBox(width: 4),
                                      Text((route['rating'] as double).toStringAsFixed(1), 
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                if (route['isFirestore'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _selectedMode == TransportMode.bus ? "Live" : "Active",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedMode == TransportMode.bus ? Colors.green : Colors.purple,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text("${route['city1']} → ${route['city2']}",
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("${route['stops']} stops", 
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            if (route['type'] == 'metro' && route['frequency'] != null)
                              Text(route['frequency'],
                                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            const SizedBox(height: 8),
                            Text(route['price'],
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            if (route['isFirestore'] == true && route['buses'] != null && _selectedMode == TransportMode.bus)
                              Text(
                                "${route['buses']} buses available",
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            if (route['isFirestore'] == true && route['trains'] != null && _selectedMode == TransportMode.metro)
                              Text(
                                "${route['trains']} trains available",
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
  
  Widget _buildSpecialOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Special Offers",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/accessibilityModeList');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.orange.shade700, Colors.deepOrange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "20% OFF",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900),
                      ),
                      Text(
                        "Limited Offer - Book Now!",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Icon(Icons.local_offer, color: Colors.white, size: 40),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecommendedRoutes() {
    late String titleText;
    late List<Map<String, dynamic>> routeData;
    late IconData modeIcon;
    late Color iconColor;

    if (_selectedMode == TransportMode.bus) {
      titleText = "Top Bus Routes 🚌";
      modeIcon = Icons.directions_bus;
      iconColor = Colors.green.shade700;
      
      // Get Firestore bus routes
      final firestoreRoutes = _firestoreBuses.map((bus) {
        return {
          "title": "${bus['from']} to ${bus['to']}",
          "subtitle": "${bus['type']} - ${bus['price']} | ${bus['buses']} buses available",
          "isFirestore": true,
          "from": bus['from'],
          "to": bus['to'],
        };
      }).toList();
      
      // Hardcoded bus routes as fallback
      final hardcodedRoutes = [
        {"title": "Delhi to Agra", "subtitle": "Express buses, 3 hours", "isFirestore": false, "from": "Delhi", "to": "Agra"},
        {"title": "Bangalore to Chennai", "subtitle": "Frequent AC services", "isFirestore": false, "from": "Bangalore", "to": "Chennai"},
        {"title": "Mumbai to Goa", "subtitle": "Overnight sleeper service", "isFirestore": false, "from": "Mumbai", "to": "Goa"},
      ];
      
      routeData = [...firestoreRoutes, ...hardcodedRoutes].take(3).toList();
      
    } else {
      titleText = "Top Metro Routes 🚆";
      modeIcon = Icons.subway;
      iconColor = Colors.purple.shade700;
      
      // Get Firestore metro routes
      final firestoreRoutes = _firestoreMetros.map((metro) {
        return {
          "title": "${metro['from']} to ${metro['to']}",
          "subtitle": "${metro['frequency']} | ${metro['duration']} | ${metro['price']}",
          "isFirestore": true,
          "from": metro['from'],
          "to": metro['to'],
        };
      }).toList();
      
      // Hardcoded metro routes as fallback
      final hardcodedRoutes = [
        {"title": "PCMC to Civil Court", "subtitle": "Purple Line | Every 10-15 mins", "isFirestore": false, "from": "PCMC", "to": "Civil Court"},
        {"title": "Vanaz to Ramwadi", "subtitle": "Aqua Line | Every 12-18 mins", "isFirestore": false, "from": "Vanaz", "to": "Ramwadi"},
        {"title": "Hinjewadi to Shivajinagar", "subtitle": "Hinjewadi Line | Every 15-20 mins", "isFirestore": false, "from": "Hinjewadi", "to": "Shivajinagar"},
      ];
      
      routeData = [...firestoreRoutes, ...hardcodedRoutes].take(3).toList();
    }

    List<Widget> routeItems = routeData.map((data) {
      return GestureDetector(
        onTap: () {
          if (data.containsKey('from') && data.containsKey('to')) {
            if (mounted) {
              setState(() {
                fromController.text = data['from']!;
                toController.text = data['to']!;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected: ${data['from']} → ${data['to']}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          }
        },
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          color: data['isFirestore'] == true 
              ? (_selectedMode == TransportMode.bus ? Colors.blue.shade50 : Colors.purple.shade50)
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(modeIcon, color: iconColor),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    data['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (data['isFirestore'] == true)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _selectedMode == TransportMode.bus ? Colors.green.shade100 : Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _selectedMode == TransportMode.bus ? "Live" : "Active",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _selectedMode == TransportMode.bus ? Colors.green : Colors.purple,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Text(data['subtitle']!),
          ),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleText,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        ...routeItems,
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    _busSubscription?.cancel();
    _metroSubscription?.cancel();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      
      bottomNavigationBar: SafeArea(
        top: false,
        child: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 1,
          height: 70, 
          backgroundColor: Colors.transparent,
          color: Colors.blue.shade600,
          buttonBackgroundColor: Colors.blue.shade800,
          items: const [
            Icon(Icons.person, size: 30, color: Colors.white),
            Icon(Icons.search, size: 30, color: Colors.white),
            Icon(Icons.accessibility_new, size: 30, color: Colors.white),
            Icon(Icons.chat_bubble_outline, size: 30, color: Colors.white),
          ],
          onTap: handleNavTap,
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 24,
              left: 16,
              right: 16,
              bottom: 0
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back! 👋',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ready for your next adventure?',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _onNotificationTap,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blue.shade100,
                              child: const Icon(Icons.notifications_none,
                                  color: Colors.blue),
                            ),
                            if (_notificationCount > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    _notificationCount.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTransportButton(
                            TransportMode.bus, "Bus", Icons.directions_bus),
                        const SizedBox(width: 8),
                        _buildTransportButton(
                            TransportMode.metro, "Metro", Icons.subway),
                      ],
                    ),
                  ),

                  _buildSearchCard(),
                  _buildPopularRoutes(),
                  const SizedBox(height: 16),
                  _buildSpecialOffers(),
                  _buildRecommendedRoutes(),
                  
                  // Show status indicators
                  if (_selectedMode == TransportMode.bus && _firestoreBuses.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(
                        '${_firestoreBuses.length} bus routes available',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_selectedMode == TransportMode.metro && _firestoreMetros.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(
                        '${_firestoreMetros.length} metro routes available',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  final List<Map<String, String>> notifications;

  const NotificationScreen({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'No new notifications.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(
                      notification['type'] == 'ticket'
                          ? Icons.airplane_ticket
                          : Icons.location_city,
                      color: notification['type'] == 'ticket'
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(
                      notification['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notification['message']!),
                    trailing: Text(
                      notification['time']!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }
}