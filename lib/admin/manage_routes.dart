import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageRoutesPage extends StatefulWidget {
  const ManageRoutesPage({super.key});

  @override
  State<ManageRoutesPage> createState() => _ManageRoutesPageState();
}

class _ManageRoutesPageState extends State<ManageRoutesPage> {
  // Sample route data with suggestions
  List<Map<String, dynamic>> routes = [];
  
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Text controllers for add/edit
  final TextEditingController routeIdC = TextEditingController();
  final TextEditingController fromC = TextEditingController();
  final TextEditingController toC = TextEditingController();
  final TextEditingController priceC = TextEditingController();
  final TextEditingController durationC = TextEditingController();
  final TextEditingController stopsC = TextEditingController();
  final TextEditingController ratingC = TextEditingController();
  final TextEditingController transportModeC = TextEditingController();
  
  // Selected transport mode
  String _selectedTransportMode = "Bus";
  
  // Sample route suggestions
  final List<Map<String, dynamic>> routeSuggestions = [
    {
      "id": "S001",
      "from": "Swargate",
      "to": "Hinjewadi Phase 2",
      "transportMode": "Bus",
      "title": "BUS",
      "subtitle": "Cheapest route",
      "price": "₹45",
      "travelTime": "1h 20m",
      "details": "Direct PMPML bus via Katraj tunnel",
      "stops": 15,
      "rating": 4.2,
      "mode": "Direct Bus",
    },
    {
      "id": "S002",
      "from": "Swargate",
      "to": "Hinjewadi Phase 2",
      "transportMode": "Metro + Bus",
      "title": "METRO + BUS",
      "subtitle": "Fastest route",
      "price": "₹60",
      "travelTime": "55m",
      "details": "Metro to Shivaji Nagar + Bus 120A",
      "stops": 8,
      "rating": 4.5,
      "mode": "Mixed Transport",
    },
    {
      "id": "S003",
      "from": "Pune",
      "to": "Mumbai",
      "transportMode": "Bus",
      "title": "VOLVO BUS",
      "subtitle": "Fastest bus",
      "price": "₹650",
      "travelTime": "3h 15m",
      "details": "Volvo AC bus, fewer stops",
      "stops": 1,
      "rating": 4.7,
      "mode": "Luxury Bus",
    },
    {
      "id": "S004",
      "from": "Pune",
      "to": "Mumbai",
      "transportMode": "Train",
      "title": "DECCAN QUEEN",
      "subtitle": "Fastest train",
      "price": "₹650",
      "travelTime": "2h 45m",
      "details": "Deccan Queen Express, AC Chair Car",
      "stops": 5,
      "rating": 4.7,
      "mode": "Express Train",
    },
    {
      "id": "S005",
      "from": "Delhi",
      "to": "Agra",
      "transportMode": "Train",
      "title": "GATIMAAN EXP",
      "subtitle": "Fastest train",
      "price": "₹850",
      "travelTime": "2h 15m",
      "details": "Gatimaan Express, AC Chair Car",
      "stops": 1,
      "rating": 4.8,
      "mode": "High-speed Train",
    },
    {
      "id": "S006",
      "from": "Pune",
      "to": "Bangalore",
      "transportMode": "Train",
      "title": "UDYAN EXP",
      "subtitle": "Fastest train",
      "price": "₹1200",
      "travelTime": "14h",
      "details": "AC Sleeper, limited stops",
      "stops": 8,
      "rating": 4.5,
      "mode": "Superfast Train",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRoutesFromFirestore();
  }

  Future<void> _loadRoutesFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('routes').get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          routes = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              "id": doc.id,
              "from": data['from'] ?? '',
              "to": data['to'] ?? '',
              "transportMode": data['transportMode'] ?? 'Bus',
              "title": data['title'] ?? '',
              "subtitle": data['subtitle'] ?? '',
              "price": data['price'] ?? '',
              "travelTime": data['travelTime'] ?? '',
              "details": data['details'] ?? '',
              "stops": data['stops'] ?? 0,
              "rating": data['rating'] ?? 4.5,
              "mode": data['mode'] ?? '',
            };
          }).toList();
        });
      } else {
        // Load sample suggestions if Firestore is empty
        setState(() {
          routes = List.from(routeSuggestions);
        });
      }
    } catch (e) {
      print('Error loading routes: $e');
      setState(() {
        routes = List.from(routeSuggestions);
      });
    }
  }

  Future<void> _addRouteToFirestore() async {
    try {
      final routeData = {
        "from": fromC.text.trim(),
        "to": toC.text.trim(),
        "transportMode": _selectedTransportMode,
        "title": titleC.text.trim(),
        "subtitle": subtitleC.text.trim(),
        "price": priceC.text.trim(),
        "travelTime": durationC.text.trim(),
        "details": detailsC.text.trim(),
        "stops": int.tryParse(stopsC.text) ?? 0,
        "rating": double.tryParse(ratingC.text) ?? 4.5,
        "mode": modeC.text.trim(),
        "createdAt": DateTime.now(),
      };
      
      await _firestore.collection('routes').add(routeData);
      await _loadRoutesFromFirestore();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Route added successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      print('Error adding route: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add route: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateRouteInFirestore(String docId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('routes').doc(docId).update(updatedData);
      await _loadRoutesFromFirestore();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Route updated successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      print('Error updating route: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update route: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteRouteFromFirestore(String docId) async {
    try {
      await _firestore.collection('routes').doc(docId).delete();
      await _loadRoutesFromFirestore();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Route deleted successfully!'), backgroundColor: Colors.red),
      );
    } catch (e) {
      print('Error deleting route: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete route: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _addRoute() {
    _clearFields();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Add New Route Suggestion"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fromC,
                decoration: const InputDecoration(labelText: "From", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: toC,
                decoration: const InputDecoration(labelText: "To", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTransportMode,
                decoration: const InputDecoration(labelText: "Transport Mode", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "Bus", child: Text("Bus")),
                  DropdownMenuItem(value: "Train", child: Text("Train")),
                  DropdownMenuItem(value: "Metro", child: Text("Metro")),
                  DropdownMenuItem(value: "Metro + Bus", child: Text("Metro + Bus")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTransportMode = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: "Title (e.g., BUS, EXPRESS)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleC,
                decoration: const InputDecoration(labelText: "Subtitle (e.g., Cheapest route)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceC,
                decoration: const InputDecoration(labelText: "Price", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationC,
                decoration: const InputDecoration(labelText: "Travel Time", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stopsC,
                decoration: const InputDecoration(labelText: "Number of Stops", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ratingC,
                decoration: const InputDecoration(labelText: "Rating (1-5)", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modeC,
                decoration: const InputDecoration(labelText: "Mode (e.g., Direct Bus)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsC,
                decoration: const InputDecoration(labelText: "Details", border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFields();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (fromC.text.isNotEmpty && toC.text.isNotEmpty && 
                  titleC.text.isNotEmpty && priceC.text.isNotEmpty) {
                Navigator.pop(context);
                await _addRouteToFirestore();
                _clearFields();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _editRoute(Map<String, dynamic> route) {
    fromC.text = route["from"] ?? '';
    toC.text = route["to"] ?? '';
    _selectedTransportMode = route["transportMode"] ?? 'Bus';
    titleC.text = route["title"] ?? '';
    subtitleC.text = route["subtitle"] ?? '';
    priceC.text = route["price"] ?? '';
    durationC.text = route["travelTime"] ?? '';
    stopsC.text = route["stops"]?.toString() ?? '0';
    ratingC.text = route["rating"]?.toString() ?? '4.5';
    modeC.text = route["mode"] ?? '';
    detailsC.text = route["details"] ?? '';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Edit Route Suggestion"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fromC,
                decoration: const InputDecoration(labelText: "From", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: toC,
                decoration: const InputDecoration(labelText: "To", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTransportMode,
                decoration: const InputDecoration(labelText: "Transport Mode", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: "Bus", child: Text("Bus")),
                  DropdownMenuItem(value: "Train", child: Text("Train")),
                  DropdownMenuItem(value: "Metro", child: Text("Metro")),
                  DropdownMenuItem(value: "Metro + Bus", child: Text("Metro + Bus")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTransportMode = value!;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtitleC,
                decoration: const InputDecoration(labelText: "Subtitle", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceC,
                decoration: const InputDecoration(labelText: "Price", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationC,
                decoration: const InputDecoration(labelText: "Travel Time", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stopsC,
                decoration: const InputDecoration(labelText: "Number of Stops", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ratingC,
                decoration: const InputDecoration(labelText: "Rating", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modeC,
                decoration: const InputDecoration(labelText: "Mode", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsC,
                decoration: const InputDecoration(labelText: "Details", border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearFields();
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedData = {
                "from": fromC.text.trim(),
                "to": toC.text.trim(),
                "transportMode": _selectedTransportMode,
                "title": titleC.text.trim(),
                "subtitle": subtitleC.text.trim(),
                "price": priceC.text.trim(),
                "travelTime": durationC.text.trim(),
                "details": detailsC.text.trim(),
                "stops": int.tryParse(stopsC.text) ?? 0,
                "rating": double.tryParse(ratingC.text) ?? 4.5,
                "mode": modeC.text.trim(),
                "updatedAt": DateTime.now(),
              };
              
              Navigator.pop(context);
              await _updateRouteInFirestore(route["id"], updatedData);
              _clearFields();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  void _deleteRoute(Map<String, dynamic> route) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Route"),
        content: Text("Are you sure you want to delete route from ${route['from']} to ${route['to']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteRouteFromFirestore(route["id"]);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _clearFields() {
    fromC.clear();
    toC.clear();
    titleC.clear();
    subtitleC.clear();
    priceC.clear();
    durationC.clear();
    stopsC.clear();
    ratingC.clear();
    modeC.clear();
    detailsC.clear();
  }

  // Controllers for additional fields
  final TextEditingController titleC = TextEditingController();
  final TextEditingController subtitleC = TextEditingController();
  final TextEditingController modeC = TextEditingController();
  final TextEditingController detailsC = TextEditingController();

  Color _getModeColor(String transportMode) {
    if (transportMode.contains("Bus")) return Colors.green.shade700;
    if (transportMode.contains("Train")) return Colors.blue.shade700;
    if (transportMode.contains("Metro")) return Colors.purple.shade700;
    return Colors.orange.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Manage Route Suggestions",
            style: GoogleFonts.poppins(
                fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("Add, edit or delete transport route suggestions for users.",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade700)),
        const SizedBox(height: 20),

        // Add button
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _addRoute,
            icon: const Icon(Icons.add),
            label: const Text("Add Route Suggestion"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Route suggestions list
        Expanded(
          child: routes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.route, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No route suggestions found',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click "Add Route Suggestion" to create one',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with route info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _getModeColor(route["transportMode"] ?? 'Bus').withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          route["transportMode"]?.contains("Bus") == true ? Icons.directions_bus :
                                          route["transportMode"]?.contains("Train") == true ? Icons.train :
                                          Icons.subway,
                                          color: _getModeColor(route["transportMode"] ?? 'Bus'),
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${route["from"]} → ${route["to"]}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              route["title"] ?? '',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Action buttons
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                      onPressed: () => _editRoute(route),
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () => _deleteRoute(route),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // Details row
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _buildInfoChip(Icons.schedule, route["travelTime"] ?? 'N/A'),
                                _buildInfoChip(Icons.currency_rupee, route["price"] ?? 'N/A'),
                                _buildInfoChip(Icons.star, "${route["rating"] ?? 4.5} ★"),
                                _buildInfoChip(Icons.location_on, "${route["stops"] ?? 0} stops"),
                                _buildInfoChip(Icons.info_outline, route["mode"] ?? 'N/A'),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Details text
                            if (route["details"] != null && route["details"].toString().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        route["details"],
                                        style: TextStyle(
                                          fontSize: 12,
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}